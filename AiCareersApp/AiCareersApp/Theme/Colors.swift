//
//  Colors.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    static let dreamBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let dreamPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let dreamOrange = Color(red: 1.0, green: 0.5, blue: 0.2)
    static let dreamPink = Color(red: 1.0, green: 0.3, blue: 0.6)

    // MARK: - Gradients

    static let skyGradient = LinearGradient(
        colors: [dreamBlue, dreamPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sunsetGradient = LinearGradient(
        colors: [dreamOrange, dreamPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color.green.opacity(0.8), Color.mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Background Colors

    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Text Colors

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Accent Colors

    static let xpGold = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let streakOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let badgeBlue = Color(red: 0.0, green: 0.5, blue: 1.0)

    // MARK: - Power Meter Colors

    static let creativityColor = Color.purple
    static let techColor = Color.blue
    static let leadershipColor = Color.orange
    static let adventureColor = Color.green
}

// MARK: - Category Colors

extension Color {
    static func categoryColor(for category: Career.CareerCategory) -> Color {
        switch category {
        case .science:
            return .blue
        case .tech:
            return .cyan
        case .arts:
            return .purple
        case .trades:
            return .orange
        case .health:
            return .red
        case .publicService:
            return .green
        case .outdoors:
            return .mint
        case .business:
            return .indigo
        }
    }
}
