path = require "path"
g = require("gulp-help")(require "gulp")

freeport = require "freeport"
q = require "q"

lint = require "gulp-coffeelint"
plumber = require "gulp-plumber"
notify = require "gulp-notify"
uglify = require "gulp-uglify"
less = require "gulp-less"
rename = require "gulp-rename"
autoprefixer = require "gulp-autoprefixer"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
connect = require "gulp-connect"
sourcemaps = require "gulp-sourcemaps"
karma = require "gulp-karma-runner"
protractor = require("gulp-protractor").protractor

LessPluginCleanCSS = require "less-plugin-clean-css"
cleancss = new LessPluginCleanCSS(
  "advanced": true
  "rebase": true
)

karmaConf =
  "basePath": "./"
  "quiet": process.env.mode isnt "CI"
  "frameworks": ["mocha", "chai", "sinon"]
  "reporters": ["progress"]
  "colors": true
  "logLevel": "INFO"
  "autoWatch": false
  "singleRun": process.env.mode is "CI"
  "port": 9876
  "preprocessors":
    "**/*.coffee": ["coffee"]
  "coffeePreprocessor":
    "options":
      "sourceMap": true
  "browsers": [
    "Chrome"
    "Firefox"
    "PhantomJS"
  ]
  "plugins": [
    "karma-mocha"
    "karma-chai-plugins"
    "karma-chrome-launcher"
    "karma-firefox-launcher"
    "karma-coffee-preprocessor"
    "karma-sinon"
  ]

if process.env.mode is "CI"
  karmaConf.plugins.splice(
    karmaConf.plugins.indexOf("karma-chrome-launcher"), 1
  )
  karmaConf.browsers.splice(
    karmaConf.browsers.indexOf("firefox"), 1
  )

thirdParty = [
  "jquery/dist/jquery.js"
  "angular/angular.min.js"
  "angular-mocks/angular-mocks.js"
]

g.task "test.syntax", ->
  g.src([
    "./gulpfile.coffee",
    "./src/**/*.coffee",
    "./tests/**/*.coffee"
  ]).pipe(
    lint "./coffeelint.json"
  ).pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    lint.reporter "coffeelint-stylish"
  ).pipe(
    lint.reporter "failOnWarning"
  )

serverDep = undefined
if process.env.mode is "CI"
  serverDep = ["test.syntax"]
g.task "test.server", serverDep, ->
  g.src(
    thirdParty.map(
      (file) -> path.join "bower_components", file
    ).concat("./src/**/*.coffee", "./tests/unit/**/*.coffee"), "read": false
  ).pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    karma.server karmaConf
  )

runnerDep = undefined
if process.env.mode isnt "CI"
  runnerDep = ["test.syntax"]
g.task "test.runner", runnerDep, ->
  g.src(
    thirdParty.map(
      (file) -> path.join "bower_components", file
    ).concat("./src/**/*.coffee", "./tests/unit/**/*.coffee"), "read": false
  ).pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    karma.runner karmaConf
  )

g.task "compile", [
  if process.env.mode isnt "CI" then "test.runner" else "test.server"
], ->
  g.src("./src/**/*.coffee").pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    coffee()
  ).pipe(
    concat("angular-tageditor.min.js")
  ).pipe(
    uglify "mangle": true
  ).pipe g.dest "./dist"

  g.src("./src/**/*.coffee").pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    sourcemaps.init()
  ).pipe(
    coffee()
  ).pipe(
    concat("angular-tageditor.js")
  ).pipe(
    sourcemaps.write()
  ).pipe g.dest "./dist"

  g.src("./src/**/main.less").pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    sourcemaps.init()
  ).pipe(
    less()
  ).pipe(
    autoprefixer()
  ).pipe(
    rename "basename": "assets"
  ).pipe(
    sourcemaps.write()
  ).pipe(g.dest "./dist")

  g.src("./src/**/main.less").pipe(
    plumber "errorHandler": notify.onError '<%= error.message %>'
  ).pipe(
    less("plugins": [cleancss])
  ).pipe(
    autoprefixer()
  ).pipe(
    rename "basename": "assets.min"
  ).pipe(g.dest "./dist")

g.task "connect", ->
  q.nfcall(freeport).then (port) ->
    connect.server (
      "port": port
      "livereload": true
    )
g.task "reload", ["compile"], ->
  g.src([
    "./dist/**/*.js"
    "./dist/**/*.css"
    "index.html"
  ]).pipe(connect.reload())

g.task "e2e.conf", ->
  g.src(
    "./etc/protractor.conf.coffee"
  ).pipe(
    coffee()
  ).pipe(g.dest "etc")

browserConfig =
  "chrome": [
    "--capabilities.browserName=chrome"
    "--directConnect"
  ]
  "firefox": [
    "--capabilities.browserName=firefox"
    "--directConnect"
  ]

for browserName, conf of browserConfig
  do (browserName, conf) ->
    g.task "e2e.#{browserName}", ["e2e.conf"], ->
      q.nfcall(freeport).then(
        (port) ->
          baseUrl = "http://localhost:#{port}/"
          connect.server (
            "port": port
            "livereload": false
          )
          g.src(
            "./tests/e2e/**/*.coffee"
          ).pipe(
            protractor(
              "configFile": "./etc/protractor.conf.js"
              "args": ["--baseUrl=#{baseUrl}"].concat conf
            )
          ).on("close", connect.serverClose)
      )

defaultDeps = ["test.server", "connect"] if process.env.mode isnt "CI"

g.task "default", defaultDeps, ->
  if process.env.mode is "CI"
    g.start "compile"
  else
    g.watch [
      "./src/**/*.coffee",
      "./src/**/*.less",
      "./tests/**/*.coffee"
    ], [
      "compile"
      "reload"
    ]
    g.watch [
      "index.html"
    ], [
      "reload"
    ]
    g.watch "./gulpfile.coffee", ["test.syntax"]
