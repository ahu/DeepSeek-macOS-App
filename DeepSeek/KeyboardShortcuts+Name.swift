//
//  KeyboardShortcuts+Name.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/22.
//

import AppKit
import KeyboardShortcuts

// 注意前缀 KeyboardShortcuts.Name
extension KeyboardShortcuts.Name {
    static let toggleWindow = KeyboardShortcuts.Name("toggleWindow",
                                                   default: .init(.d, modifiers: [.command, .shift]))
    static let refreshWeb   = KeyboardShortcuts.Name("refreshWeb",
                                                   default: .init(.r, modifiers: .command))
}
