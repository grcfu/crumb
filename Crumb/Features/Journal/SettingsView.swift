//
//  SettingsView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

// Features/Journal/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isMetric = true
    @State private var kitchenModeOn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Voice Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("THE CHEF (AI VOICE)").font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                            HStack(spacing: 12) {
                                VoiceCard(name: "Grandma", desc: "Warm & Sweet", icon: "eyeglasses", isSelected: false)
                                VoiceCard(name: "Sous Chef", desc: "Precise & Pro", icon: "mustache.fill", isSelected: true)
                                VoiceCard(name: "Bot", desc: "Concise", icon: "desktopcomputer", isSelected: false)
                            }
                        }
                        
                        // Display & Units
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DISPLAY & UNITS").font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                            
                            VStack(spacing: 1) {
                                ToggleRow(icon: "scalemass.fill", title: "Units", subtitle: "Measurement System") {
                                    HStack(spacing: 0) {
                                        Text("Metric").font(.caption).fontWeight(.bold).padding(6).background(Color.forestGreen).foregroundColor(.white).cornerRadius(4)
                                        Text("Imp.").font(.caption).padding(6)
                                    }
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                                }
                                
                                Divider().padding(.leading, 50)
                                
                                ToggleRow(icon: "sun.max.fill", title: "Kitchen Mode", subtitle: "Keep screen awake") {
                                    Toggle("", isOn: $kitchenModeOn).labelsHidden()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        
                        // Account
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACCOUNT").font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                            
                            VStack(spacing: 1) {
                                NavRow(icon: "leaf.fill", title: "Dietary Restrictions")
                                Divider().padding(.leading, 50)
                                NavRow(icon: "square.and.arrow.up.fill", title: "Export My Recipes")
                                Divider().padding(.leading, 50)
                                NavRow(icon: "questionmark.circle.fill", title: "Support & FAQ")
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        
                        Button("Sign Out") { }
                            .foregroundColor(.terracotta)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Kitchen Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct VoiceCard: View {
    let name: String
    let desc: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .forestGreen)
            Text(name).fontWeight(.bold)
            Text(desc).font(.caption2)
        }
        .foregroundColor(isSelected ? .white : .forestGreen)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color.forestGreen : Color.white)
        .cornerRadius(16)
    }
}

struct ToggleRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.mediumGray)
            VStack(alignment: .leading) {
                Text(title).fontWeight(.medium).foregroundColor(.forestGreen)
                Text(subtitle).font(.caption).foregroundColor(.mediumGray)
            }
            Spacer()
            content
        }
        .padding()
    }
}

struct NavRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.forestGreen)
            Text(title).fontWeight(.medium).foregroundColor(.forestGreen)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.lightGray)
        }
        .padding()
    }
}
