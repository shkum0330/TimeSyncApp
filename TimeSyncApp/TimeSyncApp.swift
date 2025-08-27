//
//  TimeSyncAppApp.swift
//  TimeSyncApp
//
//  Created by sehyun on 8/20/25.
//

import SwiftUI

@main
struct TimeSyncAppApp: App {
    @StateObject private var syncManager = TimeSyncManager()
        
        var body: some Scene {
            MenuBarExtra("TimeSyncApp", systemImage: "clock") {
                ContentView()
                    .environmentObject(syncManager)
            }
        }
}
