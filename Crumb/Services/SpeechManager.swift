//
//  SpeechManager.swift
//  Crumb
//
//  Created by Grace Fu on 12/27/25.
//

import Foundation
import Speech
import AVFoundation
import SwiftUI
import Combine

enum VoiceCommand: Equatable {
    case nextStep
    case previousStep
    case readInstruction
    case ingredientQuery(String)
    case stopSpeaking
    case none
}

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    static let shared = SpeechManager()
    
    @Published var isListening = false
    @Published var transcript: String = ""
    @Published var lastCommand: VoiceCommand = .none
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var isProcessingCommand = false
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - 1. Smart Start (The Fix)
    func startListening() {
        // If already running, do nothing
        if audioEngine.isRunning { return }
        
        // CHECK PERMISSIONS FIRST
        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .notDetermined:
            // If we haven't asked yet, ask NOW, then start if allowed
            SFSpeechRecognizer.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.activateAudioSessionAndListen()
                    }
                }
            }
        case .authorized:
            // Already allowed? Just start.
            activateAudioSessionAndListen()
        case .denied, .restricted:
            print("🚫 Speech permission previously denied.")
        @unknown default:
            break
        }
    }
    
    // MARK: - 2. The Actual Logic (Private)
    private func activateAudioSessionAndListen() {
        // Reset state
        lastCommand = .none
        transcript = ""
        isProcessingCommand = false
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Session Error: \(error)")
            return // Stop if session fails
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.requiresOnDeviceRecognition = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                self.processCommand(text: self.transcript)
            }
            
            if error != nil || (result?.isFinal ?? false) {
                if !self.isProcessingCommand {
                    self.stopListening()
                }
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        // Check if tap already exists to prevent crash
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            print("👂 Jarvis is listening...")
        } catch {
            print("Engine Start Error: \(error)")
        }
    }
    
    // MARK: - 3. Stop Listening
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    // MARK: - 4. Command Logic
    private func processCommand(text: String) {
        let lower = text.lowercased()
        var commandFound: VoiceCommand = .none
        var responseText: String? = nil
        
        if lower.contains("stop") || lower.contains("quiet") {
            commandFound = .stopSpeaking
        } else if lower.contains("next") || lower.contains("done") {
            commandFound = .nextStep
            responseText = "Moving on."
        } else if lower.contains("back") || lower.contains("previous") {
            commandFound = .previousStep
            responseText = "Previous step."
        } else if lower.contains("read") || lower.contains("repeat") {
            commandFound = .readInstruction
        }
        
        if commandFound != .none {
            print("✅ Executing: \(commandFound)")
            isProcessingCommand = true
            stopListening()
            
            lastCommand = commandFound
            
            if commandFound == .stopSpeaking {
                stopSpeaking()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.startListening() }
            } else if let response = responseText {
                speak(response)
            }
        }
    }
    
    // MARK: - 5. Speech Synthesis
    func speak(_ text: String) {
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🤖 Finished speaking. Opening ears...")
        DispatchQueue.main.async {
            self.startListening()
        }
    }
    
    // Helper to request permission externally if needed
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
}
