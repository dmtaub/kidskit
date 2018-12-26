console.log "HOME"

window.onload = () ->
  console.log("LOADED")
  window.editor = ace.edit("editor")
  editor.setTheme("ace/theme/monokai")
  editor.session.setMode("ace/mode/coffee")

