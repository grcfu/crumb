//
//  MainTabView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI
import Combine

enum Tab: String, CaseIterable {
    case explore = "Explore"
    case cookbook = "Cookbook"
    case community = "Social"
    case journal = "Profile"
}

// 1. GLOBAL TAB MANAGER
class TabManager: ObservableObject {
    static let shared = TabManager()
    
    @Published var selectedTab: Tab = .explore
    @Published var shouldDismissSheets = false // <--- NEW TRIGGER
    
    private init() {}
}

struct MainTabView: View {
    // 2. LISTEN TO THE GLOBAL MANAGER
    @StateObject private var tabManager = TabManager.shared
    @Namespace private var animationNamespace
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $tabManager.selectedTab) { // Bound to Manager
                ExploreView()
                    .tag(Tab.explore)
                    .toolbar(.hidden, for: .tabBar)
                
                CookbookView()
                    .tag(Tab.cookbook)
                    .toolbar(.hidden, for: .tabBar)
                
                CommunityView()
                    .tag(Tab.community)
                    .toolbar(.hidden, for: .tabBar)
                
                JournalView()
                    .tag(Tab.journal)
                    .toolbar(.hidden, for: .tabBar)
            }
            
            // The Docked Tab Bar
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [Color.cream.opacity(0), Color.cream]),
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 100).allowsHitTesting(false).ignoresSafeArea()
                
                HStack(spacing: 0) {
                    TabButton(tab: .explore, icon: "house.fill", selectedTab: $tabManager.selectedTab, namespace: animationNamespace)
                    TabButton(tab: .cookbook, icon: "book.closed.fill", selectedTab: $tabManager.selectedTab, namespace: animationNamespace)
                    TabButton(tab: .community, icon: "trophy.fill", selectedTab: $tabManager.selectedTab, namespace: animationNamespace)
                    TabButton(tab: .journal, icon: "person.crop.circle", selectedTab: $tabManager.selectedTab, namespace: animationNamespace)
                }
                .padding(.top, 14)
                .padding(.horizontal, 24)
                .background(
                    Color.white.opacity(0.95)
                        .cornerRadius(35, corners: [.topLeft, .topRight])
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// Keep your Helper Extensions unchanged
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct TabButton: View {
    var tab: Tab
    var icon: String
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(selectedTab == tab ? .forestGreen : .lightGray)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(selectedTab == tab ? .forestGreen : .lightGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)
            .background(
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color.sageGreen.opacity(0.2))
                            .matchedGeometryEffect(id: "TabBubble", in: namespace)
                            .frame(height: 50)
                            .offset(y: -2)
                    }
                }
            )
        }
    }
}
