q = require "q"
exports.parseClass = (str) ->
  defer = q.defer()
  defer.resolve str.split " "
  defer.promise
