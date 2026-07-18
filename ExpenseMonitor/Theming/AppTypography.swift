//
//  AppTypography.swift
//  ExpenseMonitor
//

import SwiftUI

enum FontWeight {
    case thin, light, regular, medium, semibold, bold
}

protocol AppTypography {
    var largeTitle: Font { get }
    var title: Font { get }
    var title2: Font { get }
    var title2Bold: Font { get }
    var title3: Font { get }
    var title3Bold: Font { get }
    var headline: Font { get }
    var body: Font { get }
    var callout: Font { get }
    var subheadline: Font { get }
    var subheadlineBold: Font { get }
    var footnote: Font { get }
    var caption: Font { get }
    var caption2: Font { get }

    func subheadline(emphasized: Bool) -> Font
    func amount(size: CGFloat) -> Font
    func font(weight: FontWeight, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font
}
