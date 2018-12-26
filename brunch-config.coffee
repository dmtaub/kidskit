module.exports =
  files:
    javascripts:
      joinTo: 'app.js' #defalt looks in app/
    stylesheets:
      joinTo: 'app.css'
  modules:
    autoRequire:
      'app.js': ['index']
