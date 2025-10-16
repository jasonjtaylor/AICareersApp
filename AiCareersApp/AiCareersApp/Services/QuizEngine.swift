//
//  QuizEngine.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import Combine

@MainActor
class QuizEngine: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex: Int = 0
    @Published var answers: [String: String] = [:] // questionId -> answerId
    @Published var isCompleted: Bool = false
    @Published var result: QuizResult?

    private let dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentQuestionIndex = 0
        answers = [:]
        isCompleted = false
        result = nil
    }

    func answerQuestion(questionId: String, answerId: String) {
        answers[questionId] = answerId

        if currentQuestionIndex < (currentQuiz?.questions.count ?? 0) - 1 {
            currentQuestionIndex += 1
        } else {
            completeQuiz()
        }
    }

    private func completeQuiz() {
        guard let quiz = currentQuiz else { return }

        let scoreVector = calculateScoreVector(quiz: quiz)
        let topCareers = findTopCareers(scoreVector: scoreVector)
        let rationale = generateRationale(scoreVector: scoreVector, topCareers: topCareers)

        result = QuizResult(
            id: UUID().uuidString,
            userId: "current_user", // Would be actual user ID
            completedAt: Date(),
            scoreVector: scoreVector,
            topCareers: topCareers,
            rationale: rationale,
            totalScore: scoreVector.values.reduce(0, +)
        )

        isCompleted = true
    }

    private func calculateScoreVector(quiz: Quiz) -> [String: Int] {
        var scoreVector: [String: Int] = [:]

        for question in quiz.questions {
            guard let answerId = answers[question.id],
                  let answer = question.answers.first(where: { $0.id == answerId })
            else {
                continue
            }

            for tag in answer.tags {
                scoreVector[tag, default: 0] += answer.weight
            }
        }

        return scoreVector
    }

    private func findTopCareers(scoreVector: [String: Int]) -> [String] {
        let careers = dataManager.careers

        // Calculate match scores for each career
        let careerScores = careers.map { career in
            let matchScore = career.quizTags.reduce(0) { total, tag in
                total + (scoreVector[tag] ?? 0)
            }
            return (career.id, matchScore)
        }

        // Sort by score and return top 5
        return careerScores
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { $0.0 }
    }

    private func generateRationale(scoreVector: [String: Int], topCareers _: [String]) -> String {
        let topTags = scoreVector
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        var rationale = "Based on your interests in "
        rationale += topTags.joined(separator: ", ")
        rationale += ", we've matched you with careers that align with your personality and strengths."

        return rationale
    }

    func getCurrentQuestion() -> QuizQuestion? {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count
        else {
            return nil
        }
        return quiz.questions[currentQuestionIndex]
    }

    func getProgress() -> Double {
        guard let quiz = currentQuiz else { return 0.0 }
        return Double(currentQuestionIndex) / Double(quiz.questions.count)
    }

    func reset() {
        currentQuiz = nil
        currentQuestionIndex = 0
        answers = [:]
        isCompleted = false
        result = nil
    }
}
