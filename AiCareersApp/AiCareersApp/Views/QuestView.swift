//
//  QuestView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct QuestView: View {
    let career: Career
    let userProfile: UserProfile
    let xpManager: XPManager

    @State private var currentStepIndex = 0
    @State private var completedSteps: Set<String> = []
    @State private var showingConfetti = false

    private var currentStep: QuestStep? {
        guard currentStepIndex < career.questSteps.count else { return nil }
        return career.questSteps[currentStepIndex]
    }

    private var progress: Double {
        guard !career.questSteps.isEmpty else { return 0.0 }
        return Double(completedSteps.count) / Double(career.questSteps.count)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection

                // Progress
                progressSection

                // Content
                contentSection

                // Navigation
                navigationSection
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("\(career.title) Quest")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                ConfettiOverlay(isShowing: $showingConfetti)
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(career.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(career.title)
                        .font(.dreamHeader)
                        .foregroundColor(.textPrimary)

                    Text("Career Quest")
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Quest overview
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quest Steps")
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)

                    Text("\(completedSteps.count) of \(career.questSteps.count) completed")
                        .font(.dreamBody)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                QuestProgressRing(
                    completedSteps: completedSteps.count,
                    totalSteps: career.questSteps.count,
                    size: 60
                )
            }
        }
        .padding()
        .background(Color.backgroundSecondary)
    }

    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
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
        .padding(.vertical, 8)
    }

    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let step = currentStep {
                    QuestStepView(
                        step: step,
                        isCompleted: completedSteps.contains(step.id),
                        onComplete: {
                            completeStep(step)
                        }
                    )
                } else {
                    QuestCompleteView(
                        career: career,
                        totalXP: career.questSteps.reduce(0) { $0 + $1.xpReward }
                    )
                }
            }
            .padding()
        }
    }

    private var navigationSection: some View {
        HStack(spacing: 16) {
            if currentStepIndex > 0 {
                Button("Previous") {
                    withAnimation {
                        currentStepIndex -= 1
                    }
                }
                .dreamButton(style: .outline)
            }

            Spacer()

            if let step = currentStep, !completedSteps.contains(step.id) {
                Button("Mark Complete") {
                    completeStep(step)
                }
                .dreamButton(style: .primary)
            } else if currentStepIndex < career.questSteps.count - 1 {
                Button("Next") {
                    withAnimation {
                        currentStepIndex += 1
                    }
                }
                .dreamButton(style: .primary)
            }
        }
        .padding()
        .background(Color.backgroundSecondary)
    }

    private func completeStep(_ step: QuestStep) {
        completedSteps.insert(step.id)

        // Award XP
        xpManager.awardXP(to: userProfile, reason: .questStep, amount: step.xpReward)

        // Show confetti
        showingConfetti = true

        // Auto-advance to next step after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentStepIndex < career.questSteps.count - 1 {
                withAnimation {
                    currentStepIndex += 1
                }
            }
        }
    }
}

struct QuestStepView: View {
    let step: QuestStep
    let isCompleted: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.type.rawValue)
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)

                    Text(step.title)
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else {
                    Text("+\(step.xpReward) XP")
                        .font(.dreamCaption)
                        .foregroundColor(.xpGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.xpGold.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            // Step content
            Text(step.content)
                .font(.dreamBody)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)

            // Action button
            if !isCompleted {
                Button("Complete Step") {
                    onComplete()
                }
                .dreamButton(style: .success)
            }
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusL)
        .dreamShadow()
    }
}

struct QuestCompleteView: View {
    let career: Career
    let totalXP: Int

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundColor(.xpGold)

            VStack(spacing: 16) {
                Text("Quest Complete!")
                    .font(.dreamTitle)
                    .foregroundColor(.textPrimary)

                Text("Congratulations! You've completed the \(career.title) quest.")
                    .font(.dreamBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Text("You earned:")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.xpGold)

                    Text("\(totalXP) XP")
                        .font(.dreamHeader)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                .padding()
                .background(Color.backgroundSecondary)
                .cornerRadius(Layout.cornerRadiusM)
                .dreamShadow()
            }

            VStack(spacing: 16) {
                Text("What's next?")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                VStack(spacing: 12) {
                    QuestNextStepCard(
                        title: "Explore More Careers",
                        description: "Discover other exciting career paths",
                        icon: "magnifyingglass"
                    )

                    QuestNextStepCard(
                        title: "Take the Quiz",
                        description: "Find your perfect career match",
                        icon: "questionmark.circle"
                    )

                    QuestNextStepCard(
                        title: "View Your Profile",
                        description: "See your progress and badges",
                        icon: "person.circle"
                    )
                }
            }
        }
        .padding()
    }
}

struct QuestNextStepCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.dreamBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.dreamBodyBold)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

struct ConfettiOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            ZStack {
                Color.clear
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isShowing = false
                        }
                    }

                // Simple confetti animation
                ForEach(0 ..< 20, id: \.self) { _ in
                    ConfettiPiece()
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    @State private var offset = CGSize.zero
    @State private var rotation = 0.0
    @State private var opacity = 1.0

    private let colors: [Color] = [.dreamBlue, .dreamOrange, .dreamPurple, .xpGold, .green]

    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .dreamBlue)
            .frame(width: 8, height: 8)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    offset = CGSize(
                        width: Double.random(in: -200 ... 200),
                        height: Double.random(in: -300 ... 300)
                    )
                    rotation = Double.random(in: 0 ... 360)
                    opacity = 0
                }
            }
    }
}

#Preview {
    let sampleCareer = Career(
        id: "1",
        title: "Software Developer",
        summary: "Create amazing apps and websites",
        categories: [.tech],
        salary: SalaryBand(entry: 50000, mid: 80000, top: 150_000),
        power: PowerMeters(creativity: 70, tech: 95, leadership: 40, adventure: 30),
        education: EducationInfo(paths: [], prerequisites: []),
        activities: [],
        quizTags: [],
        resources: [],
        programs: [],
        emoji: "💻",
        questSteps: [
            QuestStep(
                id: "step1",
                type: .learn,
                title: "Learn about programming",
                content: "Learn the basics of computer programming",
                xpReward: 50
            ),
            QuestStep(
                id: "step2",
                type: .tryOut,
                title: "Write your first program",
                content: "Create a simple program using Python",
                xpReward: 100
            ),
        ]
    )

    QuestView(
        career: sampleCareer,
        userProfile: UserProfile(displayName: "Alex", ageMode: .teen),
        xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self)))
    )
}
