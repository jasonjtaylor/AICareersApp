//
//  ExploreView.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftUI
import SwiftData
import Combine

struct ExploreView: View {
    let dataManager: DataManager
    let xpManager: XPManager
    let userProfile: UserProfile

    @State private var searchText = ""
    @State private var selectedCategory: Career.CareerCategory?
    @State private var selectedCareer: Career?
    @State private var showingCareerDetail = false
    @State private var showingQuest = false

    private var filteredCareers: [Career] {
        var careers = dataManager.careers

        // Filter by category
        if let category = selectedCategory {
            careers = careers.filter { $0.categories.contains(category) }
        }

        // Filter by search text
        if !searchText.isEmpty {
            careers = careers.filter { career in
                career.title.localizedCaseInsensitiveContains(searchText) ||
                    career.summary.localizedCaseInsensitiveContains(searchText) ||
                    career.categories.contains { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return careers
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchSection

                // Category chips
                categorySection

                // Careers grid
                careersSection
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Explore Careers")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCareerDetail) {
            if let career = selectedCareer {
                CareerDetailView(
                    career: career,
                    dataManager: dataManager,
                    onStartQuest: {
                        showingCareerDetail = false
                        showingQuest = true
                    }
                )
            }
        }
        .sheet(isPresented: $showingQuest) {
            if let career = selectedCareer {
                QuestView(
                    career: career,
                    userProfile: userProfile,
                    xpManager: xpManager
                )
            }
        }
    }

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)

            TextField("Search careers...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.dreamBody)
        }
        .padding()
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusM)
        .padding(.horizontal)
        .padding(.top)
    }

    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryFilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(Career.CareerCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var careersSection: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(filteredCareers, id: \.id) { career in
                    CareerCardView(
                        career: career,
                        onTap: {
                            selectedCareer = career
                            showingCareerDetail = true
                        },
                        onStartQuest: {
                            selectedCareer = career
                            showingQuest = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.dreamCaption)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.dreamBlue : Color.backgroundSecondary
                )
                .cornerRadius(20)
                .dreamShadowSmall()
        }
    }
}

#Preview {
    ExploreView(
        dataManager: DataManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        xpManager: XPManager(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))),
        userProfile: UserProfile(displayName: "Alex", ageMode: .teen)
    )
}
