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
      r: 10
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

  parseAndRender: =>
    console.log("compile")
    js = coffeescript.compile(@editor.getValue(), {bare:true})
    core.compile(js).then (result) ->
      for csg in result
        csg.toTriangles()
      console.log(result)

  setupTHREE: ->
    # camera
    x = 2.5
    #grid
    size = 10
    divisions = 10
    cameraStart = new THREE.Vector3(0, size, 2*size)
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
    # Light
    light = new THREE.DirectionalLight(0xFFFFFF)
    light.position.copy(lightStart)
    light.target.position.copy(scene.position)

    scene.add @data.sceneRoot

    render = ->
      #requestAnimationFrame render
      renderer.render scene, camera

    controls = new THREE.EditorControls( camera, renderer.domElement )
    controls.addEventListener( 'change', render )

    window.onresize = () ->
      renderer.setSize viewport.clientWidth, viewport.clientHeight

      camera.aspect = renderer.domElement.offsetWidth / renderer.domElement.offsetHeight
      camera.updateProjectionMatrix()

      camera.aspect = renderer.domElement.offsetWidth / renderer.domElement.offsetHeight
      camera.updateProjectionMatrix()

      renderer.setSize( renderer.domElement.offsetWidth, renderer.domElement.offsetHeight )

      render()

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
