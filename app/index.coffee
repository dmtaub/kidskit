console.log "REQUIRED"

coffeescript = require('coffeescript')
window.THREE = require('three')

window.core = require('@jscad/core')

#require('three/examples/js/controls/OrbitControls')
require('three/examples/js/controls/EditorControls')

window.onload = () ->
  console.log("WINDOW LOADED")
  window.cad = new CADffee()

# todo, build out examples and pull from localstorage/db
editorContent = '''main = (params) ->
  return [
    sphere
      r: 2
  ]'''

class CADffee
  data:
    # todo: hash code to csg / canonicalized CSG properties to geometry
    csgCache: {}  #not sure if both are needed...
    geometryCache: {}
    sceneRoot: new THREE.Object3D()  # renderables go here

  constructor: ->
    @setupEditor()
    @editor.setValue(editorContent)
    @setupTHREE()

  clearNode: (node) ->
    while(node.children.length > 0)
      @clearNode(node.children[0])
      node.remove(node.children[0])
    # these not needed here when we start caching things
    # though probably
    # TODO: reference count
    if(node.geometry)
      node.geometry.dispose()
    if(node.material) #assume multimaterial
      material.dispose() for material in node.material
    if(node.texture)
      node.texture.dispose()


  ###
     adapted from THREE.CSG by bebbi
     https://github.com/jscad/csg.js/commit/6e0f0c68dd34747a1bd4b0f42afd4d11a99b0f4e

     @author Chandler Prall <chandler.prall@gmail.com> http://chandler.prallfamily.com

     Wrapper for Evan Wallace's CSG library (https://github.com/evanw/csg.js/)
     Provides CSG capabilities for Three.js models.

     Provided under the MIT License
  ###
  fromCSG: (csg, defaultColor = [0,0.5,0.5,0.9]) ->
    three_geometry = new (THREE.Geometry)
    console.log(csg)
    polygons = csg.toPolygons()
    # dict of different THREE.Colors in mesh
    colors = {}
    # list of different opacities used by polygons
    opacities = []
    polygons.forEach ((polygon) =>
      # polygon shared null? -> defaultColor, else extract color
      vertices = polygon.vertices.map(((vertex) ->
        @_getGeometryVertex three_geometry, vertex.pos
      ), this)
      if vertices[0] == vertices[vertices.length - 1]
        vertices.pop()
      polyColor = if polygon.shared.color then polygon.shared.color.slice() else defaultColor.slice()
      opacity = polyColor.pop()
      # one material per opacity (color not relevant)
      # collect different opacity values in opacities
      # point to current polygon opacity with materialIdx
      opacityIdx = opacities.indexOf(opacity)
      if opacityIdx > -1
        materialIdx = opacityIdx
      else
        opacities.push opacity
        materialIdx = opacities.length - 1
      # for each different color, create a color object
      colorKey = polyColor.join('_')
      if not colors[colorKey]?
        color = new THREE.Color()
        color.setRGB.apply color, polyColor
        colors[colorKey] = color
      # create a mesh face using color (not opacity~material)
      k = 2
      while k < vertices.length
        face = new THREE.Face3(
          vertices[0],
          vertices[k - 1],
          vertices[k],
          polygon.plane.normal.clone(),
          colors[colorKey],
          materialIdx
        )
        face.materialIdx = materialIdx
        three_geometry.faces.push face
        k++
      return
    )
    # for each opacity in array, create a matching material
    # (color are on faces, not materials)
    materials = opacities.map((opa) ->
      # trigger wireframe if opa == 0
      asWireframe = opa == 0
      # if opacity == 0, this is just a wireframe
      phongMaterial = new THREE.MeshPhongMaterial(
        opacity: opa or 1
        wireframe: asWireframe
        transparent: opa != 1 and opa != 0
        vertexColors: THREE.FaceColors
        # added this so we could see something
        flatShading: THREE.FlatShading,
      )
      # (force white wireframe)
      # if (asWireframe)
      #     phongMaterial.color = 'white'
      #
      if opa > 0 and opa < 1
        phongMaterial.depthWrite = false
      return phongMaterial
    )
    # now, materials is array of materials matching opacities - color not defined yet
    colorMesh = new THREE.Mesh(
      three_geometry,
      materials
    )
    # pass back bounding sphere radius
    three_geometry.computeBoundingSphere()
    boundLen = three_geometry.boundingSphere.radius + three_geometry.boundingSphere.center.length()
    phongWireframeMaterial = new THREE.MeshPhongMaterial(
      wireframe: true
      transparent: false
      color: 'white')
    wireframe = new THREE.Mesh(three_geometry, phongWireframeMaterial)
    # return result;
    return {
      colorMesh: colorMesh
      wireframe: wireframe
      boundLen: boundLen
    }

  _getGeometryVertex: (geometry, vertex_position) ->
    # var i;
    # // If Vertex already exists
    # // once required this should be done with the BSP info
    # for ( i = 0; i < geometry.vertices.length; i++ ) {
    #  if ( geometry.vertices[i].x === vertex_position.x &&
    #      geometry.vertices[i].y === vertex_position.y &&
    #      geometry.vertices[i].z === vertex_position.z ) {
    #      return i;
    #  }
    # }
    geometry.vertices.push new (THREE.Vector3)(vertex_position.x, vertex_position.y, vertex_position.z)
    geometry.vertices.length - 1


  # csgToMesh: (triangles) ->
  #   len = triangles.length
  #   console.log triangles

  parseAndRender: =>
    console.log("compile")
    js = coffeescript.compile(@editor.getValue(), {bare:true})
    meshes = []
    core.compile(js).then (result) =>
      for csg in result
        meshes.push @fromCSG(csg).colorMesh
        #TODO: generate buffer geometry from csg polygons directly for efficiency
        #meshes.push(@csgToMesh(csg.toTriangles()))
      @clearNode(@data.sceneRoot)
      for mesh in meshes
        #@data.sceneRoot.add(new THREE.AxesHelper(3))
        @data.sceneRoot.add(mesh)
      @render()
    .catch (error) =>
      console.error(error.message)
      console.log(js)

  setupTHREE: ->
    # camera
    x = 2.5
    #grid
    size = 10
    divisions = 10
    cameraStart = new THREE.Vector3(size, size, 2*size)
    lightStart =  new THREE.Vector3(20, 40, -15)

    scene = new THREE.Scene()
    gridHelper = new THREE.GridHelper( size, divisions )
    scene.add gridHelper

    renderer = new THREE.WebGLRenderer(antialias: true)
    viewport = document.getElementById('viewport')
    renderer.setSize viewport.clientWidth, viewport.clientHeight
    viewport.appendChild renderer.domElement
    camera = new THREE.PerspectiveCamera(35, viewport.clientWidth / viewport.clientHeight, 1, 1000)
    camera.position.copy(cameraStart)
    camera.lookAt(scene.position)
    scene.add camera

    light = new THREE.DirectionalLight(0xFFFFFF)
    light.position.copy(lightStart)
    light.target.position.copy(scene.position)
    scene.add light

    hemiLight = new THREE.HemisphereLight(0xffffff, 0xffffff, 0.6)
    hemiLight.color.setHSL 0.6, 0.15, 0.5
    hemiLight.groundColor.setHSL 0.095, 0.15, 0.5
    hemiLight.position.set 0, 500, 0
    scene.add hemiLight
    # dirLight = new THREE.DirectionalLight(0xffffff, 1)
    # dirLight.position.set -1, 0.75, 1
    # dirLight.position.multiplyScalar 50
    # dirLight.name = 'dirlight'
    # scene.add dirLight

    scene.add @data.sceneRoot

    @render = ->
      #requestAnimationFrame render
      renderer.render scene, camera

    controls = new THREE.EditorControls( camera, renderer.domElement )
    controls.addEventListener( 'change', @render )

    window.onresize = () =>
      renderer.setSize viewport.clientWidth, viewport.clientHeight

      camera.aspect = renderer.domElement.offsetWidth / renderer.domElement.offsetHeight
      camera.updateProjectionMatrix()

      camera.aspect = renderer.domElement.offsetWidth / renderer.domElement.offsetHeight
      camera.updateProjectionMatrix()

      renderer.setSize( renderer.domElement.offsetWidth, renderer.domElement.offsetHeight )

      @render()

    window.onresize()

  setupEditor: () ->
    ace.require("ace/ext/language_tools")

    @editor = ace.edit("editor")
    @editor.setTheme("ace/theme/monokai")

    options =
      enableBasicAutocompletion: true
      enableSnippets: false
      enableLiveAutocompletion: false

    @editor.session.setTabSize(2)
    @editor.session.setMode("ace/mode/coffee")

    @editor.commands.addCommand
      name: 'render'
      bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'}
      exec: @parseAndRender

    @editor.setOptions(options)
