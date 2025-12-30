//
//  ChallengeSubmissionView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct ChallengeSubmissionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var hydrationNotes = ""
    @State private var checks = [false, false, false]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background (Cozy Cream)
                Color.cream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Header Card
                        VStack(spacing: 12) {
                            Image(systemName: "trophy.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.golden)
                                .background(Circle().fill(Color.white).padding(2))
                                .shadow(color: .golden.opacity(0.3), radius: 10)
                            
                            Text("The Sourdough\nStarter Challenge")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.forestGreen)
                            
                            HStack {
                                Text("WEEK 42")
                                    .fontWeight(.bold)
                                    .foregroundColor(.terracotta)
                                Text("•")
                                    .foregroundColor(.lightGray)
                                Text("EXPERT")
                                    .fontWeight(.bold)
                                    .foregroundColor(.forestGreen)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Photo Evidence
                        VStack(alignment: .leading, spacing: 16) {
                            Label("THE EVIDENCE", systemImage: "camera.fill")
                                .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 16) {
                                PhotoSlot(label: "The Loaf (Exterior)")
                                PhotoSlot(label: "The Crumb (Interior)")
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: - Baker's Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Label("BAKER'S NOTES", systemImage: "pencil.line")
                                .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                            
                            TextEditor(text: $hydrationNotes)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .frame(height: 120)
                                .background(Color.white)
                                .cornerRadius(16)
                                .foregroundColor(.forestGreen)
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                                .overlay(
                                    Text("Tell the judges about your hydration levels, flour blend, and proofing time...")
                                        .foregroundColor(.mediumGray.opacity(0.5))
                                        .padding(16)
                                        .allowsHitTesting(false)
                                        .opacity(hydrationNotes.isEmpty ? 1 : 0),
                                    alignment: .topLeading
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // MARK: - The Baker's Oath (Verification)
                        VStack(alignment: .leading, spacing: 16) {
                            Label("THE BAKER'S OATH", systemImage: "hand.raised.fill")
                                .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                            
                            VStack(spacing: 0) {
                                CheckBoxRow(isChecked: $checks[0], text: "I certify I used wild yeast only")
                                Divider().background(Color.cream)
                                CheckBoxRow(isChecked: $checks[1], text: "No commercial additives used")
                                Divider().background(Color.cream)
                                CheckBoxRow(isChecked: $checks[2], text: "Baked within the last 24 hours")
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                        .padding(.horizontal, 24)
                        
                        // MARK: - Submit Button
                        Button(action: { dismiss() }) {
                            Text("Submit for Judgment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.forestGreen)
                                .cornerRadius(20)
                                .shadow(color: .forestGreen.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.mediumGray)
                }
            }
        }
    }
}

// MARK: - Subviews

struct PhotoSlot: View {
    let label: String
    var body: some View {
        Button(action: { /* Trigger Photo Picker */ }) {
            VStack {
                ZStack {
                    // Base Card
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .aspectRatio(1, contentMode: .fit)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    
                    // Dashed Border (Placeholder feel)
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                        .foregroundColor(.terracotta.opacity(0.3))
                        .padding(4)
                    
                    // Icon
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color.terracotta.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "camera.fill").foregroundColor(.terracotta))
                        
                        Text("Tap to add")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.terracotta)
                    }
                }
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.forestGreen)
                    .padding(.top, 4)
            }
        }
    }
}

struct CheckBoxRow: View {
    @Binding var isChecked: Bool
    let text: String
    
    var body: some View {
        Button(action: { withAnimation(.spring()) { isChecked.toggle() } }) {
            HStack(spacing: 16) {
                // Custom Checkbox
                ZStack {
                    Circle()
                        .stroke(isChecked ? Color.forestGreen : Color.lightGray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Circle()
                            .fill(Color.forestGreen)
                            .frame(width: 14, height: 14)
                    }
                }
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(isChecked ? .forestGreen : .mediumGray)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .contentShape(Rectangle()) // Makes the whole row tappable
        }
    }
}

#if DEBUG
#Preview {
    ChallengeSubmissionView()
}
#endif
