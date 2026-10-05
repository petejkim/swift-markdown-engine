import AppKit
import Testing
@testable import MarkdownEngine

struct PortableSourceTests {
    @Test(arguments: ["[[Note|Alias]]", "```\n[[Note|Alias]]\n```\n", "![[image.png|320]]\r\n\r\n", "---\ncustom: value\n---\n==literal==\n"])
    func literalRoundTrip(source: String) {
        let display = WikiLinkService.makeDisplayState(from: source, preserveSource: true)
        #expect(display.display == source)
        #expect(display.metadata.isEmpty)
        let storage = WikiLinkService.makeStorageState(from: display.display, existingMetadata: display.metadata,
                                                       textStorage: nil, preserveSource: true)
        #expect(storage.storage == source)
        #expect(storage.metadata.isEmpty)
    }

    @Test func legacyTransformationRemainsOptOut() {
        #expect(WikiLinkService.makeDisplayState(from: "[[Note|id]]").display == "[[Note]]")
    }
}
