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
        InstructionRow(icon: "1.circle.fill", text: "按住设定的快捷键")
        InstructionRow(icon: "2.circle.fill", text: "滑动触摸板移动光标")
        InstructionRow(icon: "3.circle.fill", text: "每次移动会触发触觉反馈")
        InstructionRow(icon: "exclamationmark.triangle.fill", text: "需要在系统设置 > 辅助功能中授权")
    }
    .padding()
} 