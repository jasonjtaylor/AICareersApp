//
//  DataManager.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import SwiftData
import Combine

@MainActor
class DataManager: ObservableObject {
    @Published var careers: [Career] = []
    @Published var programs: [Program] = []
    @Published var quizzes: [Quiz] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }

    func loadData() {
        isLoading = true
        error = nil

        Task {
            do {
                // Load careers
                if let careersData = loadJSONData(from: "MockCareers") {
                    careers = try JSONDecoder().decode([Career].self, from: careersData)
                }

                // Load programs
                if let programsData = loadJSONData(from: "MockPrograms") {
                    programs = try JSONDecoder().decode([Program].self, from: programsData)
                }

                // Load quizzes
                if let quizzesData = loadJSONData(from: "MockQuizzes") {
                    quizzes = try JSONDecoder().decode([Quiz].self, from: quizzesData)
                }

                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }

    private func loadJSONData(from filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json in bundle")
            return nil
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading \(filename).json: \(error)")
            return nil
        }
    }

    // MARK: - Career Operations

    func getCareer(by id: String) -> Career? {
        return careers.first { $0.id == id }
    }

    func getCareers(by category: Career.CareerCategory) -> [Career] {
        return careers.filter { $0.categories.contains(category) }
    }

    func searchCareers(query: String) -> [Career] {
        guard !query.isEmpty else { return careers }

        return careers.filter { career in
            career.title.localizedCaseInsensitiveContains(query) ||
                career.summary.localizedCaseInsensitiveContains(query) ||
                career.categories.contains { $0.rawValue.localizedCaseInsensitiveContains(query) }
        }
    }

    // MARK: - Program Operations

    func getPrograms(for careerId: String) -> [Program] {
        return programs.filter { $0.careerIds.contains(careerId) }
    }

    func getPrograms(by level: Program.ProgramLevel) -> [Program] {
        return programs.filter { $0.level == level }
    }

    // MARK: - Quiz Operations

    func getQuiz(by id: String) -> Quiz? {
        return quizzes.first { $0.id == id }
    }

    func getMainQuiz() -> Quiz? {
        return quizzes.first
    }
}
