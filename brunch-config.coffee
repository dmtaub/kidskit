module.exports =
  server:
    port: 4444
  files:
    javascripts:
      joinTo: 'app.js' #defalt looks in app/
    stylesheets:
      joinTo: 'app.css'
  modules:
    autoRequire:
      'app.js': ['index']
  npm:
    enabled: true
    aliases:
      'react': 'preact-compat'
      'react-dom': 'preact-compat'
