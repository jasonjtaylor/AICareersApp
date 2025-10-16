//
//  ProfileView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct ProfileView: View {
    let userProfile: UserProfile
    let xpManager: XPManager
    let streakManager: StreakManager
    let dataManager: DataManager

    @State private var showingParentMode = false
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader

                    // Stats section
                    statsSection

                    // Badges section
                    badgesSection

                    // Settings section
                    settingsSection
                }
                .padding()
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingParentMode) {
            ParentDashboardView(userProfile: userProfile, dataManager: dataManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(userProfile: userProfile)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.skyGradient)
                    .frame(width: 100, height: 100)

                Text(userProfile.displayName.prefix(1).uppercased())
                    .font(.dreamTitle)
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(userProfile.displayName)
                    .font(.dreamHeader)
                    .foregroundColor(.textPrimary)

                Text(userProfile.ageMode.displayName)
                    .font(.dreamBody)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .dreamCard()
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            HStack(spacing: 20) {
                StatCard(
                    title: "Level",
                    value: "\(userProfile.level)",
                    icon: "star.fill",
                    color: .xpGold
                )

                StatCard(
                    title: "Total XP",
                    value: "\(userProfile.totalXP)",
                    icon: "bolt.fill",
                    color: .dreamBlue
                )

                StatCard(
                    title: "Streak",
                    value: "\(userProfile.streakCount)",
                    icon: "flame.fill",
                    color: .streakOrange
                )
            }
        }
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Badges")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(userProfile.badges.filter { $0.isUnlocked }.count)/\(userProfile.badges.count)")
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(userProfile.badges, id: \.id) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "person.circle.fill",
                    title: "Edit Profile",
                    action: {
                        showingSettings = true
                    }
                )

                SettingsRow(
                    icon: "chart.bar.fill",
                    title: "View Progress",
                    action: {
                        // Show detailed progress
                    }
                )

                SettingsRow(
                    icon: "person.2.fill",
                    title: "Parent/Educator Mode",
                    action: {
                        showingParentMode = true
                    }
                )

                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    action: {
                        // Show notification settings
                    }
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.dreamHeader)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text(title)
                .font(.dreamCaption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

struct BadgeCard: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? Color.badgeBlue : Color.backgroundTertiary)
                    .frame(width: 50, height: 50)

                Image(systemName: badge.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(badge.isUnlocked ? .white : .textTertiary)
            }

            Text(badge.name)
                .font(.dreamSmall)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(badge.isUnlocked ? 1.0 : 0.5)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.dreamBlue)
                    .frame(width: 24)

                Text(title)
                    .font(.dreamBody)
                    .foregroundColor(.textPrimary)

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
}

struct ParentDashboardView: View {
    let userProfile: UserProfile
    let dataManager: DataManager

    @StateObject private var pdfService = PDFReportService()
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Parent/Educator Dashboard")
                        .font(.dreamTitle)
                        .foregroundColor(.textPrimary)

                    // Progress overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Overview")
                            .font(.dreamSubheader)
                            .foregroundColor(.textPrimary)

                        VStack(spacing: 12) {
                            ParentStatRow(
                                title: "Current Level",
                                value: "\(userProfile.level)",
                                icon: "star.fill",
                                color: .xpGold
                            )

                            ParentStatRow(
                                title: "Total XP",
                                value: "\(userProfile.totalXP)",
                                icon: "bolt.fill",
                                color: .dreamBlue
                            )

                            ParentStatRow(
                                title: "Daily Streak",
                                value: "\(userProfile.streakCount) days",
                                icon: "flame.fill",
                                color: .streakOrange
                            )

                            ParentStatRow(
                                title: "Badges Earned",
                                value: "\(userProfile.badges.filter { $0.isUnlocked }.count)",
                                icon: "medal.fill",
                                color: .badgeBlue
                            )
                        }
                    }
                    .padding()
                    .dreamCard()

                    // Export PDF button
                    Button("Export Progress Report") {
                        generatePDF()
                    }
                    .dreamButton(style: .primary)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(activityItems: [pdfData])
            }
        }
    }

    private func generatePDF() {
        let careers = dataManager.careers.filter { career in
            userProfile.completedCareers.contains(career.id) ||
                userProfile.recommendedCareers.contains(career.id)
        }

        if let pdfData = pdfService.generateReport(for: userProfile, careers: careers) {
            self.pdfData = pdfData
            showingShareSheet = true
        }
    }
}

struct ParentStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.dreamBody)
                    .foregroundColor(.textPrimary)

                Text(value)
                    .font(.dreamBodyBold)
                    .foregroundColor(.textPrimary)
            }

            Spacer()
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

struct SettingsView: View {
    let userProfile: UserProfile

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Settings")
                        .font(.dreamTitle)
                        .foregroundColor(.textPrimary)

                    Text("Settings panel coming soon!")
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleProfile = UserProfile(displayName: "Alex", ageMode: .teen)
    sampleProfile.totalXP = 150
    sampleProfile.level = 2
    sampleProfile.streakCount = 3

    let dataManager = DataManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self)))

    ProfileView(
        userProfile: sampleProfile,
        xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        streakManager: StreakManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        dataManager: dataManager
    )
}
