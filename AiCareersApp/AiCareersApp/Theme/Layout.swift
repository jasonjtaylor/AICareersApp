//
//  Layout.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI

enum Layout {
    // MARK: - Spacing

    static let paddingXS: CGFloat = 4
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let paddingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24

    // MARK: - Card Dimensions

    static let cardHeight: CGFloat = 200
    static let cardWidth: CGFloat = 160
    static let cardPadding: CGFloat = 16

    // MARK: - Button Heights

    static let buttonHeight: CGFloat = 44
    static let buttonHeightLarge: CGFloat = 52
    static let buttonHeightSmall: CGFloat = 36

    // MARK: - Icon Sizes

    static let iconS: CGFloat = 16
    static let iconM: CGFloat = 24
    static let iconL: CGFloat = 32
    static let iconXL: CGFloat = 48

    // MARK: - Power Meter

    static let powerMeterHeight: CGFloat = 8
    static let powerMeterWidth: CGFloat = 60

    // MARK: - XP Bar

    static let xpBarHeight: CGFloat = 12
    static let xpBarWidth: CGFloat = 200

    // MARK: - Badge

    static let badgeSize: CGFloat = 40
    static let badgeSizeLarge: CGFloat = 60
}

// MARK: - Shadow Styles

extension View {
    func dreamShadow() -> some View {
        shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    func dreamShadowLarge() -> some View {
        shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    func dreamShadowSmall() -> some View {
        shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Card Styles

extension View {
    func dreamCard() -> some View {
        background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusL)
            .dreamShadow()
    }

    func dreamCardLarge() -> some View {
        background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusXL)
            .dreamShadowLarge()
    }
}

// MARK: - Button Styles

extension View {
    func dreamButton(style: DreamButtonStyle = .primary) -> some View {
        frame(height: Layout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(style.background)
            .foregroundColor(style.foregroundColor)
            .font(style.font)
            .cornerRadius(Layout.cornerRadiusM)
            .dreamShadow()
    }
}

enum DreamButtonStyle {
    case primary
    case secondary
    case outline
    case success

    var background: some View {
        switch self {
        case .primary:
            return AnyView(Color.skyGradient)
        case .secondary:
            return AnyView(Color.backgroundSecondary)
        case .outline:
            return AnyView(Color.clear)
        case .success:
            return AnyView(Color.successGradient)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .success:
            return .white
        case .secondary:
            return .textPrimary
        case .outline:
            return .dreamBlue
        }
    }

    var font: Font {
        return .dreamButton
    }
}
