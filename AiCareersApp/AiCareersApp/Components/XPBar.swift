//
//  XPBar.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData

struct XPBar: View {
    let currentXP: Int
    let level: Int
    let xpManager: XPManager
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Level \(level)")
                    .font(.dreamLevel)
                    .foregroundColor(.textSecondary)

                Spacer()

                Text("\(currentXP) XP")
                    .font(.dreamXP)
                    .foregroundColor(.xpGold)
                    .fontWeight(.bold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Layout.powerMeterHeight / 2)
                        .fill(Color.backgroundTertiary)
                        .frame(height: Layout.xpBarHeight)

                    // Progress bar
                    RoundedRectangle(cornerRadius: Layout.xpBarHeight / 2)
                        .fill(Color.skyGradient)
                        .frame(width: geometry.size.width * animatedProgress, height: Layout.xpBarHeight)
                        .animation(.easeInOut(duration: 1.0), value: animatedProgress)
                }
            }
            .frame(height: Layout.xpBarHeight)

            HStack {
                Text("Next level: \(xpManager.xpForNextLevel(currentLevel: level, totalXP: currentXP)) XP")
                    .font(.dreamSmall)
                    .foregroundColor(.textTertiary)

                Spacer()
            }
        }
        .onAppear {
            animatedProgress = xpManager.xpProgressForCurrentLevel(currentLevel: level, totalXP: currentXP)
        }
        .onChange(of: currentXP) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = xpManager.xpProgressForCurrentLevel(currentLevel: level, totalXP: newValue)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        XPBar(
            currentXP: 150,
            level: 2,
            xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self)))
        )
        .padding()

        XPBar(
            currentXP: 450,
            level: 4,
            xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self)))
        )
        .padding()
    }
    .background(Color.backgroundPrimary)
}
