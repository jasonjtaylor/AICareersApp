//
//  Career.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation

struct Career: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let categories: [CareerCategory]
    let salary: SalaryBand
    let power: PowerMeters
    let education: EducationInfo
    let activities: [String]
    let quizTags: [String]
    let resources: [String]
    let programs: [String]
    let emoji: String
    let questSteps: [QuestStep]

    enum CareerCategory: String, CaseIterable, Codable {
        case science = "Science"
        case tech = "Technology"
        case arts = "Arts"
        case trades = "Trades"
        case health = "Health"
        case publicService = "Public Service"
        case outdoors = "Outdoors"
        case business = "Business"
    }
}

struct SalaryBand: Codable, Hashable {
    let entry: Int
    let mid: Int
    let top: Int

    var entryFormatted: String {
        "$\(entry / 1000)k"
    }

    var midFormatted: String {
        "$\(mid / 1000)k"
    }

    var topFormatted: String {
        "$\(top / 1000)k"
    }
}

struct PowerMeters: Codable, Hashable {
    let creativity: Int // 0-100
    let tech: Int // 0-100
    let leadership: Int // 0-100
    let adventure: Int // 0-100

    var total: Int {
        creativity + tech + leadership + adventure
    }
}

struct EducationInfo: Codable, Hashable {
    let paths: [EducationPath]
    let prerequisites: [String]
}

struct EducationPath: Codable, Identifiable, Hashable {
    let id: String
    let level: EducationLevel
    let description: String
    let duration: String
    let requirements: [String]

    enum EducationLevel: String, CaseIterable, Codable {
        case middleSchool = "Middle School"
        case highSchool = "High School"
        case certificate = "Certificate"
        case diploma = "Diploma"
        case degree = "Degree"
        case graduate = "Graduate"
    }
}

struct QuestStep: Codable, Identifiable, Hashable {
    let id: String
    let type: QuestStepType
    let title: String
    let content: String
    let xpReward: Int
    let isCompleted: Bool = false

    enum QuestStepType: String, CaseIterable, Codable {
        case learn = "Learn"
        case tryOut = "Try"
        case path = "Path"
        case skills = "Skills"
    }
}
