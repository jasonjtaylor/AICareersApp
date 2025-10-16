//
//  Quiz.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation

struct Quiz: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let questions: [QuizQuestion]
    let tags: [String]
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let prompt: String
    let answers: [QuizAnswer]
    let tags: [String]
}

struct QuizAnswer: Codable, Identifiable {
    let id: String
    let text: String
    let tags: [String]
    let weight: Int // How much this answer contributes to each tag
}

struct QuizResult: Codable {
    let id: String
    let userId: String
    let completedAt: Date
    let scoreVector: [String: Int] // tag -> score
    let topCareers: [String] // career IDs
    let rationale: String
    let totalScore: Int
}

struct QuizRecommendation: Codable {
    let careerId: String
    let matchScore: Int
    let reason: String
}
