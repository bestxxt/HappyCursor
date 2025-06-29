//
//  ContentView.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var text: String = {
        // Use LocalizationManager's current language to set initial text
        let language = LocalizationManager.shared.currentLanguage
        
        if language == "zh" {
            return """
            欢迎使用 HappyCursor 全局光标控制器！
            这是一个测试区域，您可以在这里体验光标移动功能。按住设定的快捷键（默认是 Command 键）并滑动触摸板，您会看到光标在文字中移动。
            测试步骤：
            1. 将光标放在这段文字中的任意位置。
            2. 按住 Command 键（或您设定的其他快捷键）。
            3. 滑动触摸板，观察光标的移动。
            4. 每次移动都会触发触觉反馈。
            您可以尝试在不同的位置测试，比如：
            • 在单词中间移动光标。
            • 在行首和行尾之间移动。
            • 在段落之间上下移动。
            • 测试不同的移动灵敏度设置。
            这个功能在任何支持文本编辑的应用中都可以使用，包括 VSCode、Safari、Notes 等。让您的文本编辑体验更加流畅和高效！
            """
        } else {
            return """
            Welcome to HappyCursor Global Cursor Controller!
            This is a test area where you can experience cursor movement functionality. Hold the set hotkey (default is Command key) and slide the trackpad, you will see the cursor moving in the text.
            Test steps:
            1. Place the cursor anywhere in this text.
            2. Hold the Command key (or your set hotkey).
            3. Slide the trackpad to observe cursor movement.
            4. Each movement will trigger haptic feedback.
            You can try testing in different positions, such as:
            • Moving the cursor within words.
            • Moving between the beginning and end of lines.
            • Moving up and down between paragraphs.
            • Testing different movement sensitivity settings.
            This feature works in any app that supports text editing, including VSCode, Safari, Notes, etc. Make your text editing experience smoother and more efficient!
            """
        }
    }()
    @State private var isCmdPressed: Bool = false
    @State private var isOptPressed: Bool = false
    @State private var isShiftPressed: Bool = false
    @State private var eventMonitor: Any?
    @State private var moveThresholdX: Double = AppDelegate.moveThresholdX
    @State private var moveThresholdY: Double = AppDelegate.moveThresholdY
    @State private var hotkey: AppDelegate.ModifierKey = AppDelegate.hotkey
    @State private var enableHorizontal: Bool = AppDelegate.enableHorizontal
    @State private var enableVertical: Bool = AppDelegate.enableVertical
    @State private var enableHapticFeedback: Bool = AppDelegate.enableHapticFeedback
    @State private var enableCursorControl: Bool = AppDelegate.enableCursorControl
    
    // Horizontal movement enhancement features
    @State private var horizontalWordJump: Bool = AppDelegate.horizontalWordJump
    @State private var horizontalBeginEnd: Bool = AppDelegate.horizontalBeginEnd
    @State private var horizontalShift: Bool = AppDelegate.horizontalShift
    
    // Vertical movement enhancement features
    @State private var verticalBeginEnd: Bool = AppDelegate.verticalBeginEnd
    @State private var verticalShift: Bool = AppDelegate.verticalShift
    
    @State private var showingSubscriptionView = false
    @State private var enableAppSpecificControl: Bool = AppDelegate.enableAppSpecificControl
    @State private var enabledApps: Set<String> = AppDelegate.enabledApps
    @State private var allInstalledApps: [String] = []
    @State private var appNameToPath: [String: String] = [:]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top title area
                VStack(spacing: 16) {
                    HStack {
                        Image("interface_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("HappyCursor".localized)
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Global Cursor Controller".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Buy Me a Coffee button
                        Button(action: {
                            if let url = URL(string: "https://coff.ee/terry_xie") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundColor(.orange)
                                Text("Buy Me a Coffee")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Sponsor the author Buy Me a Coffee")

                        // Reset configuration button
                        Button(action: {
                            AppDelegate.resetToDefaultSettings()
                            // Reload configuration to UI
                            moveThresholdX = AppDelegate.moveThresholdX
                            moveThresholdY = AppDelegate.moveThresholdY
                            hotkey = AppDelegate.hotkey
                            enableHorizontal = AppDelegate.enableHorizontal
                            enableVertical = AppDelegate.enableVertical
                            enableHapticFeedback = AppDelegate.enableHapticFeedback
                            enableCursorControl = AppDelegate.enableCursorControl
                            
                            // Reload movement enhancement feature configuration
                            horizontalWordJump = AppDelegate.horizontalWordJump
                            horizontalBeginEnd = AppDelegate.horizontalBeginEnd
                            horizontalShift = AppDelegate.horizontalShift
                            verticalBeginEnd = AppDelegate.verticalBeginEnd
                            verticalShift = AppDelegate.verticalShift
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Reset to default configuration".localized)
                    }
                    
                    Divider()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // General Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("General Settings".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Language selector
                            LanguageSelectorView()
                            
                            Toggle("Enable Cursor Control".localized, isOn: $enableCursorControl)
                                .onChange(of: enableCursorControl, initial: false) { _, newValue in
                                    AppDelegate.enableCursorControl = newValue
                                }
                            
                            Toggle("Enable Haptic Feedback".localized, isOn: $enableHapticFeedback)
                                .onChange(of: enableHapticFeedback, initial: false) { _, newValue in
                                    AppDelegate.enableHapticFeedback = newValue
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Key status display
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Status".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 12)
                            
                            HStack(spacing: 16) {
                                Spacer()
                                KeyStatusView(keyName: "Shift".localized, isPressed: isShiftPressed)
                                KeyStatusView(keyName: "Command".localized, isPressed: isCmdPressed)
                                KeyStatusView(keyName: "Option".localized, isPressed: isOptPressed)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Trigger hotkey settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trigger Hotkey".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Hotkey".localized, selection: $hotkey) {
                                ForEach(AppDelegate.ModifierKey.allCases) { key in
                                    Text(key.symbol).tag(key)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: hotkey, initial: false) { oldValue, newValue in
                                AppDelegate.hotkey = newValue
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Movement sensitivity settings
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Movement Sensitivity".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Horizontal movement settings
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Horizontal Movement".localized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(String(format: "%.1f", moveThresholdX))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "hare")
                                        .foregroundColor(.secondary)
                                    Slider(value: $moveThresholdX, in: 1...50, step: 0.5) {
                                    }
                                    .onChange(of: moveThresholdX, initial: false) { oldValue, newValue in
                                        AppDelegate.moveThresholdX = newValue
                                    }
                                    
                                    Image(systemName: "tortoise")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Toggle("Enable Horizontal Movement".localized, isOn: $enableHorizontal)
                                        .onChange(of: enableHorizontal, initial: false) { _, newValue in
                                            AppDelegate.enableHorizontal = newValue
                                        }
                                    
                                    Spacer()
                                    
                                    // Horizontal movement enhancement options
                                    HStack(spacing: 12) {
                                        Toggle("Word Jump".localized, isOn: $horizontalWordJump)
                                            .onChange(of: horizontalWordJump) { _, newValue in
                                                if newValue {
                                                    // Mutually exclusive selection: turn off other options
                                                    horizontalBeginEnd = false
                                                    horizontalShift = false
                                                    AppDelegate.horizontalBeginEnd = false
                                                    AppDelegate.horizontalShift = false
                                                }
                                                AppDelegate.horizontalWordJump = newValue
                                            }
                                        
                                        Toggle("Line Start/End".localized, isOn: $horizontalBeginEnd)
                                            .onChange(of: horizontalBeginEnd) { _, newValue in
                                                if newValue {
                                                    // Mutually exclusive selection: turn off other options
                                                    horizontalWordJump = false
                                                    horizontalShift = false
                                                    AppDelegate.horizontalWordJump = false
                                                    AppDelegate.horizontalShift = false
                                                }
                                                AppDelegate.horizontalBeginEnd = newValue
                                            }
                                        
                                        Toggle("Select".localized, isOn: $horizontalShift)
                                            .onChange(of: horizontalShift) { _, newValue in
                                                if newValue {
                                                    // Mutually exclusive selection: turn off other options
                                                    horizontalWordJump = false
                                                    horizontalBeginEnd = false
                                                    AppDelegate.horizontalWordJump = false
                                                    AppDelegate.horizontalBeginEnd = false
                                                }
                                                AppDelegate.horizontalShift = newValue
                                            }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Vertical movement settings
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Vertical Movement".localized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(String(format: "%.1f", moveThresholdY))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "hare")
                                        .foregroundColor(.secondary)
                                    Slider(value: $moveThresholdY, in: 1...50, step: 0.5) {
                                    }
                                    .onChange(of: moveThresholdY, initial: false) { oldValue, newValue in
                                        AppDelegate.moveThresholdY = newValue
                                    }
                                    Image(systemName: "tortoise")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Toggle("Enable Vertical Movement".localized, isOn: $enableVertical)
                                        .onChange(of: enableVertical, initial: false) { _, newValue in
                                            AppDelegate.enableVertical = newValue
                                        }
                                    
                                    Spacer()
                                    
                                    // Vertical movement enhancement options
                                    HStack(spacing: 12) {
                                        Toggle("Column Start/End".localized, isOn: $verticalBeginEnd)
                                            .onChange(of: verticalBeginEnd) { _, newValue in
                                                if newValue {
                                                    // Mutually exclusive selection: turn off other options
                                                    verticalShift = false
                                                    AppDelegate.verticalShift = false
                                                }
                                                AppDelegate.verticalBeginEnd = newValue
                                            }
                                        
                                        Toggle("Select".localized, isOn: $verticalShift)
                                            .onChange(of: verticalShift) { _, newValue in
                                                if newValue {
                                                    // Mutually exclusive selection: turn off other options
                                                    verticalBeginEnd = false
                                                    AppDelegate.verticalBeginEnd = false
                                                }
                                                AppDelegate.verticalShift = newValue
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // App specific control
                        VStack(alignment: .leading, spacing: 12) {
                            Text("App Specific Control".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Toggle("Enable cursor control only in selected apps".localized, isOn: $enableAppSpecificControl)
                                .onChange(of: enableAppSpecificControl) { _, newValue in
                                    AppDelegate.enableAppSpecificControl = newValue
                                }
                            
                            if enableAppSpecificControl {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("App Whitelist (check to enable)".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 4) {
                                            ForEach(allInstalledApps, id: \.self) { appName in
                                                HStack {
                                                    Button(action: {
                                                        if enabledApps.contains(appName) {
                                                            enabledApps.remove(appName)
                                                        } else {
                                                            enabledApps.insert(appName)
                                                        }
                                                        AppDelegate.enabledApps = enabledApps
                                                    }) {
                                                        HStack {
                                                            Image(systemName: enabledApps.contains(appName) ? "checkmark.square.fill" : "square")
                                                                .foregroundColor(enabledApps.contains(appName) ? .accentColor : .secondary)
                                                            if let appPath = appNameToPath[appName] {
                                                                let nsImage = NSWorkspace.shared.icon(forFile: appPath)
                                                                Image(nsImage: nsImage)
                                                                    .resizable()
                                                                    .frame(width: 20, height: 20)
                                                            }
                                                            Text(appName)
                                                                .foregroundColor(.primary)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 200)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Test area
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Area".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextEditor(text: $text)
                                .font(.body)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InstructionRow(icon: "1.circle.fill", text: "Hold the set hotkey".localized)
                                InstructionRow(icon: "2.circle.fill", text: "Slide trackpad to move cursor".localized)
                                InstructionRow(icon: "3.circle.fill", text: "Haptic feedback on each movement".localized)
                                InstructionRow(icon: "exclamationmark.triangle.fill", text: "Requires authorization in System Settings > Accessibility".localized)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .frame(width: 550, height: 750)
            .onAppear {
                // Periodically sync global modifier key status
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    isCmdPressed = AppDelegate.isCmdPressed
                    isOptPressed = AppDelegate.isOptPressed
                    isShiftPressed = AppDelegate.isShiftPressed
                }
                // Get all installed applications
                let appDirs = ["/Applications", "/System/Applications", NSHomeDirectory() + "/Applications"]
                var allApps: Set<String> = []
                var nameToPath: [String: String] = [:]
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
                                    nameToPath[name] = appPath
                                }
                            }
                        }
                    }
                }
                allInstalledApps = Array(allApps).sorted()
                appNameToPath = nameToPath
                // Sync app specific control status
                enableAppSpecificControl = AppDelegate.enableAppSpecificControl
                enabledApps = AppDelegate.enabledApps
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                appDelegate.checkAccessibilityPermission()
            }
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                // When language changes, reload test area text based on current language
                if localizationManager.currentLanguage == "zh" {
                    text = """
                    欢迎使用 HappyCursor 全局光标控制器！
                    这是一个测试区域，您可以在这里体验光标移动功能。按住设定的快捷键（默认是 Command 键）并滑动触摸板，您会看到光标在文字中移动。
                    测试步骤：
                    1. 将光标放在这段文字中的任意位置。
                    2. 按住 Command 键（或您设定的其他快捷键）。
                    3. 滑动触摸板，观察光标的移动。
                    4. 每次移动都会触发触觉反馈。
                    您可以尝试在不同的位置测试，比如：
                    • 在单词中间移动光标。
                    • 在行首和行尾之间移动。
                    • 在段落之间上下移动。
                    • 测试不同的移动灵敏度设置。
                    这个功能在任何支持文本编辑的应用中都可以使用，包括 VSCode、Safari、Notes 等。让您的文本编辑体验更加流畅和高效！
                    """
                } else {
                    text = """
                    Welcome to HappyCursor Global Cursor Controller!
                    This is a test area where you can experience cursor movement functionality. Hold the set hotkey (default is Command key) and slide the trackpad, you will see the cursor moving in the text.
                    Test steps:
                    1. Place the cursor anywhere in this text.
                    2. Hold the Command key (or your set hotkey).
                    3. Slide the trackpad to observe cursor movement.
                    4. Each movement will trigger haptic feedback.
                    You can try testing in different positions, such as:
                    • Moving the cursor within words.
                    • Moving between the beginning and end of lines.
                    • Moving up and down between paragraphs.
                    • Testing different movement sensitivity settings.
                    This feature works in any app that supports text editing, including VSCode, Safari, Notes, etc. Make your text editing experience smoother and more efficient!
                    """
                }
            }
            .blur(radius: appDelegate.isAccessibilityPermissionGranted ? 0 : 10)
            
            if !appDelegate.isAccessibilityPermissionGranted {
                PermissionPromptView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDelegate())
} 
