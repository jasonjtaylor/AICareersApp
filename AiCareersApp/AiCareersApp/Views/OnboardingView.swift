//
//  OnboardingView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftData
import SwiftUI
import Combine

struct OnboardingView: View {
    let onComplete: (UserProfile) -> Void

    @State private var displayName = ""
    @State private var selectedAgeMode: AgeMode = .teen
    @State private var currentStep = 0

    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: .dreamBlue))
                .padding(.horizontal)
                .padding(.top)

            TabView(selection: $currentStep) {
                // Step 1: Welcome
                WelcomeStep()
                    .tag(0)

                // Step 2: Name and Age
                NameAgeStep(displayName: $displayName, selectedAgeMode: $selectedAgeMode)
                    .tag(1)

                // Step 3: Ready to Start
                ReadyStep()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .dreamButton(style: .outline)
                }

                Spacer()

                Button(currentStep == totalSteps - 1 ? "Get Started!" : "Next") {
                    if currentStep == totalSteps - 1 {
                        createUserProfile()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .dreamButton(style: .primary)
                .disabled(currentStep == 1 && displayName.isEmpty)
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
    }

    private func createUserProfile() {
        let profile = UserProfile(displayName: displayName, ageMode: selectedAgeMode)
        onComplete(profile)
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon/logo placeholder
            ZStack {
                Circle()
                    .fill(Color.skyGradient)
                    .frame(width: 120, height: 120)

                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("Welcome to DreamPath!")
                    .font(.dreamTitle)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPrimary)

                Text("Discover your perfect career through fun quests, quizzes, and adventures!")
                    .font(.dreamBody)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

struct NameAgeStep: View {
    @Binding var displayName: String
    @Binding var selectedAgeMode: AgeMode

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                Text("Tell us about yourself")
                    .font(.dreamHeader)
                    .foregroundColor(.textPrimary)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What should we call you?")
                            .font(.dreamSubheader)
                            .foregroundColor(.textPrimary)

                        TextField("Enter your name", text: $displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.dreamBody)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your age group?")
                            .font(.dreamSubheader)
                            .foregroundColor(.textPrimary)

                        VStack(spacing: 12) {
                            ForEach(AgeMode.allCases, id: \.self) { ageMode in
                                AgeModeButton(
                                    ageMode: ageMode,
                                    isSelected: selectedAgeMode == ageMode
                                ) {
                                    selectedAgeMode = ageMode
                                }
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct AgeModeButton: View {
    let ageMode: AgeMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ageMode.displayName)
                        .font(.dreamBodyBold)
                        .foregroundColor(isSelected ? .white : .textPrimary)

                    Text(ageMode.ageRange)
                        .font(.dreamCaption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
.background {
    if isSelected {
        LinearGradient(colors: [.dreamBlue, .dreamPurple],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    } else {
        Color.backgroundSecondary
    }
}
            .dreamShadow()
        }
    }
}

struct ReadyStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "rocket.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.dreamOrange)

                Text("You're all set!")
                    .font(.dreamTitle)
                    .foregroundColor(.textPrimary)

                Text("Get ready to explore amazing careers, complete fun quests, and discover your dream path!")
                    .font(.dreamBody)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView { profile in
        print("Profile created: \(profile.displayName)")
    }
}
