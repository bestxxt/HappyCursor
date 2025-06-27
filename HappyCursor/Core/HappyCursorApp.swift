//
//  HappyCursorApp.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI
import Cocoa

@main
struct HappyCursorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openSettings) private var openSettings
    @State private var showMenuBar = true
    @State private var didOpenSettings = false
    
    var body: some Scene {
        // 状态栏菜单
        MenuBarExtra(isInserted: $showMenuBar) {
            StatusBarMenuView()
                .environmentObject(appDelegate)
        } label: {
            Image("bar_icon")
                .resizable()
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: Notification.Name("OpenSettings"),
                        object: nil
                    )
                ) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        openSettings()
                    }
                }
                .onAppear {
                    if !didOpenSettings {
                        didOpenSettings = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            openSettings()
                        }
                    }
                }
        }
        .menuBarExtraStyle(.menu)
        
        // 设置界面
        Settings {
            ContentView()
                .environmentObject(appDelegate)
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultPosition(.center)
    }
}
