import AppKit

extension NativeTextViewWrapper {
    /// Reflect a committed portable source edit without generating another edit
    /// or replacing the native view. Each view retains its own styled storage.
    public static func synchronizeSource(_ source: String, in view: NSTextView) {
        guard let coordinator = view.delegate as? NativeTextViewCoordinator,
              coordinator.configuration.portableMarkdown, !view.hasMarkedText(),
              view.string != source, let storage = view.textStorage else { return }
        let old = view.string as NSString
        let new = source as NSString
        let before = Array(view.string)
        let after = Array(source)
        var prefix = 0
        while prefix < min(before.count, after.count), before[prefix] == after[prefix] { prefix += 1 }
        var suffix = 0
        while suffix < min(before.count, after.count) - prefix,
              before[before.count - suffix - 1] == after[after.count - suffix - 1] { suffix += 1 }
        let start = String(before.prefix(prefix)).utf16.count
        let tail = String(before.suffix(suffix)).utf16.count
        let range = NSRange(location: start, length: old.length - start - tail)
        let replacement = new.substring(with: NSRange(location: start, length: new.length - start - tail))
        let delta = new.length - old.length
        let selection = view.selectedRange()
        let location: Int
        let length: Int
        if NSMaxRange(selection) <= start { location = selection.location; length = selection.length }
        else if selection.location >= NSMaxRange(range) { location = selection.location + delta; length = selection.length }
        else { location = min(start + replacement.utf16.count, new.length); length = 0 }
        let scroll = view.enclosingScrollView?.contentView.bounds.origin
        storage.replaceCharacters(in: range, with: replacement)
        view.setSelectedRange(NSRange(location: location, length: length))
        coordinator.lastSyncedText = source
        coordinator.rebuildTextStorageAndStyle(view, from: source)
        if let native = view as? NativeTextView, let scroller = view.enclosingScrollView {
            native.recalcOverscroll(for: scroller)
            native.refreshPlaceholderVisibility()
            if let scroll { scroller.contentView.scroll(to: scroll); scroller.reflectScrolledClipView(scroller.contentView) }
        }
    }
}
