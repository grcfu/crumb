//
//  Color+Extensions.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

extension Color {
    // MARK: - Core Colors (The "Anchor")
    
    /// Forest Green (#3E5641) - Main headings, tab titles, primary buttons. Replaces black text.
    static let forestGreen = Color(hex: "3E5641")
    
    // MARK: - Backgrounds
    
    /// Creamed Butter (#F9F4E8) - Main app background (lightened from Warm Beige for better contrast)
    static let creamedButter = Color(hex: "F9F4E8")
    
    /// Cream - Alias for creamedButter
    static let cream = Color.creamedButter
    
    /// Warm Beige (#EAD2AC) - Cards and tab bar background
    static let warmBeige = Color(hex: "EAD2AC")
    
    /// Sage Green - A softer green for secondary actions
    static let sageGreen = Color(hex: "8A9A5B")
    
    // MARK: - Action Colors
    
    /// Pistachio (#C0CAAD) - Secondary buttons (like "Save," "Filter") and tags (e.g., "Vegetarian")
    static let pistachio = Color(hex: "C0CAAD")
    
    /// Burnt Sienna (#A0520E) - Notifications, high-energy items, timers, leaderboard numbers
    static let burntSienna = Color(hex: "A0520E")
    
    /// Terracotta (#C97C5D) - Heart/like icons, profile accents, badges, challenge gradients
    static let terracotta = Color(hex: "C97C5D")
    
    // MARK: - Kitchen Mode (Dark Mode Exception)
    
    /// True Black (#000000) - Kitchen mode background (keeps battery usage low)
    static let kitchenBlack = Color(hex: "000000")
    
    /// Warm Beige Text - Text color in kitchen mode (softer on eyes than white)
    static let kitchenText = Color.warmBeige
    
    /// Terracotta Alerts - Timer/alerts in kitchen mode (visible but not blinding)
    static let kitchenAlert = Color.terracotta
    
    // MARK: - Utility Colors
    
    /// White - For text on colored backgrounds
    static let crumbWhite = Color.white
    
    /// Light Gray - For secondary text and subtle dividers
    static let lightGray = Color(hex: "9E9E9E")
    
    /// Medium Gray - For disabled states
    static let mediumGray = Color(hex: "757575")
    
    /// Golden Yellow - For leaderboard points and achievement badges
    static let golden = Color(hex: "F4D03F")
    
    // MARK: - Convenience Initializer
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

