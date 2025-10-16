//
//  CareerCardView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct CareerCardView: View {
    let career: Career
    let onTap: () -> Void
    let onStartQuest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with emoji and title
            HStack {
                Text(career.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 2) {
                    Text(career.title)
                        .font(.dreamSubheader)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)

                    Text(career.summary)
                        .font(.dreamCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
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

            // Salary chips
            HStack(spacing: 8) {
                SalaryChip(level: "Entry", amount: career.salary.entryFormatted)
                SalaryChip(level: "Mid", amount: career.salary.midFormatted)
                SalaryChip(level: "Top", amount: career.salary.topFormatted)

                Spacer()
            }

            // Power meters
            VStack(spacing: 6) {
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

            // Action buttons
            HStack(spacing: 12) {
                Button("Learn More") {
                    onTap()
                }
                .dreamButton(style: .outline)

                Button("Start Quest") {
                    onStartQuest()
                }
                .dreamButton(style: .primary)
            }
        }
        .padding(Layout.cardPadding)
        .dreamCard()
        .onTapGesture {
            onTap()
        }
    }
}

struct CategoryChip: View {
    let category: Career.CareerCategory

    var body: some View {
        Text(category.rawValue)
            .font(.dreamSmall)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.categoryColor(for: category))
            .cornerRadius(8)
    }
}

struct SalaryChip: View {
    let level: String
    let amount: String

    var body: some View {
        VStack(spacing: 2) {
            Text(level)
                .font(.dreamSmall)
                .foregroundColor(.textSecondary)
            Text(amount)
                .font(.dreamCaption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.backgroundTertiary)
        .cornerRadius(6)
    }
}

struct PowerMeterRow: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.dreamSmall)
                .foregroundColor(.textSecondary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Layout.powerMeterHeight / 2)
                        .fill(Color.backgroundTertiary)
                        .frame(height: Layout.powerMeterHeight)

                    RoundedRectangle(cornerRadius: Layout.powerMeterHeight / 2)
                        .fill(color)
                        .frame(width: geometry.size.width * (Double(value) / 100.0), height: Layout.powerMeterHeight)
                }
            }
            .frame(width: Layout.powerMeterWidth, height: Layout.powerMeterHeight)

            Text("\(value)")
                .font(.dreamSmall)
                .foregroundColor(.textSecondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

#Preview {
    let sampleCareer = Career(
        id: "1",
        title: "Software Developer",
        summary: "Create amazing apps and websites that people use every day",
        categories: [.tech, .science],
        salary: SalaryBand(entry: 50000, mid: 80000, top: 120_000),
        power: PowerMeters(creativity: 70, tech: 95, leadership: 40, adventure: 30),
        education: EducationInfo(paths: [], prerequisites: []),
        activities: [],
        quizTags: ["tech", "creative", "analytical"],
        resources: [],
        programs: [],
        emoji: "💻",
        questSteps: []
    )

    CareerCardView(
        career: sampleCareer,
        onTap: {},
        onStartQuest: {}
    )
    .padding()
}
