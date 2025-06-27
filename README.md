# HappyCursor - Global Cursor Controller

A professional macOS application that provides precise text cursor movement control through trackpad gestures and keyboard shortcuts, delivering a smooth haptic feedback experience.

## ✨ Key Features

### 🎯 Global Cursor Control
- **Smart Cursor Movement**: Hold keyboard shortcuts and slide the trackpad to precisely control text insertion point
- **Cross-Application Support**: Works in any application that supports text editing (VSCode, Safari, Notes, etc.)
- **Arrow Key Simulation**: Achieves cursor movement by simulating arrow key events with excellent compatibility

### 🎮 Haptic Feedback
- **Real-time Feedback**: Triggers haptic feedback with every cursor movement
- **Force Touch Support**: Designed specifically for MacBooks with haptic feedback support
- **Multiple Feedback Types**: Supports different types of haptic feedback including generic, alignment, and level change

### ⚙️ Flexible Configuration
- **Adjustable Sensitivity**: Independently set horizontal and vertical movement sensitivity
- **Shortcut Selection**: Supports Shift, Command, and Option modifier keys
- **Direction Control**: Enable or disable horizontal/vertical movement individually
- **Auto-Save**: All settings are automatically saved and maintained on next launch

### 🎨 Professional Interface
- **Modern Design**: Clean interface following Apple's design guidelines
- **Real-time Status Display**: Intuitive display of shortcut status and configuration information
- **Responsive Layout**: Adapts to different window sizes

## 🚀 System Requirements

- **Operating System**: macOS 10.15 (Catalina) or higher
- **Hardware Requirements**: Mac device with haptic feedback support (such as MacBook Pro with Touch Bar)
- **Permission Requirements**: Requires accessibility permissions in System Settings

## 📦 Installation and Usage

### 1. Install Application
1. Download and install HappyCursor
2. On first launch, the system will prompt to grant accessibility permissions

### 2. Configure Permissions
1. Open System Settings > Privacy & Security > Accessibility
2. Find HappyCursor and enable permissions
3. Restart the application

### 3. Start Using
1. Select trigger shortcut in the application interface (default: Command)
2. Adjust horizontal and vertical movement sensitivity
3. Hold the shortcut key and slide the trackpad in any text editor
4. Enjoy precise cursor control and haptic feedback
5. All settings are automatically saved and maintained on next launch

## 🔧 Technical Architecture

### Core Technologies
- **SwiftUI**: Build modern user interfaces
- **AppKit**: Provide macOS-specific system functionality
- **Core Graphics**: Global event monitoring and keyboard event simulation
- **Haptic Feedback**: Haptic feedback system integration

### Main Components
```
HappyCursor/
├── HappyCursorApp.swift      # Application entry and configuration
├── ContentView.swift         # Main interface view
├── AppDelegate.swift         # Global event handling and cursor control
├── HapticManager.swift       # Haptic feedback management
└── Assets.xcassets/          # Application resources
```

### Core Functionality Implementation

#### Global Event Monitoring
- Use `CGEventTap` to monitor global mouse movement and keyboard events
- Real-time detection of modifier key state changes
- Precise control of event interception and forwarding

#### Cursor Movement Control
- Accumulate trackpad movement distance and trigger movement when threshold is reached
- Simulate arrow key events to ensure cross-application compatibility
- Intelligent handling of independent horizontal and vertical direction control

#### Haptic Feedback System
- Integrate `NSHapticFeedbackManager` to provide multiple feedback types
- Support continuous feedback and feedback sequences
- Automatic device compatibility detection

## 🎯 Use Cases

### Programming Development
- Quickly position cursor in IDEs like VSCode, Xcode
- Precise code editing and navigation

### Document Editing
- Quickly move cursor in document editors like Pages, Word
- Improve document editing efficiency

### Web Browsing
- Quickly position text in browsers like Safari, Chrome
- Enhance web content editing experience

## 🔒 Privacy and Security

- **Local Processing**: All event processing is done locally, no user data collection
- **Transparent Permissions**: Clear explanation of required system permissions and purposes
- **No Network Access**: Application does not perform any network communication

## 🛠️ Development Notes

### Project Structure
```
HappyCursor/
├── HappyCursor/              # Main application code
│   ├── HappyCursorApp.swift  # Application entry
│   ├── ContentView.swift     # Main interface
│   ├── AppDelegate.swift     # Event handling
│   ├── HapticManager.swift   # Haptic feedback
│   └── Assets.xcassets/      # Resource files
├── HappyCursorTests/         # Unit tests
├── HappyCursorUITests/       # UI tests
└── README.md                 # Project documentation
```

### Development Environment
- **Xcode**: 15.0 or higher
- **Swift**: 5.9 or higher
- **macOS SDK**: 14.0 or higher

### Build Steps
1. Open `HappyCursor.xcodeproj` with Xcode
2. Select target device (requires Mac with haptic feedback support)
3. Build and run the project

## 📄 License

Copyright © 2025 HappyCursor. All rights reserved.

## 🙏 Acknowledgments

- Excellent development tools and APIs provided by Apple
- Valuable feedback from all test users

---

**HappyCursor** - Making cursor movement smarter, making editing experience smoother 🎯

