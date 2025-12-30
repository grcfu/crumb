//
//  CommunityView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI
import Combine

// MARK: - Mock Data Model
struct SocialPost: Identifiable {
    let id = UUID()
    let username: String
    let avatarUrl: String
    let postImageUrl: String
    let timeAgo: String
    let title: String
    let notes: String
    let likes: Int
    let comments: Int
}

struct CommunityView: View {
    // Timer State
    @State private var daysRemaining = 2
    @State private var hoursRemaining = 14
    @State private var minutesRemaining = 35
    @State private var secondsRemaining = 0
    
    // Navigation State
    @State private var showSubmission = false
    @State private var showChallengeDetails = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - MOCK FEED DATA (New Examples)
    let posts: [SocialPost] = [
        SocialPost(
            username: "CrustFund",
            avatarUrl: "https://spoonacular.com/recipeImages/649195-556x370.jpg", // Bagel Avatar
            postImageUrl: "https://spoonacular.com/recipeImages/649195-636x393.jpg", // NYC Bagels
            timeAgo: "3h ago",
            title: "NYC Style Everything Bagels",
            notes: "Boiled in malt syrup water for 1 min per side. That shine is undeniable! Topped generously with homemade everything seasoning.",
            likes: 412,
            comments: 38
        ),
        SocialPost(
            username: "PieHard",
            avatarUrl: "https://spoonacular.com/recipeImages/632583-556x370.jpg", // Pie Avatar
            postImageUrl: "https://spoonacular.com/recipeImages/632583-636x393.jpg", // Apple Pie
            timeAgo: "6h ago",
            title: "Classic Lattice Apple Pie",
            notes: "Used a mix of Granny Smith and Honeycrisp apples. The secret to the crust? Vodka instead of water to stop gluten development!",
            likes: 890,
            comments: 102
        ),
        SocialPost(
            username: "CarrotTop",
            avatarUrl: "https://spoonacular.com/recipeImages/637162-556x370.jpg", // Cake Avatar
            postImageUrl: "https://spoonacular.com/recipeImages/637162-636x393.jpg", // Carrot Cake
            timeAgo: "2d ago",
            title: "Spiced Carrot Cake",
            notes: "Toasted the walnuts before folding them in. The cream cheese frosting has a touch of orange zest to cut the sweetness.",
            likes: 567,
            comments: 45
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background
                CommunityBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // 1. Header
                        headerSection
                        
                        // 2. Weekly Challenge Card
                        weeklyChallengeCard
                        
                        // 3. The Feed
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fresh from the Oven")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.forestGreen)
                                .padding(.horizontal, 20)
                            
                            LazyVStack(spacing: 24) {
                                ForEach(posts) { post in
                                    SocialPostCard(post: post)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSubmission) {
                ChallengeSubmissionView()
            }
            .sheet(isPresented: $showChallengeDetails) {
                ChallengeDetailView(
                    days: $daysRemaining,
                    hours: $hoursRemaining,
                    minutes: $minutesRemaining,
                    seconds: $secondsRemaining
                )
            }
            .onReceive(timer) { _ in
                updateCountdown()
            }
        }
    }
    
    // MARK: - Custom Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                    Text("Connect with fellow bakers.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.terracotta)
                }
                Spacer()
                HStack(spacing: 12) {
                    CircleButton(icon: "bell.fill")
                    CircleButton(icon: "magnifyingglass")
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Weekly Challenge Card
    private var weeklyChallengeCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill").font(.caption)
                Text("WEEKLY CHALLENGE").font(.caption).fontWeight(.bold)
            }
            .foregroundColor(.forestGreen)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.white).cornerRadius(20)
            
            VStack(spacing: 4) {
                Text("The Perfect Sourdough")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Text("Join 5,432 bakers currently proofing.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            HStack(spacing: 12) {
                countdownCircle(value: daysRemaining, label: "DAYS")
                countdownCircle(value: hoursRemaining, label: "HRS")
                countdownCircle(value: minutesRemaining, label: "MINS")
                countdownCircle(value: secondsRemaining, label: "SECS")
            }
            
            Button(action: { showSubmission = true }) {
                HStack {
                    Text("Submit Entry").fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.terracotta)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.terracotta, Color.burntSienna]), startPoint: .topLeading, endPoint: .bottomTrailing)
                GeometryReader { geo in
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 300, height: 300).blur(radius: 60).offset(x: -100, y: -100)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.terracotta.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 20)
        .onTapGesture { showChallengeDetails = true }
    }
    
    // MARK: - Helper Views
    private func countdownCircle(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value)).font(.title2).fontWeight(.bold).foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 60, height: 60)
        .background(Color.black.opacity(0.1))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
    
    private func updateCountdown() {
        if secondsRemaining > 0 { secondsRemaining -= 1 }
        else {
            secondsRemaining = 59
            if minutesRemaining > 0 { minutesRemaining -= 1 }
            else {
                minutesRemaining = 59
                if hoursRemaining > 0 { hoursRemaining -= 1 }
                else {
                    hoursRemaining = 23
                    if daysRemaining > 0 { daysRemaining -= 1 }
                }
            }
        }
    }
}

// MARK: - Social Post Card (Fixed Layout + Aesthetics)
struct SocialPostCard: View {
    let post: SocialPost
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. User Info Header
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: post.avatarUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.warmBeige
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.cream, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                    Text(post.timeAgo)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.mediumGray)
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundColor(.mediumGray)
            }
            .padding(16)
            
            // 2. Main Image (FIXED: GeometryReader + Spoonacular URL)
            GeometryReader { geometry in
                AsyncImage(url: URL(string: post.postImageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else if phase.error != nil {
                        ZStack {
                            Color.warmBeige
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.terracotta)
                        }
                    } else {
                        ZStack {
                            Color.warmBeige.opacity(0.5)
                            ProgressView().tint(.terracotta)
                        }
                    }
                }
            }
            .frame(height: 320)
            .cornerRadius(16)
            .padding(.horizontal, 12)
            
            // 3. Action Bar
            HStack(spacing: 20) {
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isLiked.toggle() } }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isLiked ? .terracotta : .forestGreen)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                    Text("\(post.comments)")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.forestGreen)
                
                Spacer()
                
                Image(systemName: "bookmark")
                    .font(.title3)
                    .foregroundColor(.forestGreen)
            }
            .padding(16)
            
            // 4. Content Area
            VStack(alignment: .leading, spacing: 12) {
                // Title & Likes
                HStack(alignment: .firstTextBaseline) {
                    Text(post.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                        .lineLimit(1)
                    Spacer()
                    Text("\(isLiked ? post.likes + 1 : post.likes) likes")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                }
                
                // Baker's Notes
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "pencil.line")
                            .font(.caption)
                            .foregroundColor(.terracotta)
                        Text("BAKER'S NOTES")
                            .font(.caption)
                            .fontWeight(.black)
                            .tracking(1)
                            .foregroundColor(.terracotta)
                    }
                    
                    Text(post.notes)
                        .font(.subheadline)
                        .foregroundColor(.mediumGray)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color.warmBeige.opacity(0.4))
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.06), radius: 15, y: 8)
        .padding(.horizontal, 20)
    }
}

// MARK: - Reusable Components
struct CircleButton: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.headline)
            .foregroundColor(.forestGreen)
            .frame(width: 48, height: 48)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

struct CommunityBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.cream, Color.warmBeige]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#if DEBUG
#Preview {
    CommunityView()
}
#endif
