//
//  InstructionRow.swift
//  HappyCursor
//
//  Created by 谢鑫涛 on 2025-06-18.
//

import SwiftUI

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        InstructionRow(icon: "1.circle.fill", text: "Hold the set hotkey")
        InstructionRow(icon: "2.circle.fill", text: "Slide trackpad to move cursor")
        InstructionRow(icon: "3.circle.fill", text: "Haptic feedback on each movement")
        InstructionRow(icon: "exclamationmark.triangle.fill", text: "Requires authorization in System Settings > Accessibility")
    }
    .padding()
} 