//
//  HapticManager.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import Foundation
import AppKit

/// Haptic feedback manager
/// Responsible for managing various haptic feedback effects in the application
class HapticManager: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance
    static let shared = HapticManager()
    
    // MARK: - Properties
    
    /// System haptic feedback manager
    private let hapticManager = NSHapticFeedbackManager.defaultPerformer
    
    // MARK: - Initialization
    
    private init() {
        print("🎯 Haptic feedback manager initialized")
    }
    
    // MARK: - Haptic Feedback Methods
    
    /// Trigger generic haptic feedback
    /// Suitable for general user interaction feedback
    func triggerGenericHaptic() {
        hapticManager.perform(.generic, performanceTime: .now)
    }
    
    /// Trigger alignment haptic feedback
    /// Suitable for feedback when elements are aligned or snapped
    func triggerAlignmentHaptic() {
        hapticManager.perform(.alignment, performanceTime: .now)
    }
    
    /// Trigger level change haptic feedback
    /// Suitable for feedback when values or levels change
    func triggerLevelChangeHaptic() {
        hapticManager.perform(.levelChange, performanceTime: .now)
    }
    
    /// Trigger continuous haptic feedback
    /// - Parameter duration: Duration (seconds)
    func triggerContinuousHaptic(duration: TimeInterval = 1.0) {
        let startTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if Date().timeIntervalSince(startTime) >= duration {
                timer.invalidate()
                return
            }
            self.hapticManager.perform(.generic, performanceTime: .now)
        }
    }
    
    /// Trigger haptic feedback sequence
    /// Trigger different types of haptic feedback in sequence
    func triggerHapticSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.triggerGenericHaptic()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.triggerAlignmentHaptic()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.triggerLevelChangeHaptic()
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if device supports haptic feedback
    /// - Returns: Whether haptic feedback is supported
    func isHapticFeedbackSupported() -> Bool {
        // NSHapticFeedbackManager.defaultPerformer always returns a valid object,
        // if hardware doesn't support it, calling perform will fail silently.
        // Therefore, we assume it's always supported.
        return true
    }
    
    /// Get haptic feedback status information
    /// - Returns: Status description string
    func getHapticStatus() -> String {
        if isHapticFeedbackSupported() {
            return "✅ Haptic feedback enabled"
        } else {
            return "⚠️ Current device doesn't support haptic feedback"
        }
    }
} 