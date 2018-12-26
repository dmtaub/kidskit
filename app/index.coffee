console.log "HOME"

window.onload = () ->
  console.log("LOADED")
  editor = ace.edit("editor")
  editor.session.setMode("ace/modes/javascript")
  editor.setTheme("ace/theme/chrome")

