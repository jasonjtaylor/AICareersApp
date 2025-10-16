//
//  CareerDetailView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct CareerDetailView: View {
    let career: Career
    let dataManager: DataManager
    let onStartQuest: () -> Void

    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Tab selector
                    tabSelector

                    // Content
                    contentSection
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle(career.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start Quest") {
                        onStartQuest()
                    }
                    .dreamButton(style: .primary)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Emoji and title
            HStack {
                Text(career.emoji)
                    .font(.system(size: 48))

                VStack(alignment: .leading, spacing: 4) {
                    Text(career.title)
                        .font(.dreamTitle)
                        .foregroundColor(.textPrimary)

                    Text(career.summary)
                        .font(.dreamBody)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(career.categories, id: \.self) { category in
                        CategoryChip(category: category)
                    }
                }
                .padding(.horizontal, 1)
            }

            // Power meters
            VStack(spacing: 12) {
                Text("Career Strengths")
                    .font(.dreamSubheader)
                    .foregroundColor(.textPrimary)

                VStack(spacing: 8) {
                    PowerMeterRow(
                        label: "Creativity",
                        value: career.power.creativity,
                        color: .creativityColor
                    )
                    PowerMeterRow(
                        label: "Tech",
                        value: career.power.tech,
                        color: .techColor
                    )
                    PowerMeterRow(
                        label: "Leadership",
                        value: career.power.leadership,
                        color: .leadershipColor
                    )
                    PowerMeterRow(
                        label: "Adventure",
                        value: career.power.adventure,
                        color: .adventureColor
                    )
                }
            }
        }
        .padding()
        .background(Color.backgroundSecondary)
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "About",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            TabButton(
                title: "Skills",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            TabButton(
                title: "Salary",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            TabButton(
                title: "Education",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.horizontal)
        .background(Color.backgroundPrimary)
    }

    private var contentSection: some View {
        VStack(spacing: 16) {
            switch selectedTab {
            case 0:
                aboutContent
            case 1:
                skillsContent
            case 2:
                salaryContent
            case 3:
                educationContent
            default:
                aboutContent
            }
        }
        .padding()
    }

    private var aboutContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What does a \(career.title) do?")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            Text("A \(career.title.lowercased()) is responsible for \(career.summary.lowercased()). This career offers opportunities to work in various settings and make a meaningful impact.")
                .font(.dreamBody)
                .foregroundColor(.textSecondary)

            if !career.activities.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try These Activities")
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)

                    ForEach(career.activities, id: \.self) { activity in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.dreamBlue)

                            Text(activity)
                                .font(.dreamBody)
                                .foregroundColor(.textSecondary)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var skillsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Required Skills")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                SkillCard(skill: "Problem Solving", level: "High")
                SkillCard(skill: "Communication", level: "Medium")
                SkillCard(skill: "Technical Skills", level: "High")
                SkillCard(skill: "Creativity", level: "Medium")
            }
        }
    }

    private var salaryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Salary Information")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                SalaryInfoCard(
                    level: "Entry Level",
                    amount: career.salary.entryFormatted,
                    description: "Starting salary for new graduates"
                )

                SalaryInfoCard(
                    level: "Mid Career",
                    amount: career.salary.midFormatted,
                    description: "With 5-10 years of experience"
                )

                SalaryInfoCard(
                    level: "Senior Level",
                    amount: career.salary.topFormatted,
                    description: "With 10+ years of experience"
                )
            }
        }
    }

    private var educationContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Education Path")
                .font(.dreamSubheader)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                ForEach(career.education.paths, id: \.id) { path in
                    EducationPathCard(path: path)
                }
            }

            if !career.education.prerequisites.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prerequisites")
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)

                    ForEach(career.education.prerequisites, id: \.self) { prerequisite in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.dreamBlue)

                            Text(prerequisite)
                                .font(.dreamBody)
                                .foregroundColor(.textSecondary)

                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.dreamBody)
                    .foregroundColor(isSelected ? .dreamBlue : .textSecondary)

                Rectangle()
                    .fill(isSelected ? Color.dreamBlue : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

struct SkillCard: View {
    let skill: String
    let level: String

    var body: some View {
        VStack(spacing: 8) {
            Text(skill)
                .font(.dreamBodyBold)
                .foregroundColor(.textPrimary)

            Text(level)
                .font(.dreamCaption)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.backgroundTertiary)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

struct SalaryInfoCard: View {
    let level: String
    let amount: String
    let description: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(level)
                    .font(.dreamBodyBold)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Text(amount)
                .font(.dreamHeader)
                .fontWeight(.bold)
                .foregroundColor(.dreamBlue)
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

struct EducationPathCard: View {
    let path: EducationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(path.level.rawValue)
                    .font(.dreamBodyBold)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text(path.duration)
                    .font(.dreamCaption)
                    .foregroundColor(.textSecondary)
            }

            Text(path.description)
                .font(.dreamBody)
                .foregroundColor(.textSecondary)

            if !path.requirements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requirements:")
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)

                    ForEach(path.requirements, id: \.self) { requirement in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.dreamBlue)

                            Text(requirement)
                                .font(.dreamSmall)
                                .foregroundColor(.textSecondary)

                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .dreamShadow()
    }
}

#Preview {
    let sampleCareer = Career(
        id: "1",
        title: "Software Developer",
        summary: "Create amazing apps and websites that people use every day",
        categories: [.tech, .science],
        salary: SalaryBand(entry: 50000, mid: 80000, top: 150_000),
        power: PowerMeters(creativity: 70, tech: 95, leadership: 40, adventure: 30),
        education: EducationInfo(
            paths: [
                EducationPath(
                    id: "cs-degree",
                    level: .degree,
                    description: "Computer Science Degree",
                    duration: "4 years",
                    requirements: ["High school diploma", "Math courses"]
                ),
            ],
            prerequisites: ["High school diploma", "Basic computer skills"]
        ),
        activities: ["Learn to code online", "Build your first app"],
        quizTags: ["tech", "creative", "analytical"],
        resources: [],
        programs: [],
        emoji: "💻",
        questSteps: []
    )

    CareerDetailView(
        career: sampleCareer,
        dataManager: DataManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        onStartQuest: {}
    )
}
