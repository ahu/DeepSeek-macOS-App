//
//  ShortcutRecorderView.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/22.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutRecorderView: View {
    var name: KeyboardShortcuts.Name

    var body: some View {
        HStack {
            Text(name.rawValue).frame(width: 120, alignment: .leading)
            KeyboardShortcuts.Recorder(for: name)
        }
        .padding(.vertical, 4)
    }
}
