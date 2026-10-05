import Testing
@testable import MarkdownEngine

struct PortableResourceTests {
    @Test func escapedResourcesExcludeLiteralAndCodeSyntax() {
        let source = #"![A \[draft\]](a\(1\).png)"# + "\n`![code](code.png)`\n\n```md\n![fenced](fenced.png)\n```\n![[literal.png|320]]\n"
        #expect(MarkdownSourceResources.imageReferences(in: source) == [#"a\(1\).png"#])
    }

    @Test func portableLinkDestinationRemainsRelative() {
        let source = #"[A \[draft\]](../a\(1\).md)"#
        #expect(MarkdownSourceResources.linkDestination(in: source, atUTF16: 2) == #"../a\(1\).md"#)
    }
}
