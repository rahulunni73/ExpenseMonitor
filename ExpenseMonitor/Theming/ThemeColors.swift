//
//  ThemeColors.swift
//  ExpenseMonitor
//

import SwiftUI

struct ThemeColors: Equatable {
    let accent: Color
    let income: Color
    let expense: Color
    let background: Color
    let backgroundTop: Color
    let surface: Color
    let surfaceSecondary: Color

    /// A top-to-bottom wash from `backgroundTop` into `background`, for screens that want
    /// one continuous blended backdrop (e.g. a header fading into the content below it)
    /// instead of the flat `background` fill used everywhere else.
    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, background], startPoint: .top, endPoint: .bottom)
    }
}
