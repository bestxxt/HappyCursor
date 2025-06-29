//
//  AppDelegate.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import Cocoa

/// Application delegate class, responsible for global event monitoring and cursor control
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAccessibilityPermissionGranted: Bool = false {
        didSet {
            if isAccessibilityPermissionGranted {
                if eventTap == nil {
                    print("Permission granted, starting event monitoring...")
                    setupEventTap()
                }
            } else {
                if eventTap != nil {
                    print("Permission revoked, stopping event monitoring...")
                    cleanupEventTap()
                }
            }
        }
    }
    
    // MARK: - Properties
    
    /// Event listener
    private var eventTap: CFMachPort?
    /// Run loop source
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
        
        // Horizontal movement enhancement features
        static let horizontalWordJump = "horizontalWordJump"
        static let horizontalBeginEnd = "horizontalBeginEnd"
        static let horizontalShift = "horizontalShift"
        
        // Vertical movement enhancement features
        static let verticalWordJump = "verticalWordJump"
        static let verticalBeginEnd = "verticalBeginEnd"
        static let verticalShift = "verticalShift"
        
        // New: Application-specific control
        static let enableAppSpecificControl = "enableAppSpecificControl"
        static let enabledApps = "enabledApps"
    }
    
    // MARK: - Configuration
    
    /// Horizontal movement threshold (smaller value = more sensitive)
    static var moveThresholdX: Double {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.moveThresholdX) as? Double) ?? 10.0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.moveThresholdX)
        }
    }
    
    /// Vertical movement threshold (smaller value = more sensitive)
    static var moveThresholdY: Double {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.moveThresholdY) as? Double) ?? 20.0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.moveThresholdY)
        }
    }
    
    /// Currently selected hotkey
    static var hotkey: ModifierKey {
        get {
            let rawValue = UserDefaults.standard.string(forKey: ConfigKeys.hotkey) ?? ModifierKey.command.rawValue
            return ModifierKey(rawValue: rawValue) ?? .command
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: ConfigKeys.hotkey)
        }
    }
    
    /// Whether horizontal movement is enabled
    static var enableHorizontal: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableHorizontal) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableHorizontal)
        }
    }
    
    /// Whether vertical movement is enabled
    static var enableVertical: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableVertical) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableVertical)
        }
    }
    
    /// Whether haptic feedback is enabled
    static var enableHapticFeedback: Bool {
        get {
            return (UserDefaults.standard.object(forKey: ConfigKeys.enableHapticFeedback) as? Bool) ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableHapticFeedback)
        }
    }
    
    /// Whether cursor control is enabled (master switch)
    static var enableCursorControl: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.enableCursorControl) as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableCursorControl) }
    }
    
    // MARK: - Horizontal Movement Enhancement Features
    
    /// Whether horizontal movement enables word-by-word movement (Option)
    static var horizontalWordJump: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalWordJump) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalWordJump) }
    }
    
    /// Whether horizontal movement enables beginning/end of line movement (Command)
    static var horizontalBeginEnd: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalBeginEnd) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalBeginEnd) }
    }
    
    /// Whether horizontal movement enables selection functionality (Shift)
    static var horizontalShift: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.horizontalShift) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.horizontalShift) }
    }
    
    // MARK: - Vertical Movement Enhancement Features
    
    /// Whether vertical movement enables beginning/end of line movement (Command)
    static var verticalBeginEnd: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.verticalBeginEnd) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.verticalBeginEnd) }
    }
    
    /// Whether vertical movement enables selection functionality (Shift)
    static var verticalShift: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.verticalShift) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.verticalShift) }
    }
    
    /// Application-specific control
    /// Whether application-specific control is enabled (whitelist)
    static var enableAppSpecificControl: Bool {
        get { (UserDefaults.standard.object(forKey: ConfigKeys.enableAppSpecificControl) as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: ConfigKeys.enableAppSpecificControl) }
    }
    
    /// Whitelist applications (application names)
    static var enabledApps: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: ConfigKeys.enabledApps) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: ConfigKeys.enabledApps)
        }
    }
    
    /// Get all installed applications (application names)
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
    
    /// Check if current active application is in whitelist
    static func isAppEnabledForCursorControl() -> Bool {
        guard let activeApp = NSWorkspace.shared.frontmostApplication else {
            return false
        }
        let appName = activeApp.localizedName ?? ""
        return enabledApps.contains(appName)
    }
    
    /// Modifier key type enumeration
    enum ModifierKey: String, CaseIterable, Identifiable {
        case shift = "Shift"
        case command = "Command"
        case option = "Option"
        
        var id: String { rawValue }
        
        /// Corresponding NSEvent modifier key flags
        var flag: NSEvent.ModifierFlags {
            switch self {
            case .shift: return .shift
            case .command: return .command
            case .option: return .option
            }
        }
        
        /// Corresponding CGEvent modifier key flags
        var cgFlag: CGEventFlags {
            switch self {
            case .shift: return .maskShift
            case .command: return .maskCommand
            case .option: return .maskAlternate
            }
        }
        
        /// Display symbol
        var symbol: String {
            switch self {
            case .shift: return "⇧ Shift"
            case .command: return "⌘ Command"
            case .option: return "⌥ Option"
            }
        }
    }
    
    // MARK: - State Management
    
    /// Horizontal direction cumulative movement amount
    static var accumX: Double = 0.0
    /// Vertical direction cumulative movement amount
    static var accumY: Double = 0.0
    /// Whether hotkey is active
    static var isHotkeyActive: Bool = false
    /// Mouse position locked when hotkey is active
    static var lockedMousePosition: CGPoint?
    
    /// Global modifier key status
    static var isCmdPressed: Bool = false
    static var isOptPressed: Bool = false
    static var isShiftPressed: Bool = false
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("HappyCursor starting...")
        
        // Set application as delegate application, support status bar mode
        NSApp.setActivationPolicy(.accessory)
        
        checkAccessibilityPermission()
        print("HappyCursor startup completed")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("HappyCursor closing...")
        cleanupEventTap()
        print("HappyCursor closed")
    }
    
    /// Prevent application from exiting when window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: - Settings Management
    
    /// Reset to default settings
    static func resetToDefaultSettings() {
        UserDefaults.standard.set(10.0, forKey: ConfigKeys.moveThresholdX)
        UserDefaults.standard.set(10.0, forKey: ConfigKeys.moveThresholdY)
        UserDefaults.standard.set(ModifierKey.command.rawValue, forKey: ConfigKeys.hotkey)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableHorizontal)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableVertical)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableHapticFeedback)
        UserDefaults.standard.set(true, forKey: ConfigKeys.enableCursorControl)
        
        // Default values for horizontal movement enhancement features
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalWordJump)
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalBeginEnd)
        UserDefaults.standard.set(false, forKey: ConfigKeys.horizontalShift)
        
        // Default values for vertical movement enhancement features
        UserDefaults.standard.set(false, forKey: ConfigKeys.verticalBeginEnd)
        UserDefaults.standard.set(false, forKey: ConfigKeys.verticalShift)
        
        print("Configuration reset to default values")
    }
    
    // MARK: - Accessibility Permission
    
    /// Check accessibility permission
    func checkAccessibilityPermission() {
        // Update accessibility permission status
        isAccessibilityPermissionGranted = AXIsProcessTrusted()
        
        if isAccessibilityPermissionGranted {
            setupEventTap()
        } else {
            cleanupEventTap()
        }
    }
    
    /// Open accessibility system settings
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Event Handling Setup
    
    /// Set up global event monitoring
    private func setupEventTap() {
        // Listen for mouse movement and modifier key change events
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
            print("✅ Global event monitoring started")
        } else {
            print("❌ Global event monitoring startup failed")
        }
    }
    
    /// Clean up event listener
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
    
    /// Handle global events
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
    
    /// Handle modifier key change events
    private static func handleFlagsChanged(event: CGEvent) -> CGEvent {
        let flags = event.flags
        
        // Update global modifier key status
        isCmdPressed = flags.contains(.maskCommand)
        isOptPressed = flags.contains(.maskAlternate)
        isShiftPressed = flags.contains(.maskShift)
        
        let isHotkeyCurrentlyPressed = flags.contains(hotkey.cgFlag)
        
        if isHotkeyCurrentlyPressed && !isHotkeyActive {
            // Hotkey just pressed
            isHotkeyActive = true
            lockedMousePosition = event.location
            print("Hotkey pressed, locked mouse position to: \(String(describing: lockedMousePosition))")
        } else if !isHotkeyCurrentlyPressed && isHotkeyActive {
            // Hotkey just released
            isHotkeyActive = false
            lockedMousePosition = nil
            print("Hotkey released, unlocked mouse.")
        }
        
        return event
    }
    
    /// Handle mouse movement events
    private static func handleMouseMoved(event:CGEvent) -> CGEvent? {
        // Check if cursor control is enabled
        guard enableCursorControl else { return event }
        // Check application-specific control
        if enableAppSpecificControl {
            guard isAppEnabledForCursorControl() else { return event }
        }
        
        guard isHotkeyActive, let lockedPos = lockedMousePosition else {
            return event
        }
        
        // Get mouse movement distance
        let deltaX = event.getDoubleValueField(.mouseEventDeltaX)
        let deltaY = event.getDoubleValueField(.mouseEventDeltaY)
        
        // Accumulate movement amount
        accumX += deltaX
        accumY += deltaY
        
        // Process horizontal movement
        if enableHorizontal {
            processHorizontalMovement()
        }
        
        // Process vertical movement
        if enableVertical {
            processVerticalMovement()
        }
        
        // Warp mouse back to locked position
        CGWarpMouseCursorPosition(lockedPos)
        
        // Prevent original event (don't move mouse pointer)
        return nil
    }
    
    /// Process horizontal movement
    private static func processHorizontalMovement() {
        while abs(accumX) >= moveThresholdX {
            if accumX > 0 {
                sendArrowKey(left: false, isHorizontal: true) // Right
                accumX -= moveThresholdX
                accumY = 0
            } else {
                sendArrowKey(left: true, isHorizontal: true)  // Left
                accumX += moveThresholdX
                accumY = 0
            }
            if enableHapticFeedback {
                HapticManager.shared.triggerGenericHaptic()
            }
        }
    }
    
    /// Process vertical movement
    private static func processVerticalMovement() {
        while abs(accumY) >= moveThresholdY {
            if accumY > 0 {
                sendArrowKey(up: false, isHorizontal: false)   // Down
                accumY -= moveThresholdY
                accumX = 0
            } else {
                sendArrowKey(up: true, isHorizontal: false)    // Up
                accumY += moveThresholdY
                accumX = 0
            }
            if enableHapticFeedback {
                HapticManager.shared.triggerGenericHaptic()
            }
        }
    }
    
    // MARK: - Keyboard Simulation
    
    /// Send direction key events
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
        
        // Apply corresponding enhancement features based on movement direction
        if isHorizontal {
            // Horizontal movement enhancement features
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
            // Vertical movement enhancement features
            if verticalBeginEnd {
                customFlags.insert(.maskCommand)
            }
            if verticalShift {
                customFlags.insert(.maskShift)
            }
        }
        
        // Apply modifier key flags - first clear all modifier keys, then add custom modifier keys
        keyDown?.flags = customFlags
        keyUp?.flags = customFlags
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
} 
