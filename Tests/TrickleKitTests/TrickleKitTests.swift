import XCTest
import ChocofordEssentials
@testable import TrickleCore
@testable import TrickleEditor
@testable import TrickleAWS


final class TrickleKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //        XCTAssertEqual(TrickleKit().text, "Hello, World!")
    }
    
    
    // MARK: - Markdown parse tests
    func testMarkdownToHeadingBlocks() throws {
        //        let testString: String = {
        //return """
        //# Heading 1
        //## Heading 2
        //
        //### Heading 3
        //
        //
        //#### Heading 4
        //##### Heading 5
        //###### Heading 6
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //
        //        XCTAssertEqual(blocks.count, 7)
        //        XCTAssertEqual(blocks[0].type, TrickleBlock.BlockType.h1)
        //        XCTAssertEqual(blocks[0].elements?.count, 1)
        //        XCTAssertEqual(blocks[0].blocks, nil)
        //        XCTAssertEqual(blocks[1].type, TrickleBlock.BlockType.h2)
        //        XCTAssertEqual(blocks[2].type, TrickleBlock.BlockType.h3)
        //        XCTAssertEqual(blocks[3].type, TrickleBlock.BlockType.richText)
        //        XCTAssertEqual(blocks[4].type, TrickleBlock.BlockType.h4)
        //        XCTAssertEqual(blocks[5].type, TrickleBlock.BlockType.h5)
        //        XCTAssertEqual(blocks[6].type, TrickleBlock.BlockType.h6)
        //    }
        //
        //    func testMarkdownToListBlocks() throws {
        //        let testString: String = {
        //return """
        //* List 1
        //* List 2
        //3
        //* List 4
        //
        //* List 5
        //
        //
        //* List 6
        //
        //Not a List
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //
        //        XCTAssertEqual(blocks.count, 6)
        //        XCTAssertEqual(blocks[0].type, TrickleBlock.BlockType.list)
        //        XCTAssertEqual(blocks[1].type, TrickleBlock.BlockType.list)
        //        XCTAssertEqual(blocks[2].type, TrickleBlock.BlockType.list)
        //        XCTAssertEqual(blocks[3].type, TrickleBlock.BlockType.list)
        //        XCTAssertEqual(blocks[4].type, TrickleBlock.BlockType.list)
        //        XCTAssertEqual(blocks[5].type, TrickleBlock.BlockType.richText)
        //    }
        //
        //    func testMarkdownToCodeBlock() throws {
        //        let testString: String = {
        //return """
        //```swift
        //final class TrickleKitTests: XCTestCase {
        //    func testExample() throws {
        //        // This is an example of a functional test case.
        //        // Use XCTAssert and related functions to verify your tests produce the correct
        //        // results.
        //        XCTAssertEqual(TrickleKit().text, "Hello, World!")
        //    }
        //}
        //```
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //        dump(blocks)
        //
        //        XCTAssertEqual(blocks.count, 1)
        //        XCTAssertEqual(blocks[0].type, TrickleBlock.BlockType.code)
        //        XCTAssertEqual(blocks[0].userDefinedValue, TrickleBlock.UserDefinedValue.code(.init(language: "swift")))
        //
        //    }
        //
        //    func testMarkdownToNumberedListBlocks() throws {
        //        let testString: String = {
        //return """
        //1. list 1
        //2. list 2
        //list --
        //3. list 3
        //
        //abc
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //        dump(blocks)
        //
        //        XCTAssertEqual(blocks.count, 4)
        //        XCTAssertEqual(blocks[0].type, TrickleBlock.BlockType.numberedList)
        //
        //
        //    }
        //
        //    func testMarkdownToQuoteBlock() throws {
        //        let testString: String = {
        //return """
        //> Quote 1
        //>
        //> Quote 2
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //        dump(blocks)
        //
        ////        XCTAssertEqual(blocks.count, 1)
        ////        XCTAssertEqual(blocks[0].type, .code)
        ////        XCTAssertEqual(blocks[0].userDefinedValue, .code(.init(language: "swift")))
        //
        //    }
        //
        //    func testMarkdownToBlock() throws {
        //        let markdownTest: String = {
        //            return """
        //# Heading 1
        //## Heading 2
        //
        //### Heading 3
        //text line 1
        //text line 2
        //
        //text line 3
        //
        //
        //text line 4
        //
        //* list 1
        //*   list 2
        //*   list 3
        //
        //1.  Red
        //2.     Green
        //3.    Blue
        //
        //- [ ] a task list item
        //- [ ] list syntax required
        //- [ ] normal **formatting**, @mentions, #1234 refs
        //- [ ] incomplete
        //- [x] completed
        //
        //
        //syntax highlighting:
        //```ruby
        //require 'redcarpet'
        //markdown = Redcarpet.new("Hello World!")
        //puts markdown.to_html
        //```
        //
        //In the markdown source file, the math block is a *LaTeX* expression wrapped by a pair of ‘$$’ marks:
        //
        //$$
        //ABC
        //$$
        //
        //You can find more details [here](https://support.typora.io/Math/).
        //
        //
        //| First Header  | Second Header |
        //| ------------- | ------------- |
        //| Content Cell  | Content Cell  |
        //| Content Cell  | Content Cell  |
        //
        //[^footnote]: Here is the *text* of the **footnote**.
        //
        //------
        //
        //Typora now supports [YAML Front Matter](http://jekyllrb.com/docs/frontmatter/). Input `---` at the top of the article and then press `Return` to introduce a metadata block. Alternatively, you can insert a metadata block from the top menu of Typora.
        //
        //
        //Input `[toc]` and press the `Return` key. This will create a  “Table of Contents” section. The TOC extracts all headers from the document, and its contents are updated automatically as you add to the document.
        //
        //## Span Elements
        //
        //Span elements will be parsed and rendered right after typing. Moving the cursor in middle of those span elements will expand those elements into markdown source. Below is an explanation of the syntax for each span element.
        //
        //### Links
        //
        //
        //This is [an example](http://example.com/ "Title") inline link.
        //
        //[This link](http://example.net/) has no title attribute.
        //
        //will produce:
        //
        //This is [an example](http://example.com/ "Title") inline link. (`<p>This is <a href="http://example.com/" title="Title">`)
        //
        //[This link](http://example.net/) has no title attribute. (`<p><a href="http://example.net/">This link</a> has no`)
        //
        //#### Internal Links
        //
        //**You can set the href to headers**, which will create a bookmark that allow you to jump to that section after clicking. For example:
        //
        //Command(on Windows: Ctrl) + Click [This link](#block-elements) will jump to header `Block Elements`. To see how to write that, please move cursor or click that link with `⌘` key pressed to expand the element into markdown source.
        //
        //#### Reference Links
        //
        //Reference-style links use a second set of square brackets, inside which you place a label of your choosing to identify the link:
        //
        //``` markdown
        //This is [an example][id] reference-style link.
        //
        //Then, anywhere in the document, you define your link label on a line by itself like this:
        //
        //[id]: http://example.com/  "Optional Title Here"
        //```
        //
        //In Typora, they will be rendered like so:
        //
        //This is [an example][id] reference-style link.
        //
        //[id]: http://example.com/    "Optional Title Here"
        //
        //The implicit link name shortcut allows you to omit the name of the link, in which case the link text itself is used as the name. Just use an empty set of square brackets — for example, to link the word “Google” to the google.com web site, you could simply write:
        //
        //``` markdown
        //[Google][]
        //And then define the link:
        //
        //[Google]: http://google.com/
        //```
        //
        //In Typora, clicking the link will expand it for editing, and command+click will open the hyperlink in your web browser.
        //
        //### URLs
        //
        //Typora allows you to insert URLs as links, wrapped by `<`brackets`>`.
        //
        //`<i@typora.io>` becomes <i@typora.io>.
        //
        //Typora will also automatically link standard URLs. e.g: www.google.com.
        //
        //### Images
        //
        //Images have similar syntax as links, but they require an additional `!` char before the start of the link. The syntax for inserting an image looks like this:
        //
        //``` markdown
        //![Alt text](/path/to/img.jpg)
        //
        //![Alt text](/path/to/img.jpg "Optional title")
        //```
        //
        //You are able to use drag & drop to insert an image from an image file or your web browser. You can modify the markdown source code by clicking on the image. A relative path will be used if the image that is added using drag & drop is in same directory or sub-directory as the document you're currently editing.
        //
        //If you’re using markdown for building websites, you may specify a URL prefix for the image preview on your local computer with property `typora-root-url` in YAML Front Matters. For example, input `typora-root-url:/User/Abner/Website/typora.io/` in YAML Front Matters, and then `![alt](/blog/img/test.png)` will be treated as `![alt](file:///User/Abner/Website/typora.io/blog/img/test.png)` in Typora.
        //
        //You can find more details [here](https://support.typora.io/Images/).
        //
        //### Emphasis
        //
        //Markdown treats asterisks (`*`) and underscores (`_`) as indicators of emphasis. Text wrapped with one `*` or `_` will be wrapped with an HTML `<em>` tag. E.g:
        //
        //``` markdown
        //*single asterisks*
        //
        //_single underscores_
        //```
        //
        //output:
        //
        //*single asterisks*
        //
        //_single underscores_
        //
        //GFM will ignore underscores in words, which is commonly used in code and names, like this:
        //
        //> wow_great_stuff
        //>
        //> do_this_and_do_that_and_another_thing.
        //
        //To produce a literal asterisk or underscore at a position where it would otherwise be used as an emphasis delimiter, you can backslash escape it:
        //
        //``` markdown
        //\\*this text is surrounded by literal asterisks\\*
        //```
        //
        //Typora recommends using the `*` symbol.
        //
        //### Strong
        //
        //A double `*` or `_` will cause its enclosed contents to be wrapped with an HTML `<strong>` tag, e.g:
        //
        //``` markdown
        //**double asterisks**
        //
        //__double underscores__
        //```
        //
        //output:
        //
        //**double asterisks**
        //
        //__double underscores__
        //
        //Typora recommends using the `**` symbol.
        //
        //### Code
        //
        //To indicate an inline span of code, wrap it with backtick quotes (`). Unlike a pre-formatted code block, a code span indicates code within a normal paragraph. For example:
        //
        //``` markdown
        //Use the `printf()` function.
        //```
        //
        //will produce:
        //
        //Use the `printf()` function.
        //
        //### Strikethrough
        //
        //GFM adds syntax to create strikethrough text, which is missing from standard Markdown.
        //
        //`~~Mistaken text.~~` becomes ~~Mistaken text.~~
        //
        //### Underlines
        //
        //Underline is powered by raw HTML.
        //
        //`<u>Underline</u>` becomes <u>Underline</u>.
        //
        //### Emoji :smile:
        //
        //Input emoji with syntax `:smile:`.
        //
        //User can trigger auto-complete suggestions for emoji by pressing `ESC` key, or trigger it automatically after enabling it on preference panel. Also, inputting UTF-8 emoji characters directly is also supported by going to `Edit` -> `Emoji & Symbols` in the menu bar (macOS).
        //
        //### Inline Math
        //
        //To use this feature, please enable it first in the `Preference` Panel -> `Markdown` Tab. Then, use `$` to wrap a TeX command. For example: `$\\lim_{x \\to \\infty} \\exp(-x) = 0$` will be rendered as LaTeX command.
        //
        //To trigger inline preview for inline math: input “$”, then press the `ESC` key, then input a TeX command.
        //
        //You can find more details [here](https://support.typora.io/Math/).
        //
        //### Subscript
        //
        //To use this feature, please enable it first in the `Preference` Panel -> `Markdown` Tab. Then, use `~` to wrap subscript content. For example: `H~2~O`, `X~long\\ text~`/
        //
        //### Superscript
        //
        //To use this feature, please enable it first in the `Preference` Panel -> `Markdown` Tab. Then, use `^` to wrap superscript content. For example: `X^2^`.
        //
        //### Highlight
        //
        //To use this feature, please enable it first in the `Preference` Panel -> `Markdown` Tab. Then, use `==` to wrap highlight content. For example: `==highlight==`.
        //
        //## HTML
        //
        //You can use HTML to style content what pure Markdown does not support. For example, use `<span style="color:red">this text is red</span>` to add text with red color.
        //
        //### Embed Contents
        //
        //Some websites provide iframe-based embed code which you can also paste into Typora. For example:
        //
        //```Markdown
        //<iframe height='265' scrolling='no' title='Fancy Animated SVG Menu' src='http://codepen.io/jeangontijo/embed/OxVywj/?height=265&theme-id=0&default-tab=css,result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'></iframe>
        //```
        //
        //### Video
        //
        //You can use the `<video>` HTML tag to embed videos. For example:
        //
        //```Markdown
        //<video src="xxx.mp4" />
        //```
        //
        //### Other HTML Support
        //
        //You can find more details [here](https://support.typora.io/HTML/).
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: markdownTest)
        //        dump(blocks)
        ////        XCTAssertEqual(TrickleKit().text, "Hello, World!")
        //    }
        //
        //    func testMarkdownToElements() throws {
        //        let testString: String = {
        //return """
        //Start, **Bold**, [link](https://www.google.com), *italic*, `inline-code`
        //"""
        //        }()
        //
        //        let blocks = TrickleEditorParser.formBlock(string: testString)
        //        dump(blocks)
    }
    
    // MARK: - Test parse preview
    //    func testParsePreviewData() throws {
    //        let workspaces: [WorkspaceData] = load("workspaces.json")
    //        
    //        XCTAssertEqual(blocks.count, 1)
    //    }
    
    func testTrickleAWS() async throws {
        let data = try Data(contentsOf: URL(string: "file:///Users/chocoford/Downloads/trickle logo.png")!)
        let res = try await TrickleAWSProvider.shared.uploadFile(data: data, type: .workspaceLogo("test"), fileExtension: "png")
        print(res)
    }
}
