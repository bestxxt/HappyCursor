//
//  PermissionPromptView.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI

/// Permission prompt view
struct PermissionPromptView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Accessibility permission required".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("To allow HappyCursor to control the cursor globally,\nplease grant Accessibility permission in System Settings.".localized)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                appDelegate.openAccessibilitySettings()
            }) {
                Text("Open System Settings".localized)
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("After authorization, you may need to restart HappyCursor for all features to take effect.".localized)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.ultraThin)
    }
}

#Preview {
    PermissionPromptView()
        .environmentObject(AppDelegate())
} 