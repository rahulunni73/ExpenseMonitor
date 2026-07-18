//
//  HelveticaNeueTypography.swift
//  ExpenseMonitor
//

import SwiftUI

struct HelveticaNeueTypography: AppTypography {
    private func postScriptName(for weight: FontWeight) -> String {
        switch weight {
        case .thin: return "HelveticaNeue-Thin"
        case .light: return "HelveticaNeue-Light"
        case .regular: return "HelveticaNeue-Roman"
        case .medium: return "HelveticaNeue-Medium"
        case .semibold: return "HelveticaNeue-Medium" // no Semibold face available — Medium is the closest match
        case .bold: return "HelveticaNeue-Bold"
        }
    }

    func font(weight: FontWeight = .regular, size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .custom(postScriptName(for: weight), size: size, relativeTo: textStyle)
    }

    var largeTitle: Font { font(size: 34, relativeTo: .largeTitle) }
    var title: Font { font(size: 28, relativeTo: .title) }
    var title2: Font { font(size: 22, relativeTo: .title2) }
    var title2Bold: Font { font(weight: .bold, size: 22, relativeTo: .title2) }
    var title3: Font { font(size: 20, relativeTo: .title3) }
    var title3Bold: Font { font(weight: .bold, size: 20, relativeTo: .title3) }
    var headline: Font { font(weight: .medium, size: 17, relativeTo: .headline) } // no Semibold face available
    var body: Font { font(size: 17, relativeTo: .body) }
    var callout: Font { font(size: 16, relativeTo: .callout) }
    var subheadline: Font { font(size: 15, relativeTo: .subheadline) }
    var subheadlineBold: Font { font(weight: .bold, size: 15, relativeTo: .subheadline) }
    var footnote: Font { font(size: 13, relativeTo: .footnote) }
    var caption: Font { font(size: 12, relativeTo: .caption) }
    var caption2: Font { font(size: 11, relativeTo: .caption2) }

    func subheadline(emphasized: Bool) -> Font {
        emphasized ? subheadlineBold : subheadline
    }

    func amount(size: CGFloat) -> Font {
        font(weight: .bold, size: size, relativeTo: .largeTitle)
    }
}
