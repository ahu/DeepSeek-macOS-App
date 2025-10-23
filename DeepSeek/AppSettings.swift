//
//  AppSettings.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/22.
//

import SwiftUI
import KeyboardShortcuts

@available(macOS 13, *)
struct AppSettings: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("开关应用").frame(width: 100, alignment: .leading)
                KeyboardShortcuts.Recorder(for: .toggleWindow)
            }
            HStack {
                Text("刷新页面").frame(width: 100, alignment: .leading)
                KeyboardShortcuts.Recorder(for: .refreshWeb)
            }
        }
        .frame(width: 400, height: 100) // 固定窗口大小
        .padding(0) // 去掉多余 padding
        .navigationTitle("快捷键设置")
    }
}
