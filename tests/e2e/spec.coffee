chai = require "chai"
chai.use require "chai-as-promised"
expect = chai.expect
parseClass = require("./parser").parseClass

describe "TagEditor E2E tests", ->
  before ->
    browser.get "/"

  describe "Tag compilation check", ->
    it "textarea shouldn't be present, because the directive replaces it.", ->
      textarea = element(By.model "tags")
      expect(textarea.getTagName()).not.eventually.equal "textarea"
    it "3 li tags should be displayed with tag class", ->
      li = element(By.model "tags").all(By.css "li.tag")
      li.isDisplayed().then (isDisplayed) ->
        expect(isDisplayed.every (item) -> item is true).is.true
      expect(li.count()).eventually.equal 3
    it "1 input tag should be displayed with editor class", ->
      input = element(
        By.model "tags"
      ).element(
        By.css "input.editor"
      )
      expect(input.isDisplayed()).is.eventually.true
      expect(input.isEnabled()).is.eventually.true

  describe "Tag manipulation check", ->
    input = undefined
    items = undefined
    before ->
      tags = element(By.model "tags")
      input = tags.element(By.css "input.editor")
      items = tags.all(
        By.css "li.tag"
      ).all(
        By.css "span.tag-body"
      )

    describe "Type \"test4\" and tabkey", ->
      before ->
        input.sendKeys "test4#{protractor.Key.TAB}"
      it "Then number of the tags should be proper", ->
        expect(items.count()).is.eventually.equal 4
      it "And tag should be appended", ->
        expect(items.last().getText()).eventually.equal "test4"

    describe "Tries to remove the last tag from the editor", ->
      before ->
        input.sendKeys protractor.Key.BACK_SPACE
      it "Then number of the tags should be proper", ->
        expect(items.count()).is.eventually.equal 3
      it "And last tag should be deleted", ->
        expect(items.last().getText()).eventually.equal "test3"

    describe "Remove first tag by clicking x", ->
      before ->
        items.first().element(
          By.xpath("..")
        ).element(By.css "a.remove-tag").click()
      it "Then number of the tags should be proper", ->
        expect(items.count()).is.eventually.equal 2
      it "And first tag should be deleted", ->
        expect(items.first().getText()).eventually.equal "test2"

    describe "Illegal Cases", ->
      directive = undefined
      before ->
        directive = element By.className "ng-tag-editor"
      describe "Type tags more than # of appreciated tags", ->
        tagLim = undefined
        before ->
          directive.getAttribute("data-ng-max-tag-length").then (value) ->
            tagLim = parseInt value
            for textNum in [4..(tagLim + 3)]
              do (textNum) ->
                input.sendKeys "test#{textNum}#{protractor.Key.TAB}"
        it "The editor should have maxTagNumExceeded class", ->
          # This seems to be a bug of selenium that doesn't wait until the
          # class is changed.
          browser.wait(
            (->
              input.getAttribute(
                "class"
              ).then(parseClass).then(
                (classList) ->
                  ("maxTagNumExceeded" in classList)
              )
            )
          ).then (contains) -> expect(contains).is.true
        it "The edito should be empty", ->
          expect(input.getAttribute "value").is.eventually.empty
        it "The tags should be proper", ->
          expect(
            items.getText()
          ).eventually.eql ("test#{item}" for item in [2..11])

      describe "Recover maxTagNumExceeded class", ->
        describe "by typing backspace to the editor", ->
          before ->
            input.sendKeys protractor.Key.BACK_SPACE
          it "The editor shouldn't have maxTagNumExceeded", ->
            browser.wait(
              (->
                input.getAttribute(
                  "class"
                ).then(parseClass).then(
                  (classList) ->
                    ("maxTagNumExceeded" not in classList)
                )
              )
            ).then (contains) -> expect(contains).is.true
        describe "by clicking a tag", ->
          before ->
            input.sendKeys "testA#{protractor.Key.TAB}"
            input.sendKeys "testB#{protractor.Key.TAB}"
            browser.wait(
              (->
                input.getAttribute(
                  "class"
                ).then(parseClass).then(
                  (classList) ->
                    ("maxTagNumExceeded" in classList)
                )
              )
            ).then (contains) -> expect(contains).is.true
            items.first().element(
              By.xpath("..")
            ).element(By.css "a.remove-tag").click()
          it "The editor shouldn't have maxTagNumExceeded", ->
            browser.wait(
              (->
                input.getAttribute(
                  "class"
                ).then(parseClass).then(
                  (classList) ->
                    ("maxTagNumExceeded" not in classList)
                )
              )
            ).then (contains) -> expect(contains).is.true
