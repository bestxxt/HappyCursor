//
//  HapticManager.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import Foundation
import AppKit

/// 触觉反馈管理器
/// 负责管理应用中的各种触觉反馈效果
class HapticManager: ObservableObject {
    
    // MARK: - Singleton
    
    /// 共享实例
    static let shared = HapticManager()
    
    // MARK: - Properties
    
    /// 系统触觉反馈管理器
    private let hapticManager = NSHapticFeedbackManager.defaultPerformer
    
    // MARK: - Initialization
    
    private init() {
        print("🎯 触觉反馈管理器已初始化")
    }
    
    // MARK: - Haptic Feedback Methods
    
    /// 触发通用触觉反馈
    /// 适用于一般的用户交互反馈
    func triggerGenericHaptic() {
        hapticManager.perform(.generic, performanceTime: .now)
    }
    
    /// 触发对齐触觉反馈
    /// 适用于元素对齐或吸附时的反馈
    func triggerAlignmentHaptic() {
        hapticManager.perform(.alignment, performanceTime: .now)
    }
    
    /// 触发等级变化触觉反馈
    /// 适用于数值或等级变化时的反馈
    func triggerLevelChangeHaptic() {
        hapticManager.perform(.levelChange, performanceTime: .now)
    }
    
    /// 触发连续触觉反馈
    /// - Parameter duration: 持续时间（秒）
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
    
    /// 触发触觉反馈序列
    /// 依次触发不同类型的触觉反馈
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
    
    /// 检查设备是否支持触觉反馈
    /// - Returns: 是否支持触觉反馈
    func isHapticFeedbackSupported() -> Bool {
        // NSHapticFeedbackManager.defaultPerformer 总是返回一个有效的对象，
        // 如果硬件不支持，调用 perform 会静默失败。
        // 因此，我们假定它总是受支持的。
        return true
    }
    
    /// 获取触觉反馈状态信息
    /// - Returns: 状态描述字符串
    func getHapticStatus() -> String {
        if isHapticFeedbackSupported() {
            return "✅ 触觉反馈已启用"
        } else {
            return "⚠️ 当前设备不支持触觉反馈"
        }
    }
} 