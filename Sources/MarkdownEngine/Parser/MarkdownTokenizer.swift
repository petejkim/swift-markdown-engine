//
//  MarkdownTokenizer.swift
//  MarkdownEngine
//
//  Created by Luca Chen on 18.02.26.
//

// The token namespace. Tokens are produced by `parseTokensViaAST`
// (`BlockScopedTokenizer`): block structure + block-level tokens come from
// `BlockParser` + `BlockLevelTokenizer` (hand scanners, no regex), inline
// tokens from the AST (`InlineParser` → `InlineASTAdapter`). This file keeps
// only the code-block language helper.
import Foundation

/// Source-only resource discovery for embedders. Reuses the editor parser so
/// code spans/fences and literal wiki embeds never request local image reads.
public enum MarkdownSourceResources {
    public static func linkDestination(in source: String, atUTF16 location: Int) -> String? {
        let text = source as NSString
        guard location >= 0, location < text.length,
              let token = MarkdownTokenizer.parseTokensViaAST(in: source).first(where: {
                  $0.kind == .link && NSLocationInRange(location, $0.range)
              }), token.markerRanges.count >= 4 else { return nil }
        let start = NSMaxRange(token.markerRanges[2])
        let end = token.markerRanges[3].location
        guard end > start, end <= text.length else { return nil }
        return text.substring(with: NSRange(location: start, length: end - start))
    }

    public static func imageReferences(in source: String) -> [String] {
        let text = source as NSString
        var seen: Set<String> = []
        var references: [String] = []
        for token in MarkdownTokenizer.parseTokensViaAST(in: source) where token.kind == .imageLink {
            guard token.markerRanges.count >= 4 else { continue }
            let start = NSMaxRange(token.markerRanges[2])
            let end = token.markerRanges[3].location
            guard end > start, end <= text.length else { continue }
            let reference = text.substring(with: NSRange(location: start, length: end - start))
            if seen.insert(reference).inserted { references.append(reference) }
        }
        return references
    }
}

// MARK: - Tokenizer
enum MarkdownTokenizer {

    // MARK: - Code Block Helpers

    static func extractLanguage(from token: MarkdownToken, in text: String) -> String? {
        guard token.kind == .codeBlock,
              let openingMarker = token.markerRanges.first,
              openingMarker.length > 4 else { return nil }

        let nsText = text as NSString
        let langRange = NSRange(location: openingMarker.location + 3, length: openingMarker.length - 4)

        guard langRange.location + langRange.length <= nsText.length else { return nil }

        let langString = nsText.substring(with: langRange).trimmingCharacters(in: .whitespacesAndNewlines)
        return langString.isEmpty ? nil : langString
    }
}
