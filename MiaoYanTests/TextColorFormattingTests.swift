import XCTest

@testable import MiaoYan

final class TextColorFormattingTests: XCTestCase {
    func testWrapsTextAndKeepsUnicodeSelected() throws {
        for text in ["orange", "橙色文字", "👨‍👩‍👧‍👦 cafe\u{0301} 𠮷"] {
            let edit = try XCTUnwrap(TextColorFormatting.replacement(for: text, color: "#FFA500"))
            XCTAssertEqual(edit.text, "<span style=\"color:#FFA500\">\(text)</span>")
            XCTAssertEqual((edit.text as NSString).substring(with: edit.selection), text)
        }
    }

    func testPreservesLineEndingsAndBlankParagraphs() throws {
        for newline in ["\n", "\r\n", "\r"] {
            let text = "first\(newline)  \(newline)第二段😀\(newline)"
            let edit = try XCTUnwrap(TextColorFormatting.replacement(for: text, color: "#123abc"))
            XCTAssertEqual(edit.text, "<span style=\"color:#123ABC\">first</span>\(newline)  \(newline)<span style=\"color:#123ABC\">第二段😀</span>\(newline)")
            XCTAssertTrue((edit.text as NSString).substring(with: edit.selection).hasPrefix("first"))
            XCTAssertTrue((edit.text as NSString).substring(with: edit.selection).hasSuffix("第二段😀"))
        }
    }

    func testEmptyAndBlankSelectionsProduceNoEdit() {
        for text in ["", " ", "\t", "\n\r\n", " \n \n"] {
            XCTAssertNil(TextColorFormatting.replacement(for: text, color: "#FFA500"))
        }
    }

    func testColorIsNormalizedAndUnsafeValuesFallBackToOrange() throws {
        XCTAssertEqual(TextColorFormatting.normalizedColor("#12abef"), "#12ABEF")
        for color in ["orange", "#FFF", "#GG0000", "#00000000", "#FF0000\n", "red; background:black", "\" onclick=\"alert(1)"] {
            XCTAssertEqual(TextColorFormatting.normalizedColor(color), "#FFA500", color)
            let edit = try XCTUnwrap(TextColorFormatting.replacement(for: "text", color: color))
            XCTAssertEqual(edit.text, "<span style=\"color:#FFA500\">text</span>")
        }
    }

    func testKeepsMarkdownAndHTMLContentVerbatim() throws {
        let text = "**bold** & <em>italic</em> [link](https://example.com)"
        let edit = try XCTUnwrap(TextColorFormatting.replacement(for: text, color: "#008000"))
        XCTAssertEqual((edit.text as NSString).substring(with: edit.selection), text)
    }
}
