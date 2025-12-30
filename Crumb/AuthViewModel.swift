//
//  AuthViewModel.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import SwiftUI
import Supabase
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // DELETE THIS LINE: var objectWillChange: ObservableObjectPublisher
    // Swift handles this automatically!
    
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    func signUp() async {
        do {
            let response = try await AppManager.shared.client.auth.signUp(
                email: email,
                password: password
            )
            print("Sign up successful: \(String(describing: response))")
            
            // ADD THIS LINE: Manually tell the app we are logged in
            self.isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn() async {
        do {
            try await AppManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        do {
            try await AppManager.shared.client.auth.signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error)")
        }
    }
    init() {
        Task {
            // Check if there is already a user session saved on the device
            let session = try? await AppManager.shared.client.auth.session
            self.isAuthenticated = session != nil
        }
    }
}
