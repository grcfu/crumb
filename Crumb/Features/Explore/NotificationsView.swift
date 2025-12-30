//
//  NotificationsView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Social", "System", "Challenges"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Unified Background
                BakersTableBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 2. Custom Aesthetic Header
                    HStack {
                        Text("Notifications")
                            .font(.system(size: 32, weight: .bold, design: .serif)) // Matches Explore Title
                            .foregroundColor(.forestGreen)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.forestGreen.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    .background(Color.cream.opacity(0.8).blur(radius: 10)) // Frosted glass effect behind header
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 3. Filter Chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(filters, id: \.self) { filter in
                                        FilterChip(text: filter, isSelected: selectedFilter == filter) {
                                            withAnimation(.spring()) {
                                                selectedFilter = filter
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // 4. "New" Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("New")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.mediumGray)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 16) {
                                    NotificationCard(
                                        icon: "trophy.fill",
                                        color: .golden,
                                        title: "Sourdough Feed",
                                        message: "Timer is up! Time to stretch and fold.",
                                        time: "2m ago",
                                        isUnread: true
                                    )
                                    
                                    NotificationCard(
                                        icon: "heart.fill",
                                        color: .terracotta,
                                        title: "New Like",
                                        message: "Erin liked your Lemon Tart.",
                                        time: "5m ago",
                                        isUnread: true
                                    )
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // 5. "Earlier" Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Earlier")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.mediumGray)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 16) {
                                    NotificationCard(
                                        icon: "flame.fill",
                                        color: .forestGreen,
                                        title: "Challenge Ending",
                                        message: "24 hours left to submit your Focaccia.",
                                        time: "1d ago",
                                        isUnread: false
                                    )
                                    
                                    NotificationCard(
                                        icon: "person.2.fill",
                                        color: .sageGreen,
                                        title: "New Follower",
                                        message: "Marcus started following your recipes.",
                                        time: "3d ago",
                                        isUnread: false
                                    )
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true) // We made our own custom header
        }
    }
}

// MARK: - Aesthetic Notification Card
struct NotificationCard: View {
    let icon: String
    let color: Color
    let title: String
    let message: String
    let time: String
    let isUnread: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Bubble
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.forestGreen)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.lightGray)
                        .fontWeight(.medium)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.mediumGray)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Unread Dot
            if isUnread {
                Circle()
                    .fill(Color.terracotta)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9)) // Slightly translucent
        .cornerRadius(20)
        // Soft Shadow
        .shadow(color: Color.forestGreen.opacity(0.08), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isUnread ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Aesthetic Filter Chip
struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.forestGreen : Color.white)
                .foregroundColor(isSelected ? .white : .forestGreen)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.forestGreen.opacity(0.1), lineWidth: 1)
                )
        }
    }
}
