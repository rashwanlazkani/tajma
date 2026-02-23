import SwiftUI

enum TajmaTheme {
    // MARK: - Colors
    static let brandRed = Color(red: 231/255, green: 63/255, blue: 87/255)
    static let rowEven = Color(red: 246/255, green: 246/255, blue: 246/255)
    static let rowOdd = Color(red: 249/255, green: 249/255, blue: 249/255)
    static let tableBackground = Color(red: 249/255, green: 249/255, blue: 249/255)
    static let separator = Color(red: 219/255, green: 219/255, blue: 219/255)
    static let primaryText = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let secondaryText = Color(red: 0.58, green: 0.58, blue: 0.58)
    static let menuText = Color(red: 0.2, green: 0.2, blue: 0.341)
    static let linesBackground = Color(red: 246/255, green: 246/255, blue: 246/255)

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // MARK: - Sizes
    static let rowHeight: CGFloat = 44
    static let headerRowHeight: CGFloat = 28
    static let navBarHeight: CGFloat = 47
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xff00) >> 8) / 255.0
        let b = Double(rgbValue & 0xff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
