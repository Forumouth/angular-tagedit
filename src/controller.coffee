angular.module("ngTagEditor.controller", [
]).controller "ngTagEditorController", [
  "$scope"
  (scope) ->
    checkModel = (model) ->
      if model not instanceof Array and model
        throw new Error "ngModel should be an array or empty"
      else if not scope.ngModel
        scope.ngModel = []
    scope.$watch "ngModel", checkModel
    checkModel scope.ngModel

    pushText = ->
      scope.insertTag scope.ngModel.length, scope.tmpHolder
      delete scope.tmpHolder
    popText = ->
      scope.removeTag scope.ngModel.length - 1
    scope.removeTag = (index) ->
      maxTagNumIndex = scope.editorClass.indexOf "maxTagNumExceeded"
      if maxTagNumIndex >= 0
        scope.editorClass.splice maxTagNumIndex, 1
      value = scope.ngModel.splice index, 1
      callArg = (
        "index": index,
        "value": value
      )
      scope.ngChange callArg
      scope.ngDel callArg
      delete scope.styles[scope.styles.length - 1]
    scope.insertTag = (index, value) ->
      if !scope.ngMaxTagLength or
          scope.ngModel.length < scope.ngMaxTagLength
        rest = scope.ngModel.splice index, scope.ngModel.length, value
        scope.ngModel = scope.ngModel.concat rest
        callArg = (
          "index": index,
          "value": value
        )
        scope.styles[index] =
          scope.ngChange(callArg) or scope.styles[index]
        scope.styles[index] =
          scope.ngAdd(callArg) or scope.styles[index]
      else if "maxTagNumExceeded" not in scope.editorClass
        scope.editorClass.push "maxTagNumExceeded"
    scope.blur = ->
      if scope.tmpHolder
        pushText()
    scope.keydown = (event) ->
      if event.keyCode is 8
        if not scope.tmpHolder
          popText()
          event.preventDefault()
      else if event.keyCode is 9
        scope.blur()
        event.preventDefault()
    scope.editorClass = []
    scope.styles = {}
    scope.ngModel.forEach (tag, index) ->
      style = scope.tagStyle (
        "tag": tag
        "index": index
      )
      if style
        scope.styles[index] = style
]
