import SwiftUI
import SwiftData
import Combine

struct HomeView: View {
    let userProfile: UserProfile
    let dataManager: DataManager
    let xpManager: XPManager
    let streakManager: StreakManager

    // Present sheet when this is non-nil
    @State private var selectedCareer: Career?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting and XP
                    headerSection

                    // Streak section
                    streakSection

                    // Quick actions
                    quickActionsSection

                    // Recent careers
                    if !userProfile.completedCareers.isEmpty {
                        recentCareersSection
                    }

                    // Suggested careers
                    suggestedCareersSection
                }
                .padding()
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("DreamPath")
            .navigationBarTitleDisplayMode(.large)
        }
        // ✅ Use .sheet(item:) so the builder ALWAYS returns a View
        .sheet(item: $selectedCareer) { career in
            QuestView(
                career: career,
                userProfile: userProfile,
                xpManager: xpManager
            )
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)

                    Text(userProfile.displayName)
                        .font(.dreamHeader)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                // Mascot placeholder
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dreamOrange)
            }

            // XP Bar
            XPBar(
                currentXP: userProfile.totalXP,
                level: userProfile.level,
                xpManager: xpManager
            )
        }
        .padding()
        .dreamCard()
    }

    private var streakSection: some View {
        HStack {
            StreakRing(streakCount: userProfile.streakCount, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Streak")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                Text(streakManager.getStreakMessage())
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding()
        .dreamCard()
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Start a Quest",
                    icon: "play.circle.fill",
                    color: .dreamBlue
                ) {
                    // Pick a default career to start (or navigate to Explore to pick one)
                    if let first = dataManager.careers.first {
                        selectedCareer = first
                    }
                }

                QuickActionButton(
                    title: "Take Quiz",
                    icon: "questionmark.circle.fill",
                    color: .dreamOrange
                ) {
                    // TODO: Navigate to quiz screen
                }

                QuickActionButton(
                    title: "Explore",
                    icon: "magnifyingglass",
                    color: .dreamPurple
                ) {
                    // TODO: Navigate to explore screen
                }
            }
        }
    }

    private var recentCareersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Careers")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(userProfile.completedCareers.prefix(5)), id: \.self) { careerId in
                        if let career = dataManager.getCareer(by: careerId) {
                            RecentCareerCard(career: career) {
                                selectedCareer = career
                            }
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }

    private var suggestedCareersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested for You")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(Array(dataManager.careers.prefix(4)), id: \.id) { career in
                    CareerCardView(
                        career: career,
                        onTap: {
                            selectedCareer = career
                        },
                        onStartQuest: {
                            selectedCareer = career
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Subviews

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(title)
                    .font(.dreamCaption)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusM)
            .dreamShadow()
        }
    }
}

struct RecentCareerCard: View {
    let career: Career
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(career.emoji)
                    .font(.system(size: 32))

                Text(career.title)
                    .font(.dreamCaption)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80, height: 100)
            .padding()
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusM)
            .dreamShadow()
        }
    }
}

#Preview {
    HomeView(
        userProfile: {
            let p = UserProfile(displayName: "Alex", ageMode: .teen)
            p.totalXP = 150
            p.level = 2
            p.streakCount = 3
            return p
        }(),
        dataManager: {
            let ctx = ModelContext(try! ModelContainer(for: UserProfile.self))
            return DataManager(modelContext: ctx)
        }(),
        xpManager: {
            let ctx = ModelContext(try! ModelContainer(for: UserProfile.self))
            return XPManager(modelContext: ctx)
        }(),
        streakManager: {
            let ctx = ModelContext(try! ModelContainer(for: UserProfile.self))
            return StreakManager(modelContext: ctx)
        }()
    )
}
