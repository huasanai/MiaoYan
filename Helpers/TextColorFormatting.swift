import Foundation

/// The source edit behind Format > Text Color. Keep line endings intact and
/// never let an inline span cross a Markdown paragraph boundary.
enum TextColorFormatting {
    static let defaultColor = "#FFA500"

    static func normalizedColor(_ value: String) -> String {
        guard value.range(of: "^#[0-9a-fA-F]{6}\\z", options: .regularExpression) != nil else { return defaultColor }
        return value.uppercased()
    }

    static func replacement(for text: String, color: String) -> (text: String, selection: NSRange)? {
        guard let regex = try? NSRegularExpression(pattern: "[^\\r\\n]+") else { return nil }
        let source = text as NSString
        let lines = regex.matches(in: text, range: NSRange(location: 0, length: source.length))
        let ranges = lines.map(\.range).filter { !source.substring(with: $0).trimmingCharacters(in: .whitespaces).isEmpty }
        guard let first = ranges.first, let last = ranges.last else { return nil }
        let opening = "<span style=\"color:\(normalizedColor(color))\">"
        let closing = "</span>"
        let result = NSMutableString(string: text)
        for range in ranges.reversed() {
            result.insert(closing, at: range.upperBound)
            result.insert(opening, at: range.location)
        }
        let start = first.location + (opening as NSString).length
        let addedLength = ranges.count * ((opening as NSString).length + (closing as NSString).length)
        let end = last.upperBound + addedLength - (closing as NSString).length
        return (result as String, NSRange(location: start, length: end - start))
    }
}
