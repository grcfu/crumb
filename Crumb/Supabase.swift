//
//  Supabase.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import Foundation
import Supabase

class AppManager {
    static let shared = AppManager()
    
    // REPLACE THESE WITH YOUR KEYS FROM STEP 1
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://sgknghmpgqzpokbjrgnw.supabase.co")!,
        supabaseKey: "sb_publishable_g-5EM6bBkanD3cVrt8Hz4w_xcLJpR_I"
    )
    
    private init() {}
}
