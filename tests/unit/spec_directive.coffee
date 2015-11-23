describe "angular-tagEditor unit testing", ->
  html = undefined
  compiled = undefined
  scope = undefined
  beforeEach ->
    module "ngTagEditor"

  beforeEach ->
    html = angular.element(
      "<textarea data-ng-tag-editor data-ng-model=\"data.tags\"></textarea>"
    )

  beforeEach inject [
    "$rootScope",
    "$compile"
    (root, compile) ->
      scope = root.$new()
      scope.data =
        "tags": ["test"]
      scope.$apply ->
        compiled = compile(html)(scope)
  ]
  afterEach -> scope.$destroy()

  it "The directive should be compiled properly", ->
    expect(compiled.get(0).tagName.toLowerCase()).is.equal "ul"
