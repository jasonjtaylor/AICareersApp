//
//  QuizView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct QuizView: View {
    let quizEngine: QuizEngine
    let xpManager: XPManager
    let userProfile: UserProfile
    let dataManager: DataManager

    @State private var showingResults = false

    var body: some View {
        NavigationView {
            VStack {
                if quizEngine.isCompleted {
                    QuizResultsView(
                        result: quizEngine.result!,
                        dataManager: dataManager,
                        onRetake: {
                            quizEngine.reset()
                        },
                        onExploreCareers: {
                            // Navigate to explore with filtered results
                        }
                    )
                } else if let question = quizEngine.getCurrentQuestion() {
                    QuizQuestionView(
                        question: question,
                        progress: quizEngine.getProgress(),
                        onAnswer: { answerId in
                            quizEngine.answerQuestion(questionId: question.id, answerId: answerId)
                        }
                    )
                } else {
                    QuizStartView {
                        if let quiz = dataManager.getMainQuiz() {
                            quizEngine.startQuiz(quiz)
                        }
                    }
                }
            }
            .navigationTitle("Career Quiz")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if quizEngine.currentQuiz == nil {
                if let quiz = dataManager.getMainQuiz() {
                    quizEngine.startQuiz(quiz)
                }
            }
        }
    }
}

// MARK: - Start

struct QuizStartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.dreamBlue)

                Text("Career Discovery Quiz")
                    .font(.dreamTitle)
                    .foregroundColor(.textPrimary)

                Text("Answer 10 questions to discover which careers match your interests and personality!")
                    .font(.dreamBody)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                Text("What you'll discover:")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    QuizFeatureRow(icon: "star.fill", text: "Your top 5 career matches")
                    QuizFeatureRow(icon: "chart.bar.fill", text: "Your personality strengths")
                    QuizFeatureRow(icon: "lightbulb.fill", text: "Personalized recommendations")
                }
            }

            Spacer()

            Button("Start Quiz") {
                onStart()
            }
            .dreamButton(style: .primary)
            .padding(.horizontal)
        }
        .padding()
    }
}

struct QuizFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.dreamBlue)
                .frame(width: 20)

            Text(text)
                .font(.dreamBody)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Question

struct QuizQuestionView: View {
    let question: QuizQuestion
    let progress: Double
    let onAnswer: (String) -> Void

    @State private var selectedAnswer: String?

    var body: some View {
        VStack(spacing: 24) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(Int(progress * 10) + 1) of 10")
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)
                }

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .dreamBlue))
            }
            .padding(.horizontal)

            // Question
            VStack(spacing: 16) {
                Text(question.prompt)
                    .font(.dreamHeader)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Answers
                VStack(spacing: 12) {
                    ForEach(question.answers, id: \.id) { answer in
                        QuizAnswerButton(
                            answer: answer,
                            isSelected: selectedAnswer == answer.id
                        ) {
                            selectedAnswer = answer.id
                        }
                    }
                }
            }
            .padding()

            Spacer()

            // Next button
            Button("Next") {
                if let selected = selectedAnswer {
                    onAnswer(selected)
                }
            }
            .dreamButton(style: .primary)
            .disabled(selectedAnswer == nil)
            .padding(.horizontal)
        }
    }
}

struct QuizAnswerButton: View {
    let answer: QuizAnswer
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(answer.text)
                    .font(.dreamBody)
                    .foregroundColor(isSelected ? .white : .textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                isSelected ? Color.dreamBlue : Color.backgroundSecondary
            )
            .cornerRadius(Layout.cornerRadiusM)
            .dreamShadow()
        }
    }
}

// MARK: - Results

struct QuizResultsView: View {
    let result: QuizResult
    let dataManager: DataManager
    let onRetake: () -> Void
    let onExploreCareers: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.xpGold)

                    Text("Quiz Complete!")
                        .font(.dreamTitle)
                        .foregroundColor(.textPrimary)

                    Text("Here are your career matches")
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)
                }

                // Results
                VStack(spacing: 16) {
                    Text("Your Top Matches")
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)

                    ForEach(Array(result.topCareers.enumerated()), id: \.offset) { index, careerId in
                        if let career = getCareer(by: careerId) {
                            QuizResultCard(
                                career: career,
                                rank: index + 1
                            )
                        }
                    }
                }

                // Rationale
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why these careers?")
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)

                    Text(result.rationale)
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(Layout.cornerRadiusM)
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button("Explore These Careers") {
                        onExploreCareers()
                    }
                    .dreamButton(style: .primary)

                    Button("Retake Quiz") {
                        onRetake()
                    }
                    .dreamButton(style: .outline)
                }
            }
            .padding()
        }
    }

    private func getCareer(by id: String) -> Career? {
        return dataManager.getCareer(by: id)
    }
}

struct QuizResultCard: View {
    let career: Career
    let rank: Int

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.dreamHeader)
                .fontWeight(.bold)
                .foregroundColor(.dreamBlue)
                .frame(width: 30)

            Text(career.emoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(career.title)
                    .font(.dreamBodyBold)
                    .foregroundColor(.textPrimary)

                Text(career.summary)
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

#Preview {
    let dataManager = DataManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self)))
    QuizView(
        quizEngine: QuizEngine(dataManager: dataManager),
        xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        userProfile: UserProfile(displayName: "Alex", ageMode: .teen),
        dataManager: dataManager
    )
}
