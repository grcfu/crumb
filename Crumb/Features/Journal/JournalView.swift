//
//  JournalView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct JournalView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var showLogBake = false // New state for logging
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background
                JournalBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Custom Header
                        headerSection
                        
                        // 2. Profile Section (The Hero)
                        profileSection
                        
                        // 3. Statistics Section
                        statisticsSection
                        
                        // 4. Badges Section
                        badgesSection
                        
                        // 5. Past Bakes Grid (REAL DATA NOW)
                        pastBakesGrid
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            
            // MARK: - Sheets
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showLogBake) {
                LogBakeView()
            }
        }
        // Load Supabase recipes too (keeping your existing logic)
        .task {
            await recipeManager.fetchRecipes()
        }
    }
    
    // MARK: - Custom Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Kitchen")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                    
                    Text("The daily grind (and rise).")
                        .font(.subheadline)
                        .foregroundColor(.terracotta)
                }
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                        .foregroundColor(.forestGreen)
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Profile Section (Hero)
    private var profileSection: some View {
        ZStack {
            // Vibrant Gradient Card
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.terracotta, Color.burntSienna, Color.forestGreen.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.terracotta.opacity(0.4), radius: 15, y: 10)
            
            // Subtle Pattern Overlay on Card
            JournalPatternOverlay()
                .opacity(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(spacing: 20) {
                // Top Row: Image + Text + Edit
                HStack(alignment: .center, spacing: 16) {
                    // Profile Image
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            .frame(width: 84, height: 84)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        // Streak Badge (Floating)
                        Circle()
                            .fill(Color.golden)
                            .frame(width: 28, height: 28)
                            .overlay(Image(systemName: "flame.fill").font(.caption).foregroundColor(.white))
                            .offset(x: 28, y: 28)
                            .shadow(radius: 2)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Grace Fu")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text("Level 5 Baker")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        Text("Sourdough enthusiast & weekend patissier.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                Divider().background(Color.white.opacity(0.4))
                
                // Bottom Row: Edit Profile Button
                Button(action: { showEditProfile = true }) {
                    HStack {
                        Text("Edit Profile")
                            .fontWeight(.semibold)
                        Image(systemName: "pencil")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        HStack(spacing: 12) {
            // Updated stats to be dynamic based on PAST BAKES
            statCard(value: "\(recipeManager.pastBakes.count)", label: "BAKES", icon: "oven.fill", color: .forestGreen)
            statCard(value: "3", label: "WON", icon: "trophy.fill", color: .golden)
            statCard(value: "12", label: "FRIENDS", icon: "person.2.fill", color: .terracotta)
        }
        .padding(.horizontal, 20)
    }
    
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.forestGreen)
                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.lightGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 8, y: 4)
    }
    
    // MARK: - Content Grid (Past Bakes)
        private var pastBakesGrid: some View {
            VStack(alignment: .leading, spacing: 16) {
                
                // Section Header
                HStack {
                    Image(systemName: "photo.stack.fill")
                        .foregroundColor(.forestGreen)
                    Text("Past Bakes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                    Spacer()
                    Text("\(recipeManager.pastBakes.count) Total")
                        .font(.caption)
                        .foregroundColor(.terracotta)
                        .padding(6)
                        .background(Color.terracotta.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                // 3-column Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    
                    // 1. Add Bake Button (Strictly Square)
                    Button(action: { showLogBake = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.terracotta.opacity(0.15))
                            
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [6, 6])
                                )
                                .foregroundColor(.terracotta.opacity(0.8))
                            
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: Color.terracotta.opacity(0.15), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.terracotta)
                                    )
                                
                                Text("NEW")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.terracotta)
                                    .tracking(1.0)
                            }
                        }
                        // This forces the button to be a perfect square based on width
                        .aspectRatio(1, contentMode: .fit)
                    }
                    
                    // 2. Past Bakes (Strictly Square using Overlay Trick)
                    ForEach(recipeManager.pastBakes) { bake in
                        // We start with a clear base that sets the geometry
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Group {
                                    if let image = bake.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Rectangle().fill(Color.sageGreen.opacity(0.3))
                                            .overlay(Image(systemName: "photo").foregroundColor(.forestGreen))
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12)) // Clips the image to round corners
                            .overlay(
                                // Rating Stars Overlay (Bottom Right)
                                HStack(spacing: 2) {
                                    ForEach(0..<bake.rating, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(4)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(4)
                                .padding(4),
                                alignment: .bottomTrailing
                            )
                            .contentShape(Rectangle()) // Ensures tap area is correct
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badges")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.forestGreen)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    badgeCard(name: "Bread Winner", icon: "laurel.leading", color: .golden)
                    badgeCard(name: "Pastry Pro", icon: "birthday.cake.fill", color: .burntSienna)
                    badgeCard(name: "Early Riser", icon: "sun.max.fill", color: .terracotta)
                    badgeCard(name: "Sourdough Star", icon: "star.fill", color: .forestGreen)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func badgeCard(name: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            .overlay(
                Circle().stroke(color.opacity(0.3), lineWidth: 1)
            )
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.forestGreen)
                .multilineTextAlignment(.center)
                .frame(height: 35, alignment: .top)
                .lineLimit(2)
        }
        .frame(width: 80)
    }
}

