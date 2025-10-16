//
//  PDFReportService.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import PDFKit
import SwiftUI
import Combine

class PDFReportService: ObservableObject {
    func generateReport(for userProfile: UserProfile, careers: [Career]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "DreamPath App",
            kCGPDFContextAuthor: "DreamPath Team",
            kCGPDFContextTitle: "Career Exploration Report - \(userProfile.displayName)",
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            // Header
            drawHeader(in: pageRect)

            // Student Info
            drawStudentInfo(userProfile, in: pageRect)

            // Progress Summary
            drawProgressSummary(userProfile, in: pageRect)

            // Top Careers
            drawTopCareers(careers, in: pageRect)

            // Recommendations
            drawRecommendations(userProfile, in: pageRect)
        }

        return data
    }

    private func drawHeader(in rect: CGRect) {
        let headerRect = CGRect(x: 50, y: 50, width: rect.width - 100, height: 60)

        // App title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.systemBlue,
        ]

        "DreamPath Career Report".draw(in: headerRect, withAttributes: titleAttributes)

        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date())

        let dateRect = CGRect(x: 50, y: 80, width: rect.width - 100, height: 20)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.systemGray,
        ]

        dateString.draw(in: dateRect, withAttributes: dateAttributes)
    }

    private func drawStudentInfo(_ profile: UserProfile, in rect: CGRect) {
        let startY: CGFloat = 120
        let sectionRect = CGRect(x: 50, y: startY, width: rect.width - 100, height: 80)

        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
        ]

        "Student Information".draw(in: CGRect(x: 50, y: startY, width: rect.width - 100, height: 20), withAttributes: titleAttributes)

        // Student details
        let details = [
            "Name: \(profile.displayName)",
            "Age Group: \(profile.ageMode.displayName)",
            "Level: \(profile.level)",
            "Total XP: \(profile.totalXP)",
        ]

        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
        ]

        var yOffset: CGFloat = startY + 25
        for detail in details {
            detail.draw(in: CGRect(x: 50, y: yOffset, width: rect.width - 100, height: 15), withAttributes: detailsAttributes)
            yOffset += 15
        }
    }

    private func drawProgressSummary(_ profile: UserProfile, in rect: CGRect) {
        let startY: CGFloat = 220
        let sectionRect = CGRect(x: 50, y: startY, width: rect.width - 100, height: 100)

        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
        ]

        "Progress Summary".draw(in: CGRect(x: 50, y: startY, width: rect.width - 100, height: 20), withAttributes: titleAttributes)

        // Progress details
        let progressDetails = [
            "Current Level: \(profile.level)",
            "Total Experience Points: \(profile.totalXP)",
            "Daily Streak: \(profile.streakCount) days",
            "Badges Earned: \(profile.badges.filter { $0.isUnlocked }.count)",
            "Careers Explored: \(profile.completedCareers.count)",
        ]

        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
        ]

        var yOffset: CGFloat = startY + 25
        for detail in progressDetails {
            detail.draw(in: CGRect(x: 50, y: yOffset, width: rect.width - 100, height: 15), withAttributes: detailsAttributes)
            yOffset += 15
        }
    }

    private func drawTopCareers(_ careers: [Career], in rect: CGRect) {
        let startY: CGFloat = 340
        let sectionRect = CGRect(x: 50, y: startY, width: rect.width - 100, height: 200)

        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
        ]

        "Top Career Interests".draw(in: CGRect(x: 50, y: startY, width: rect.width - 100, height: 20), withAttributes: titleAttributes)

        // Career list
        let careerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
        ]

        var yOffset: CGFloat = startY + 25
        for (index, career) in careers.prefix(5).enumerated() {
            let careerText = "\(index + 1). \(career.title) - \(career.summary)"
            careerText.draw(in: CGRect(x: 50, y: yOffset, width: rect.width - 100, height: 15), withAttributes: careerAttributes)
            yOffset += 15
        }
    }

    private func drawRecommendations(_: UserProfile, in rect: CGRect) {
        let startY: CGFloat = 560
        let sectionRect = CGRect(x: 50, y: startY, width: rect.width - 100, height: 100)

        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
        ]

        "Recommendations".draw(in: CGRect(x: 50, y: startY, width: rect.width - 100, height: 20), withAttributes: titleAttributes)

        // Recommendations
        let recommendations = [
            "• Continue exploring different career paths",
            "• Complete more quests to earn XP and badges",
            "• Take the career quiz to discover new matches",
            "• Consider joining clubs or activities related to your interests",
        ]

        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
        ]

        var yOffset: CGFloat = startY + 25
        for recommendation in recommendations {
            recommendation.draw(in: CGRect(x: 50, y: yOffset, width: rect.width - 100, height: 15), withAttributes: detailsAttributes)
            yOffset += 15
        }
    }
}
