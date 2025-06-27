//
//  AppDelegate.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import Cocoa

/// 应用代理类，负责全局事件监听和光标控制
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAccessibilityPermissionGranted: Bool = false {
        didSet {
            if isAccessibilityPermissionGranted {
                if eventTap == nil {
                    print("权限已授予，正在启动事件监听...")
                    setupEventTap()
                }
            } else {
                if eventTap != nil {
                    print("权限已撤销，正在停止事件监听...")
                    cleanupEventTap()
                }
            }
        }
    }
    
    // MARK: - Properties
    
    /// 事件监听器
    private var eventTap: CFMachPort?
    /// 运行循环源
    private var runLoopSource: CFRunLoopSource?
    
    // MARK: - Configuration Keys
    
    private struct ConfigKeys {
        static let moveThresholdX = "moveThresholdX"
        static let moveThresholdY = "moveThresholdY"
        static let hotkey = "hotkey"
        static let enableHorizontal = "enableHorizontal"
        static let enableVertical = "enableVertical"
        static let enableHapticFeedback = "enableHapticFeedback"
        static let enableCursorControl = "enableCursorControl"
        
        // 水平移动增强功能
        static let horizontalWordJump = "horizontalWordJump"
        static let horizontalBeginEnd = "horizontalBeginEnd"
        static let horizontalShift = "horizontalShift"
        
        // 垂直移动增强功能
        static let verticalWordJump = "verticalWordJump"
        static let verticalBeginEnd = "verticalBeginEnd"
        static let verticalShift = "verticalShift"
        
        // 新增：应用特定控制
        static let enableAppSpecificControl = "enableAppSpecificControl"
        static let enabledApps = "enabledApps"
    }
    
    // MARK: - Configuration
    
    /// 水平移动阈值（越小越灵敏）
    static var moveThresholdX: Double {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.moveThresholdX) as? Double) ?? 10.0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.moveThresholdX)
        }
    }
    
    /// 垂直移动阈值（越小越灵敏）
    static var moveThresholdY: Double {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.moveThresholdY) as? Double) ?? 20.0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.moveThresholdY)
        }
    }
    
    /// 当前选中的快捷键
    static var hotkey: ModifierKey {
        get {
            let rawValue = UserDefaults.standard.string(forKey: ConfigKeys.hotkey) ?? ModifierKey.command.rawValue
            return ModifierKey(rawValue: rawValue) ?? .command
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: ConfigKeys.hotkey)
        }
    }
    
    /// 是否启用水平移动
    static var enableHorizontal: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableHorizontal) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableHorizontal)
        }
    }
    
    /// 是否启用垂直移动
    static var enableVertical: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableVertical) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableVertical)
        }
    }
    
    /// 是否启用触觉反馈
    static var enableHapticFeedback: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableHapticFeedback) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableHapticFeedback)
        }
    }
    
    /// 是否启用光标控制（总开关）
    static var enableCursorControl: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.enableCursorControl) as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableCursorControl) }
    }
    
    // MARK: - 水平移动增强功能
    
    /// 水平移动是否启用按词移动 (Option)
    static var horizontalWordJump: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalWordJump) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalWordJump) }
    }
    
    /// 水平移动是否启用行首/尾移动 (Command)
    static var horizontalBeginEnd: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalBeginEnd) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalBeginEnd) }
    }
    
    /// 水平移动是否启用选中功能 (Shift)
    static var horizontalShift: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalShift) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalShift) }
    }
    
    // MARK: - 垂直移动增强功能
    
    /// 垂直移动是否启用行首/尾移动 (Command)
    static var verticalBeginEnd: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.verticalBeginEnd) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.verticalBeginEnd) }
    }
    
    /// 垂直移动是否启用选中功能 (Shift)
    static var verticalShift: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.verticalShift) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.verticalShift) }
    }
    
    /// 应用特定控制
    /// 是否启用应用特定控制（白名单）
    static var enableAppSpecificControl: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.enableAppSpecificControl) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableAppSpecificControl) }
    }
    
    /// 白名单应用（应用名）
    static var enabledApps: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: ConfigKeys.enabledApps) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: ConfigKeys.enabledApps)
        }
    }
    
    /// 获取所有已安装应用（应用名）
    static func getAllInstalledApps() -> [String] {
        let appDirs = ["/Applications", "/System/Applications", NSHomeDirectory() + "/Applications"]
        var allApps: Set<String> = []
        for dir in appDirs {
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: dir) {
                for item in contents where item.hasSuffix(".app") {
                    let appPath = dir + "/" + item
                    let appURL = URL(fileURLWithPath: appPath)
                    if let bundle = Bundle(url: appURL) {
                        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                        let name = displayName ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                        if let name = name {
                            allApps.insert(name)
                        }
                    }
                }
            }
        }
        return Array(allApps).sorted()
    }
    
    /// 判断当前激活应用是否在白名单
    static func isAppEnabledForCursorControl() -> Bool {
        guard let activeApp = NSWorkspace.shared.frontmostApplication else {
            return false
        }
        let appName = activeApp.localizedName ?? ""
        return enabledApps.contains(appName)
    }
    
    /// 修饰键类型枚举
    enum ModifierKey: String, CaseIterable, Identifiable {
        case shift = "Shift"
        case command = "Command"
        case option = "Option"
        
        var id: String { rawValue }
        
        /// 对应的NSEvent修饰键标志
        var flag: NSEvent.ModifierFlags {
            switch self {
            case .shift: return .shift
            case .command: return .command
            case .option: return .option
            }
        }
        
        /// 对应的CGEvent修饰键标志
        var cgFlag: CGEventFlags {
            switch self {
            case .shift: return .maskShift
            case .command: return .maskCommand
            case .option: return .maskAlternate
            }
        }
        
        /// 显示符号
        var symbol: String {
            switch self {
            case .shift: return "⇧ Shift"
            case .command: return "⌘ Command"
            case .option: return "⌥ Option"
            }
        }
    }
    
    // MARK: - State Management
    
    /// 水平方向累计移动量
    static var accumX: Double = 0.0
    /// 垂直方向累计移动量
    static var accumY: Double = 0.0
    /// 热键是否处于激活状态
    static var isHotkeyActive: Bool = false
    /// 热键激活时锁定的鼠标位置
    static var lockedMousePosition: CGPoint?
    
    /// 全局修饰键状态
    static var isCmdPressed: Bool = false
    static var isOptPressed: Bool = false
    static var isShiftPressed: Bool = false
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("HappyCursor 启动中...")
        
        // 设置应用为代理应用，支持状态栏模式
        NSApp.setActivationPolicy(.accessory)
        
        checkAccessibilityPermission()
        print("HappyCursor 启动完成")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("HappyCursor 正在关闭...")
        cleanupEventTap()
        print("HappyCursor 已关闭")
    }
    
    /// 防止窗口关闭时应用退出
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: - Settings Management
    
    /// 重置为默认设置
    static func resetToDefaultSettings() {
        UserDefaults.standard.set(10.0, forKey: ConfigKeys.moveThresholdX)
        UserDefaults.standard.set(10.0, forKey: ConfigKeys.moveThresholdY)
        UserDefaults.standard.set(ModifierKey.command.rawValue, forKey: ConfigKeys.hotkey)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableHorizontal)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableVertical)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableHapticFeedback)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableCursorControl)
        
        // 水平移动增强功能默认值
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalWordJump)
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalBeginEnd)
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalShift)
        
        // 垂直移动增强功能默认值
        UserDefaults.standard.set(false, forKey: ConfigKeys.verticalBeginEnd)
        UserDefaults.standard.set(false, forKey: ConfigKeys.verticalShift)
        
        print("配置已重置为默认值")
    }
    
    // MARK: - Accessibility Permission
    
    /// 检查辅助功能权限
    func checkAccessibilityPermission() {
        // 更新无障碍权限状态
        isAccessibilityPermissionGranted = AXIsProcessTrusted()
        
        if isAccessibilityPermissionGranted {
            setupEventTap()
        } else {
            cleanupEventTap()
        }
    }
    
    /// 打开辅助功能系统设置
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Event Handling Setup
    
    /// 设置全局事件监听
    private func setupEventTap() {
        // 监听鼠标移动和修饰键变化事件
        let mask = (1 << CGEventType.mouseMoved.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, event, refcon in
                let result = AppDelegate.handleEvent(proxy: proxy, type: type, event: event)
                if let result = result {
                    return Unmanaged.passRetained(result)
                } else {
                    return nil
                }
            },
            userInfo: nil
        )
        
        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("✅ 全局事件监听已启动")
        } else {
            print("❌ 全局事件监听启动失败")
        }
    }
    
    /// 清理事件监听器
    private func cleanupEventTap() {
        if let eventTap = eventTap {
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
    }
    
    // MARK: - Event Processing
    
    /// 处理全局事件
    static func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> CGEvent? {
        switch type {
        case .flagsChanged:
            return handleFlagsChanged(event: event)
        case .mouseMoved:
            return handleMouseMoved(event: event)
        default:
            return event
        }
    }
    
    /// 处理修饰键变化事件
    private static func handleFlagsChanged(event: CGEvent) -> CGEvent {
        let flags = event.flags
        
        // 更新全局修饰键状态
        isCmdPressed = flags.contains(.maskCommand)
        isOptPressed = flags.contains(.maskAlternate)
        isShiftPressed = flags.contains(.maskShift)
        
        let isHotkeyCurrentlyPressed = flags.contains(hotkey.cgFlag)
        
        if isHotkeyCurrentlyPressed && !isHotkeyActive {
            // 热键刚刚被按下
            isHotkeyActive = true
            lockedMousePosition = event.location
            print("热键已按下，锁定鼠标位置于: \(String(describing: lockedMousePosition))")
        } else if !isHotkeyCurrentlyPressed && isHotkeyActive {
            // 热键刚刚被释放
            isHotkeyActive = false
            lockedMousePosition = nil
            print("热键已释放，解除鼠标锁定。")
        }
        
        return event
    }
    
    /// 处理鼠标移动事件
    private static func handleMouseMoved(event:CGEvent) -> CGEvent? {
        // 检查光标控制是否启用
        guard enableCursorControl else { return event }
        // 检查应用特定控制
        if enableAppSpecificControl {
            guard isAppEnabledForCursorControl() else { return event }
        }
        
        guard isHotkeyActive, let lockedPos = lockedMousePosition else {
            return event
        }
        
        // 获取鼠标移动距离
        let deltaX = event.getDoubleValueField(.mouseEventDeltaX)
        let deltaY = event.getDoubleValueField(.mouseEventDeltaY)
        
        // 累加移动量
        accumX += deltaX
        accumY += deltaY
        
        // 处理水平移动
        if enableHorizontal {
            processHorizontalMovement()
        }
        
        // 处理垂直移动
        if enableVertical {
            processVerticalMovement()
        }
        
        // 将鼠标传送回锁定位置
        CGWarpMouseCursorPosition(lockedPos)
        
        // 阻止原事件（不让鼠标指针移动）
        return nil
    }
    
    /// 处理水平移动
    private static func processHorizontalMovement() {
        while abs(accumX) >= moveThresholdX {
            if accumX > 0 {
                sendArrowKey(left: false, isHorizontal: true) // 向右
                accumX -= moveThresholdX
                accumY = 0
            } else {
                sendArrowKey(left: true, isHorizontal: true)  // 向左
                accumX += moveThresholdX
                accumY = 0
            }
            if enableHapticFeedback {
                HapticManager.shared.triggerGenericHaptic()
            }
        }
    }
    
    /// 处理垂直移动
    private static func processVerticalMovement() {
        while abs(accumY) >= moveThresholdY {
            if accumY > 0 {
                sendArrowKey(up: false, isHorizontal: false)   // 向下
                accumY -= moveThresholdY
                accumX = 0
            } else {
                sendArrowKey(up: true, isHorizontal: false)    // 向上
                accumY += moveThresholdY
                accumX = 0
            }
            if enableHapticFeedback {
                HapticManager.shared.triggerGenericHaptic()
            }
        }
    }
    
    // MARK: - Keyboard Simulation
    
    /// 发送方向键事件
    static func sendArrowKey(left: Bool? = nil, up: Bool? = nil, isHorizontal: Bool = true) {
        var key: CGKeyCode = 0
        
        if let left = left {
            key = left ? 123 : 124 // 123: left, 124: right
        } else if let up = up {
            key = up ? 126 : 125   // 126: up, 125: down
        }
        
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)
        
        var customFlags: CGEventFlags = []
        
        // 根据移动方向应用相应的增强功能
        if isHorizontal {
            // 水平移动增强功能
            if horizontalWordJump {
                customFlags.insert(.maskControl)
            }
            if horizontalBeginEnd {
                customFlags.insert(.maskCommand)
            }
            if horizontalShift {
                customFlags.insert(.maskShift)
            }
        } else {
            // 垂直移动增强功能
            if verticalBeginEnd {
                customFlags.insert(.maskCommand)
            }
            if verticalShift {
                customFlags.insert(.maskShift)
            }
        }
        
        // 应用修饰键标志 - 先清除所有修饰键，然后添加自定义修饰键
        keyDown?.flags = customFlags
        keyUp?.flags = customFlags
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
} 
