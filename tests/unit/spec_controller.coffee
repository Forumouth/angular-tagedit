describe "Tag Editor controller test", ->
  scope = undefined
  ctrl = undefined
  beforeEach ->
    module "ngTagEditor.controller"
  beforeEach inject [
    "$rootScope"
    "$controller"
    (root, ctrlConstructor) ->
      scope = root.$new()
      scope.tagAdd = sinon.spy()
      scope.tagDel = sinon.spy()
      scope.tagChange = sinon.spy()
      scope.tmpStyle =
        "width": undefined
      ctrl = ctrlConstructor "ngTagEditorController", (
        "$scope": scope
      )
  ]
  afterEach ->
    scope.$destroy()

  it "The controller should be defined", ->
    expect(ctrl).is.not.undefined

  describe "Model integrity check", ->
    describe "Model is a list (but not empty)", ->
      it "Controller shouldn't throw any exceptions", ->
        expect(
          -> scope.$apply(-> scope.ngModel = ["test"])
        ).not.throw Error
    describe "Model is an empty list", ->
      it "Controller shouldn't throw any exceptions", ->
        expect(
          -> scope.$apply(-> scope.ngModel = [])
        ).not.throw Error
    describe "Model is string", ->
      it "Controller shouldn throw any exceptions", ->
        expect(
          -> scope.$apply(-> scope.ngModel = "This is a test")
        ).throw Error

  describe "removeTag calling test", ->
    beforeEach ->
      scope.ngModel = [
        "test1"
        "test2"
        "test3"
        "test4"
      ]
      scope.removeTag 2
    it "scope.ngModel should be proper", ->
      expect(scope.ngModel).eql [
        "test1"
        "test2"
        "test4"
      ]
    it "ngChange should be called once", ->
      expect(scope.tagChange.calledOnce).is.true
    it "ngAdd shouldn't be called", ->
      expect(scope.tagAdd.called).is.false
    it "ngDel should be called once", ->
      expect(scope.tagDel.calledOnce).is.true

  describe "insertTag calling test", ->
    beforeEach ->
      scope.ngModel = [
        "test1"
        "test2"
        "test4"
      ]
      scope.insertTag 2, "test3"
    it "scope.ngModel should be proper", ->
      expect(scope.ngModel).eql [
        "test1"
        "test2"
        "test3"
        "test4"
      ]
    it "ngChange should be called once", ->
      expect(scope.tagChange.calledOnce).is.true
    it "ngAdd should be called once", ->
      expect(scope.tagAdd.calledOnce).is.true
    it "ngDel shouldn't be called", ->
      expect(scope.tagDel.called).is.false

  describe "Calling keydown function", ->
    modelObj = ["test1", "test2", "test3"]
    key = {}
    beforeEach ->
      key.preventDefault = sinon.spy()
      scope.ngModel = angular.copy modelObj
      scope.removeTag = sinon.spy()
      scope.insertTag = sinon.spy()
    describe "with Non-backspace key", ->
      beforeEach ->
        key.keyCode = 46
        scope.keydown key
      it "scope.removeTag shouldn't be called", ->
        expect(scope.removeTag.called).is.false
      it "scope.insertTag shouldn't be called", ->
        expect(scope.insertTag.called).is.false
      it "The default event shouldn't be prevented", ->
        expect(key.preventDefault.called).is.false

    describe "with backspace key", ->
      beforeEach ->
        key.keyCode = 8
        scope.keydown key
      it "The last text should popped", ->
        expect(
          scope.removeTag.calledWithExactly scope.ngModel.length - 1
        ).is.true
      it "scope.insertTag shouldn't be called", ->
        expect(scope.insertTag.called).is.false
      it "scope.tmpHolder should be empty", ->
        expect(scope.tmpHolder).is.empty
      it "The default event should be prevented", ->
        expect(key.preventDefault.called).is.true

    describe "With backspace key containing text in tmpHolder", ->
      beforeEach ->
        key.keyCode = 8
        scope.tmpHolder = "This is a test"
        scope.keydown key
      it "The default event shouldn't be prevented", ->
        expect(key.preventDefault.called).is.false
      it "scope.removeTag shouldn't be called", ->
        expect(scope.removeTag.called).is.false
      it "scope.insertTag shouldn't be called", ->
        expect(scope.insertTag.called).is.false

    describe "with tab key", ->
      describe "Containing text in tmpHolder", ->
        insertedText = undefined
        beforeEach ->
          key.keyCode = 9
          scope.tmpHolder = "This is a test"
          insertedText = angular.copy scope.tmpHolder
          scope.keydown key
        it "tmpHolder should be empty", ->
          expect(scope.tmpHolder).is.empty
        it "The default event should be prevented", ->
          expect(key.preventDefault.called).is.true
        it "scope.removeTag shouldn't be called", ->
          expect(scope.removeTag.called).is.false
        it "scope.insertTag should be called to append tmpHolder", ->
          expect(
            scope.insertTag.calledWithExactly(
              scope.insertTag.length, insertedText
            )
          ).is.false

      describe "Empty text in tmpHolder", ->
        beforeEach ->
          key.keyCode = 9
          scope.keydown key
        it "ngModel shouldn't be changed", ->
          expect(scope.ngModel).is.eql modelObj
        it "The default event should be prevented", ->
          expect(key.preventDefault.called).is.true
        it "scope.removeTag shouldn't be called", ->
          expect(scope.removeTag.called).is.false
        it "scope.insertTag shouldn't be called", ->
          expect(scope.insertTag.called).is.false
