//
//  ProgressRing.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color
    let backgroundColor: Color

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        size: CGFloat = 80,
        color: Color = .dreamBlue,
        backgroundColor: Color = .backgroundTertiary
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: animatedProgress)

            // Center content
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.dreamCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

struct QuestProgressRing: View {
    let completedSteps: Int
    let totalSteps: Int
    let size: CGFloat

    private var progress: Double {
        guard totalSteps > 0 else { return 0.0 }
        return Double(completedSteps) / Double(totalSteps)
    }

    var body: some View {
        ZStack {
            ProgressRing(
                progress: progress,
                lineWidth: 6,
                size: size,
                color: .green,
                backgroundColor: .backgroundTertiary
            )

            VStack(spacing: 2) {
                Text("\(completedSteps)")
                    .font(.dreamHeader)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)

                Text("of \(totalSteps)")
                    .font(.dreamSmall)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct StreakRing: View {
    let streakCount: Int
    let size: CGFloat

    var body: some View {
        ZStack {
            ProgressRing(
                progress: min(1.0, Double(streakCount) / 7.0), // 7 days = full ring
                lineWidth: 6,
                size: size,
                color: .streakOrange,
                backgroundColor: .backgroundTertiary
            )

            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.streakOrange)

                Text("\(streakCount)")
                    .font(.dreamCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            ProgressRing(progress: 0.3, size: 60)
            ProgressRing(progress: 0.7, size: 80, color: .dreamOrange)
            ProgressRing(progress: 1.0, size: 100, color: .green)
        }

        HStack(spacing: 20) {
            QuestProgressRing(completedSteps: 2, totalSteps: 4, size: 80)
            StreakRing(streakCount: 5, size: 80)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