// MARK: - JOURNAL BACKGROUND HELPERS (UNCHANGED)
struct JournalBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.cream, Color.warmBeige.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                BakingToolsPattern(spacing: 80)
                    .stroke(Color.terracotta.opacity(0.06), lineWidth: 1)
                
                ZStack {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 220))
                        .foregroundColor(.forestGreen.opacity(0.04))
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                        .rotationEffect(.degrees(-10))
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 180))
                        .foregroundColor(.terracotta.opacity(0.05))
                        .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.85)
                        .rotationEffect(.degrees(20))
                }
                
                ForEach(0..<20, id: \.self) { _ in
                    JournalParticle(screenSize: geometry.size)
                }
            }
        }
    }
}

struct JournalPatternOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, to: rect.width + rect.height, by: 20) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x - rect.height, y: rect.height))
        }
        return path
    }
}

struct BakingToolsPattern: Shape {
    let spacing: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, to: rect.width + spacing, by: spacing) {
            for y in stride(from: 0, to: rect.height + spacing, by: spacing) {
                path.move(to: CGPoint(x: x - 15, y: y))
                path.addLine(to: CGPoint(x: x + 15, y: y))
                path.move(to: CGPoint(x: x - 20, y: y)); path.addLine(to: CGPoint(x: x - 15, y: y))
                path.move(to: CGPoint(x: x + 15, y: y)); path.addLine(to: CGPoint(x: x + 20, y: y))
                
                let whiskX = x + spacing/2
                path.move(to: CGPoint(x: whiskX, y: y - 15))
                path.addCurve(to: CGPoint(x: whiskX, y: y + 15), control1: CGPoint(x: whiskX - 10, y: y), control2: CGPoint(x: whiskX + 10, y: y))
                path.move(to: CGPoint(x: whiskX, y: y - 15))
                path.addCurve(to: CGPoint(x: whiskX, y: y + 15), control1: CGPoint(x: whiskX - 5, y: y), control2: CGPoint(x: whiskX + 5, y: y))
            }
        }
        return path
    }
}

struct JournalParticle: View {
    let screenSize: CGSize
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    let isSparkle = Bool.random()
    
    var body: some View {
        Group {
            if isSparkle {
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 10...18)))
            } else {
                Circle()
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
            }
        }
        .foregroundColor(isSparkle ? .golden.opacity(0.6) : .lightGray.opacity(0.4))
        .position(position)
        .opacity(opacity)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            position = CGPoint(x: CGFloat.random(in: 0...screenSize.width), y: CGFloat.random(in: 0...screenSize.height))
            withAnimation(Animation.easeInOut(duration: Double.random(in: 10...20)).repeatForever(autoreverses: true)) {
                position.x += CGFloat.random(in: -30...30)
                position.y += CGFloat.random(in: -30...30)
                opacity = Double.random(in: 0.2...0.7)
                rotation = Double.random(in: 0...360)
            }
        }
    }
}

#if DEBUG
#Preview {
    JournalView()
        .environmentObject(RecipeManager())
}
#endif
