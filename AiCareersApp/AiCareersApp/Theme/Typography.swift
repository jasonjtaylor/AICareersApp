//
//  Typography.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI

extension Font {
    // MARK: - Headers

    static let dreamTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let dreamHeader = Font.system(size: 24, weight: .bold, design: .rounded)
    static let dreamSubheader = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body Text

    static let dreamBody = Font.system(size: 16, weight: .regular, design: .rounded)
    static let dreamBodyBold = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let dreamCaption = Font.system(size: 14, weight: .regular, design: .rounded)
    static let dreamSmall = Font.system(size: 12, weight: .regular, design: .rounded)

    // MARK: - Buttons

    static let dreamButton = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let dreamButtonLarge = Font.system(size: 18, weight: .bold, design: .rounded)

    // MARK: - Special

    static let dreamXP = Font.system(size: 18, weight: .bold, design: .rounded)
    static let dreamLevel = Font.system(size: 14, weight: .bold, design: .rounded)
    static let dreamBadge = Font.system(size: 12, weight: .semibold, design: .rounded)
}

// MARK: - Age Mode Typography

extension Font {
    static func dreamFont(for ageMode: AgeMode, style: DreamFontStyle) -> Font {
        let baseSize: CGFloat
        let weight: Font.Weight

        switch ageMode {
        case .kid:
            baseSize = style.kidSize
            weight = style.kidWeight
        case .teen:
            baseSize = style.teenSize
            weight = style.teenWeight
        case .student:
            baseSize = style.studentSize
            weight = style.studentWeight
        }

        return Font.system(size: baseSize, weight: weight, design: .rounded)
    }
}

enum DreamFontStyle {
    case title
    case header
    case body
    case caption
    case button

    var kidSize: CGFloat {
        switch self {
        case .title: return 28
        case .header: return 22
        case .body: return 16
        case .caption: return 14
        case .button: return 16
        }
    }

    var teenSize: CGFloat {
        switch self {
        case .title: return 30
        case .header: return 24
        case .body: return 16
        case .caption: return 14
        case .button: return 16
        }
    }

    var studentSize: CGFloat {
        switch self {
        case .title: return 32
        case .header: return 24
        case .body: return 16
        case .caption: return 14
        case .button: return 16
        }
    }

    var kidWeight: Font.Weight {
        switch self {
        case .title: return .bold
        case .header: return .bold
        case .body: return .regular
        case .caption: return .regular
        case .button: return .semibold
        }
    }

    var teenWeight: Font.Weight {
        switch self {
        case .title: return .bold
        case .header: return .semibold
        case .body: return .regular
        case .caption: return .regular
        case .button: return .semibold
        }
    }

    var studentWeight: Font.Weight {
        switch self {
        case .title: return .bold
        case .header: return .semibold
        case .body: return .regular
        case .caption: return .regular
        case .button: return .semibold
        }
    }
}
