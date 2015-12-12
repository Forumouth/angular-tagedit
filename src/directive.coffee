angular.module("ngTagEditor", [
  "ngTagEditor.controller"
]).directive("ngTagEditor", [
  "$compile"
  (compile) ->
    (
      "restrict": "AC"
      "scope":
        "ngModel": "="
        "tagChange": "&"
        "tagAdd": "&"
        "tagDel": "&"
        "tagStyle": "&"
        "textMaxLength": "="
        "tagMaxLength": "="
        "placeholder": "@"
      "replace": true
      "template": (
        "<ul>
          <li class=\"tag\" data-ng-repeat=\"item in ngModel track by $index\"
            data-ng-style=\"styles[$index]\">
            <span class=\"tag-body\">{{ item }}</span>
            <a href=\"javascript:void(0)\"
              class=\"remove-tag\"
              data-ng-click=\"removeTag($index)\"
            >&times;</a>
          </li>
          <li class=\"editor\">
            <input
              class=\"editor\"
              data-ng-model=\"tmpHolder\"
              data-ng-class=\"editorClass\"
              data-ng-style=\"editorStyle\"
              data-ng-trim=\"false\"
              placeholder=\"{{ placeholder }}\"
              maxlength=\"{{ textMaxLength }}\"
              data-ng-keydown=\"keydown($event)\"
              data-ng-blur=\"blur()\">
          </li>
        </ul>"
      )
      "controller": "ngTagEditorController",
      "link": (scope, element) ->
        scope.__measure_style__ =
          "opacity": 0
          "white-space": "pre"
          "visibility": "hidden"
          "position": "absolute"
        measure = compile(
          angular.element(
            "<span class=\"editor measure\"
              data-ng-style=\"__measure_style__\">
              {{ tmpHolder || placeholder }}
             </span>"
          )
        )(scope)
        element.append measure
        scope.measure = measure[0]
    )
])
