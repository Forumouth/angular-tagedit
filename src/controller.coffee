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
      scope.editorClass.maxTagNumExceeded = false
      value = scope.ngModel.splice index, 1
      callArg = (
        "index": index,
        "value": value
      )
      style = scope.tagChange callArg
      style = scope.tagDel(callArg) or style
      if style is null
        scope.styles.splice index, 1
      else if style
        scope.styles[index] = style
      else
        scope.styles.pop()
    scope.insertTag = (index, value) ->
      if !scope.tagMaxLength or scope.ngModel.length < scope.tagMaxLength
        rest = scope.ngModel.splice index, scope.ngModel.length, value
        scope.ngModel = scope.ngModel.concat rest
        callArg = (
          "index": index,
          "value": value
        )
        scope.styles[index] = scope.tagChange(callArg) or scope.styles[index]
        scope.styles[index] = scope.tagAdd(callArg) or scope.styles[index]
      else
        scope.editorClass.maxTagNumExceeded = true
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
    scope.styles = []
    scope.editorClass =
      'maxTagNumExceeded': scope.ngModel.length >= scope.tagMaxLength
    scope.ngModel.forEach (tag, index) ->
      style = scope.tagStyle (
        "value": tag
        "index": index
      )
      if style
        scope.styles[index] = style
]
