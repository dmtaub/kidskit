console.log "REQUIRED"
window.onload = () ->
  console.log("WINDOW LOADED")
  ace.require("ace/ext/language_tools")
  
  window.editor = ace.edit("editor")
  editor.setTheme("ace/theme/monokai")
  
  options = 
    enableBasicAutocompletion: true
    enableSnippets: false
    enableLiveAutocompletion: false
  
  editor.session.setTabSize(2)
  editor.session.setMode("ace/mode/coffee")

  editor.commands.addCommand
    name: 'render'
    bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'}
    exec: (editor) ->
      console.log("compile")
  
  editor.setOptions(options)
