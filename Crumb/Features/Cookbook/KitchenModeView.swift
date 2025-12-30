//
//  KitchenModeView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct KitchenModeView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    
    // Connect to our Voice Brain
    @StateObject private var speechManager = SpeechManager.shared
    
    @State private var currentStepIndex = 0
    @State private var showVictory = false
    @State private var pulseAmount: CGFloat = 1.0
    
    // MARK: - THE FIX: Improved Sentence Splitting
    // This now splits by "." characters, regardless of spacing.
    var displaySteps: [String] {
        var brokenDown: [String] = []
        
        for step in recipe.steps {
            // 1. Replace potential confusing punctuation (like ! or ?) with periods to standardize
            let standardized = step.instruction
                .replacingOccurrences(of: "!", with: ".")
                .replacingOccurrences(of: "?", with: ".")
            
            // 2. Split strictly by "." (handles "Mix.Bake" where there is no space)
            let sentences = standardized
                .components(separatedBy: ".")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Clean up spaces
                .filter { !$0.isEmpty } // Remove empty strings caused by trailing periods
            
            for sentence in sentences {
                // 3. Add the period back for looks
                brokenDown.append(sentence + ".")
            }
        }
        
        // Fallback
        if brokenDown.isEmpty { return ["Ready to cook!"] }
        
        return brokenDown
    }
    
    var body: some View {
        ZStack {
            // 1. Dark Mode Background (OLED Saving)
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - Header
                HStack {
                    Button(action: {
                        speechManager.stopListening()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    // Updated Count
                    Text("Step \(currentStepIndex + 1) of \(displaySteps.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                // MARK: - The Instruction Card
                TabView(selection: $currentStepIndex) {
                    ForEach(Array(displaySteps.enumerated()), id: \.offset) { index, instruction in
                        VStack(spacing: 24) {
                            Text("STEP \(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.terracotta)
                                .tracking(2)
                            
                            Text(instruction)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                // MARK: - Live Voice Transcript
                if speechManager.isListening {
                    Text(speechManager.transcript.isEmpty ? "Listening..." : "“\(speechManager.transcript)”")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .animation(.easeInOut, value: speechManager.transcript)
                }
                
                Spacer()
                
                // MARK: - Controls Footer
                HStack(spacing: 50) {
                    // Back
                    Button(action: {
                        withAnimation {
                            if currentStepIndex > 0 { currentStepIndex -= 1 }
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Mic
                    Button(action: {
                        if speechManager.isListening {
                            speechManager.stopListening()
                        } else {
                            speechManager.startListening()
                        }
                    }) {
                        ZStack {
                            if speechManager.isListening {
                                Circle()
                                    .stroke(Color.terracotta.opacity(0.5), lineWidth: 2)
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(pulseAmount)
                                    .opacity(2 - pulseAmount)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                                            pulseAmount = 1.5
                                        }
                                    }
                            }
                            Circle()
                                .fill(speechManager.isListening ? Color.terracotta : Color.white.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: speechManager.isListening ? "mic.fill" : "mic.slash.fill")
                                .font(.largeTitle)
                                .foregroundColor(speechManager.isListening ? .white : .gray)
                        }
                    }
                    
                    // Next
                    Button(action: {
                        handleNextStep()
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.title)
                            .foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        
        // MARK: - VOICE COMMAND LISTENER
        .onChange(of: speechManager.lastCommand) { command in
            withAnimation(.spring()) {
                switch command {
                case .nextStep:
                    handleNextStep()
                case .previousStep:
                    if currentStepIndex > 0 { currentStepIndex -= 1 }
                case .readInstruction:
                    if displaySteps.indices.contains(currentStepIndex) {
                        speechManager.speak(displaySteps[currentStepIndex])
                    }
                default:
                    break
                }
            }
        }
        .sheet(isPresented: $showVictory) {
            VictoryView()
        }
    }
    
    func handleNextStep() {
        if currentStepIndex < displaySteps.count - 1 {
            currentStepIndex += 1
        } else {
            speechManager.stopListening()
            showVictory = true
        }
    }
}
