console.log "HOME"

window.onload = () ->
  console.log("LOADED")
  editor = ace.edit("editor")
  editor.setTheme("ace/theme/monokai")
  editor.session.setMode("ace/modes/javascript")

