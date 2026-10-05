# Portable Markdown integration

This fork starts at upstream `nodes-app/swift-markdown-engine` **0.14.0**, commit
`5ed9dd8d7eea0c77e93a91462836f4a3ef52424c`. The public product remains
`MarkdownEngine`; Apache-2.0 licensing and upstream history are retained.

MyNotesApp previously vendored the 0.9.0 core (`e0279daf5353a3e35a2a8d314d5d7ae66c652f63`)
as `PortableMarkdownEngine`. Its changes are ported here in incremental commits;
this is a forward port, not replacement of the 0.14.0 source with that old copy.

## Behavior

`MarkdownEditorConfiguration.portableMarkdown` defaults to false. Enable it to
retain literal wiki links/embeds, prevent wiki ID conversion and unsupported
image/LaTeX auto-wrapping, copy exact Markdown without loading assets, and paste
plain Markdown without whitespace/bullet normalization or implicit file reads.
Unregistered extension syntax stays literal using upstream's extension registry.
Register `StrikethroughExtension()` explicitly to retain GFM strikethrough styling.

The fork also provides:

- Native text-view creation and identity-aware editing-availability callbacks;
  Find and formatting guards during marked-text composition.
- UTF-16-safe formatting, task-list commands, portable physical-line transforms
  preserving indentation, trailing whitespace, and line terminators.
- Parser-backed standard link/image discovery, escaped resource punctuation,
  original relative link destinations, and consuming image paste/drop hooks.
  Hosts own scoped asset access and asynchronous imports.
- Runtime reading-width/spelling synchronization, narrow-column fitting,
  appearance refresh, caret reveal, and explicit viewport observer lifetimes.
- Optional `sharedUndoManager`, `canEditSource`, and `synchronizeSource(_:in:)`
  for a host-owned document shared by multiple editor views. Committed edits
  reach the source binding synchronously; peer selection is restored after the
  upstream attributed-storage rebuild. Composition remains local until committed.
- Selection preservation for clean external reloads and presentation-only
  rebuilds; stale native undo clears on reload unless the host owns shared undo.

## Port decisions

The original app commits map to the following groups in this fork's history:

| MyNotesApp commits | Port group |
| --- | --- |
| `249e1a4` | Portable source and clipboard preservation |
| `1381cd9`, `4386983`, `73a82bd` | Reload selection, native Find, formatting |
| `8cc515e`, `dcf3ed2`, `c00d981` | Resources, standard links, image input |
| `ea25524`, `cc601e1`, `8fa830e`, `7807e6e` | Layout, caret, performance, lifetime |
| `5ae1d45` | Shared source and document undo |

Upstream's newer attribute-preserving formatting paths remain for legacy callers;
portable line formatting uses the app's source-preserving behavior. Existing
upstream scroll restoration, table resize handling, parse caches, and native
mutation callbacks remain intact. Its backtick-count initialization supersedes
our older whole-string count. Optional code-overlay geometry is skipped only
after updating upstream's parsed-token cache. Range indexes retain our styling
optimization without reverting upstream's parser cost improvements.

Resource parsing retains upstream's nested link-label support and ordered range
indexes. A per-input comparison with 0.14.0 found 15 changed trees in the existing
4,000-input corpus, all escaped image alt text recognized as images instead of
literal `!` plus a link. The reviewed fingerprint and focused escaped-resource
assertions record that intentional semantic change.

## Validation and updates

Use the checked-in Package.resolved for package tests. The embedding repository's
submodule gitlink pins this fork; its Xcode Package.resolved pins optional package
dependencies. Only the core is linked into MyNotesApp.

Run focused Swift Testing suites for changed engine behavior, then MyNotesApp's
native preservation, formatting, reload, composition, shared-document, layout,
and filesystem tests through its Development plan. Relevant XCUITest workflows
and screenshot review validate macOS appearance and native commands. Keep source
files authoritative; never infer byte-preservation from parser serialization.

MyNotesApp's `docs/IMPLEMENTATION_STATUS.md` records migration validation results
and limitations. Upstream performance numbers are not measurements of the host.
