//
//  ContentView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftData
import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataManager: DataManager?
    @State private var xpManager: XPManager?
    @State private var streakManager: StreakManager?
    @State private var quizEngine: QuizEngine?

    @State private var selectedTab = 0
    @State private var userProfile: UserProfile?

    var body: some View {
        Group {
            if let profile = userProfile,
               let dataManager = dataManager,
               let xpManager = xpManager,
               let streakManager = streakManager,
               let quizEngine = quizEngine
            {
                MainTabView(
                    userProfile: profile,
                    dataManager: dataManager,
                    xpManager: xpManager,
                    streakManager: streakManager,
                    quizEngine: quizEngine
                )
            } else {
                OnboardingView(
                    onComplete: { profile in
                        userProfile = profile
                    }
                )
            }
        }
        .onAppear {
            initializeServices()
            loadUserProfile()
        }
    }

    private func initializeServices() {
        if dataManager == nil {
            dataManager = DataManager(modelContext: modelContext)
            xpManager = XPManager(modelContext: modelContext)
            streakManager = StreakManager(modelContext: modelContext)
            if let dataManager = dataManager {
                quizEngine = QuizEngine(dataManager: dataManager)
            }
        }
    }

    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try modelContext.fetch(descriptor)
            if let profile = profiles.first {
                userProfile = profile
                streakManager?.updateProfileStreak(profile)
            }
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
}

struct MainTabView: View {
    let userProfile: UserProfile
    let dataManager: DataManager
    let xpManager: XPManager
    let streakManager: StreakManager
    let quizEngine: QuizEngine

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                userProfile: userProfile,
                dataManager: dataManager,
                xpManager: xpManager,
                streakManager: streakManager
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)

            ExploreView(
                dataManager: dataManager,
                xpManager: xpManager,
                userProfile: userProfile
            )
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
            .tag(1)

            QuizView(
                quizEngine: quizEngine,
                xpManager: xpManager,
                userProfile: userProfile,
                dataManager: dataManager
            )
            .tabItem {
                Image(systemName: "questionmark.circle.fill")
                Text("Quiz")
            }
            .tag(2)

            ProfileView(
                userProfile: userProfile,
                xpManager: xpManager,
                streakManager: streakManager,
                dataManager: dataManager
            )
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(.dreamBlue)
    }
}

#Preview {
    ContentView()
}
