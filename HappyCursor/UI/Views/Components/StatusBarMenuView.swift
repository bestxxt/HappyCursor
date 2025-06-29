//
//  StatusBarMenuView.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI

struct StatusBarMenuView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var isCursorControlEnabled: Bool = AppDelegate.enableCursorControl
    @State private var isHapticFeedbackEnabled: Bool = AppDelegate.enableHapticFeedback
    
    var body: some View {
        Group {
            // Application title

            Text("HappyCursor".localized)
                .font(.headline)
                .foregroundColor(.primary) // Changed to black

            .padding(.vertical, 2)
            
            Divider()
            
            // Cursor control toggle
            Button(action: toggleCursorControl) {
                Label {
                    Text(isCursorControlEnabled ? "Disable Cursor Control".localized : "Enable Cursor Control".localized)
                        .foregroundColor(isCursorControlEnabled ? Color(red: 0.0, green: 0.6, blue: 0.0) : Color(red: 0.8, green: 0.0, blue: 0.0))
                } icon: {
                    Image(systemName: "power")
                        .foregroundColor(isCursorControlEnabled ? Color(red: 0.0, green: 0.6, blue: 0.0) : Color(red: 0.8, green: 0.0, blue: 0.0))
                }
            }
            
            // Haptic feedback toggle
            Button(action: toggleHapticFeedback) {
                Label {
                    Text(isHapticFeedbackEnabled ? "Disable Haptic Feedback".localized : "Enable Haptic Feedback".localized)
                        .foregroundColor(isHapticFeedbackEnabled ? Color(red: 0.0, green: 0.6, blue: 0.0) : Color(red: 0.8, green: 0.0, blue: 0.0))
                } icon: {
                    Image(systemName: "waveform.path")
                        .foregroundColor(isHapticFeedbackEnabled ? Color(red: 0.0, green: 0.6, blue: 0.0) : Color(red: 0.8, green: 0.0, blue: 0.0))
                }
            }
            
            Divider()
            
            // Settings
            settingItem
            
            Divider()
            
            // About
            Button(action: showAbout) {
                Label("About HappyCursor".localized, systemImage: "info.circle")
            }
            
            // Quit
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit".localized, systemImage: "power.circle")
            }
            .keyboardShortcut("q")
        }
        .labelStyle(.titleAndIcon)
        .onAppear {
            updateStates()
        }
    }
    
    @ViewBuilder private var settingItem: some View {
        if #available(macOS 14.0, *) {
            // macOS 14+ use SettingsLink
            SettingsLink {
                Label("Settings".localized, systemImage: "gearshape")
            }
        } else {
            // macOS 14 and below use traditional method
            Button(action: {
                NSApp.activate(ignoringOtherApps: true)
                NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
            }) {
                Label("Settings".localized, systemImage: "gearshape")
            }
            .keyboardShortcut(",")
        }
    }
    
    private func toggleCursorControl() {
        let newValue = !isCursorControlEnabled
        isCursorControlEnabled = newValue
        AppDelegate.enableCursorControl = newValue
        updateStates()
    }
    
    private func toggleHapticFeedback() {
        let newValue = !isHapticFeedbackEnabled
        isHapticFeedbackEnabled = newValue
        AppDelegate.enableHapticFeedback = newValue
        updateStates()
    }
    
    private func updateStates() {
        isCursorControlEnabled = AppDelegate.enableCursorControl
        isHapticFeedbackEnabled = AppDelegate.enableHapticFeedback
    }
    
    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "HappyCursor".localized
        alert.informativeText = "AboutText".localized
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK".localized)
        alert.runModal()
    }
} 
