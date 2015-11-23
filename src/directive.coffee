angular.module("ngTagEditor", [
  "ngTagEditor.controller"
]).directive("ngTagEditor", [
  ->
    (
      "restrict": "AC"
      "scope":
        "ngModel": "="
        "ngChange": "&"
        "ngAdd": "&"
        "ngDel": "&"
        "tagStyle": "&"
        "ngMaxTextLength": "="
        "ngMaxTagLength": "="
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
              placeholder=\"{{ placeholder }}\"
              maxlength=\"{{ ngMaxTextLength }}\"
              size=\"{{tmpHolder.length || placeholder.length || 10}}\"
              data-ng-keydown=\"keydown($event)\"
              data-ng-blur=\"blur()\">
          </li>
        </ul>"
      )
      "controller": "ngTagEditorController"
    )
])
