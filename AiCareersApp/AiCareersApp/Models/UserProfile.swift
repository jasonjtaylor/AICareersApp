//
//  UserProfile.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import SwiftData

@Model
class UserProfile {
    var id: String
    var displayName: String
    var ageMode: AgeMode
    var totalXP: Int
    var level: Int
    var streakCount: Int
    var lastActiveAt: Date
    var badges: [Badge]
    var completedCareers: [String]
    var recommendedCareers: [String]
    var isParentMode: Bool

    init(displayName: String, ageMode: AgeMode) {
        id = UUID().uuidString
        self.displayName = displayName
        self.ageMode = ageMode
        totalXP = 0
        level = 1
        streakCount = 0
        lastActiveAt = Date()
        badges = []
        completedCareers = []
        recommendedCareers = []
        isParentMode = false
    }
}

enum AgeMode: String, CaseIterable, Codable {
    case kid = "Kid" // 8-12
    case teen = "Teen" // 13-17
    case student = "Student" // 18+

    var displayName: String {
        switch self {
        case .kid: return "Kid Explorer"
        case .teen: return "Teen Explorer"
        case .student: return "Student Explorer"
        }
    }

    var ageRange: String {
        switch self {
        case .kid: return "8-12 years"
        case .teen: return "13-17 years"
        case .student: return "18+ years"
        }
    }
}

@Model
class Progress {
    var careerId: String
    var completedStepIds: [String]
    var earnedXP: Int
    var earnedBadges: [String]
    var lastUpdated: Date

    init(careerId: String) {
        self.careerId = careerId
        completedStepIds = []
        earnedXP = 0
        earnedBadges = []
        lastUpdated = Date()
    }
}

@Model
class Badge {
    var id: String
    var name: String
    var details: String       // ✅ renamed
    var iconName: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    var xpReward: Int

    init(id: String, name: String, details: String, iconName: String, xpReward: Int = 0) {
        self.id = id
        self.name = name
        self.details = details
        self.iconName = iconName
        self.isUnlocked = false
        self.unlockedAt = nil
        self.xpReward = xpReward
    }
}


