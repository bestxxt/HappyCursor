//
//  KeyStatusView.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI

struct KeyStatusView: View {
    let keyName: String
    let isPressed: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isPressed ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
            Text(keyName)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

#Preview {
    HStack {
        KeyStatusView(keyName: "⇧ Shift", isPressed: false)
        KeyStatusView(keyName: "⌘ Command", isPressed: true)
        KeyStatusView(keyName: "⌥ Option", isPressed: false)
    }
    .padding()
} 