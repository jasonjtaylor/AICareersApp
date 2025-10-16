//
//  Program.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation

struct Program: Codable, Identifiable {
    let id: String
    let name: String
    let institution: String
    let region: String
    let level: ProgramLevel
    let duration: String
    let category: String
    let url: String?
    let description: String
    let requirements: [String]
    let careerIds: [String] // Which careers this program relates to

    enum ProgramLevel: String, CaseIterable, Codable {
        case certificate = "Certificate"
        case diploma = "Diploma"
        case degree = "Degree"
        case graduate = "Graduate"
        case apprenticeship = "Apprenticeship"
    }
}

struct Institution: Codable, Identifiable {
    let id: String
    let name: String
    let region: String
    let type: InstitutionType
    let programs: [String] // Program IDs

    enum InstitutionType: String, CaseIterable, Codable {
        case university = "University"
        case college = "College"
        case tradeSchool = "Trade School"
        case online = "Online"
        case community = "Community College"
    }
}
