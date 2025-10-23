//
//  DeepSeekApp.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/22.
//

import SwiftUI
import KeyboardShortcuts

@available(macOS 13, *)
@main
struct DeepSeekApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        // ✅ 系统 Settings 窗口（⌘,）
        Settings {
            AppSettings()            // 你的 Recorder 面板
        }
    }
}
