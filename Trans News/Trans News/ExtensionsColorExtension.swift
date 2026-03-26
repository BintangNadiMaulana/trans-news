//
//  ColorExtension.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import UIKit

extension Color {
    // Trans News Brand Colors
    static let transNewsOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let transNewsRed = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let transNewsBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let transNewsDark = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let transNewsCardBg = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let transNewsCardBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
    })
    static let transNewsBorder = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)
    })
    static let transNewsPageBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1.0)
            : UIColor.systemGroupedBackground
    })
    
    // Gradient helpers
    static var transNewsGradient: LinearGradient {
        LinearGradient(
            colors: [transNewsOrange, transNewsRed],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var transNewsBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [transNewsOrange.opacity(0.08), Color(.systemBackground)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var transNewsSoftGradient: LinearGradient {
        LinearGradient(
            colors: [transNewsOrange.opacity(0.15), transNewsRed.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Allow brand colors to be used in ShapeStyle contexts (e.g. .foregroundStyle, .background)
extension ShapeStyle where Self == Color {
    static var transNewsOrange: Color { Color.transNewsOrange }
    static var transNewsRed: Color { Color.transNewsRed }
    static var transNewsBlue: Color { Color.transNewsBlue }
    static var transNewsDark: Color { Color.transNewsDark }
    static var transNewsCardBg: Color { Color.transNewsCardBg }
    static var transNewsCardBackground: Color { Color.transNewsCardBackground }
    static var transNewsBorder: Color { Color.transNewsBorder }
    static var transNewsPageBackground: Color { Color.transNewsPageBackground }
}
