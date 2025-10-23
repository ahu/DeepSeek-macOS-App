//
//  AppDelegate.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/21.
//

import SwiftUI
import Cocoa
import WebKit
import ServiceManagement
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem!
    private var window: NSWindow?
    private var webVC: WebViewController?
    private var preferencesWindow: NSWindowController?

    private var isAlwaysOnTop = false
    private var autoLaunchEnabled = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBar()
        setupKeyboardShortcuts()
        setupShortcutChangeObserver()
    }

    // MARK: - 状态栏
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            if let image = NSImage(named: "deepseek") {
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = true
                button.image = image
            }
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusItemClicked(_:))
            button.target = self
        }
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        let isRightClick = (event.type == .rightMouseUp)
        let isCtrlLeftClick = (event.type == .leftMouseUp && event.modifierFlags.contains(.control))

        if isRightClick || isCtrlLeftClick {
            showRightClickMenu()
        } else {
            toggleWindow()
        }
    }

    // MARK: - 右键菜单
    private func showRightClickMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "开关应用", action: #selector(toggleWindow), keyEquivalent: "")
        openItem.target = self

        let refreshItem = NSMenuItem(title: "刷新页面", action: #selector(refreshWebView), keyEquivalent: "")
        refreshItem.target = self

        let topItem = NSMenuItem(title: "置顶窗口", action: #selector(toggleAlwaysOnTop(_:)), keyEquivalent: "")
        topItem.target = self
        topItem.state = isAlwaysOnTop ? .on : .off

        let autoLaunchItem = NSMenuItem(title: "开机启动", action: #selector(toggleAutoLaunch(_:)), keyEquivalent: "")
        autoLaunchItem.target = self
        autoLaunchItem.state = autoLaunchEnabled ? .on : .off

        let prefItem = NSMenuItem(title: "偏好设置", action: #selector(openPreferences), keyEquivalent: ",")
        prefItem.keyEquivalentModifierMask = [.command]
        prefItem.target = self

        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        prefItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self

        menu.addItem(openItem)
        menu.addItem(refreshItem)
        menu.addItem(.separator())
        menu.addItem(topItem)
        menu.addItem(autoLaunchItem)
        menu.addItem(prefItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)

        // 更新菜单显示快捷键
        updateMenuShortcutDisplay(menu)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.statusItem.menu = nil
        }
    }

    // MARK: - 更新右键菜单的快捷键显示
    private func updateMenuShortcutDisplay(_ menu: NSMenu) {
        func formatShortcut(_ shortcut: KeyboardShortcuts.Shortcut?) -> String {
            guard let shortcut = shortcut else { return "" }

            var symbols = ""
            if shortcut.modifiers.contains(.command) { symbols += "⌘" }
            if shortcut.modifiers.contains(.shift) { symbols += "⇧" }
            if shortcut.modifiers.contains(.option) { symbols += "⌥" }
            if shortcut.modifiers.contains(.control) { symbols += "⌃" }

            // 手动把 KeyboardShortcuts.Key 映射成可显示字符
            switch shortcut.key {
            case .a: symbols += "A"
            case .b: symbols += "B"
            case .c: symbols += "C"
            case .d: symbols += "D"
            case .r: symbols += "R"
            case .comma: symbols += ","
            case .return: symbols += "↩︎"
            case .escape: symbols += "⎋"
            case .space: symbols += "␣"
            case .upArrow: symbols += "↑"
            case .downArrow: symbols += "↓"
            case .leftArrow: symbols += "←"
            case .rightArrow: symbols += "→"
            default: symbols += "" // 未映射的不显示
            }

            return " " + symbols
        }

        let shortcuts: [(String, KeyboardShortcuts.Name)] = [
            ("开关应用", .toggleWindow),
            ("刷新页面", .refreshWeb)
        ]

        for (title, name) in shortcuts {
            if let item = menu.item(withTitle: title) {
                let shortcut = KeyboardShortcuts.getShortcut(for: name)
                item.title = title + formatShortcut(shortcut)
            }
        }
    }

    // 监听快捷键修改 → 自动更新下次打开菜单显示
    private func setupShortcutChangeObserver() {
        // 监听快捷键按下事件
        KeyboardShortcuts.onKeyUp(for: .toggleWindow) { [weak self] in
            self?.refreshStatusMenuIfNeeded()
        }
        KeyboardShortcuts.onKeyUp(for: .refreshWeb) { [weak self] in
            self?.refreshStatusMenuIfNeeded()
        }
    }

    private func refreshStatusMenuIfNeeded() {
        if let menu = statusItem.menu {
            updateMenuShortcutDisplay(menu)
        }
    }

    // MARK: - 窗口控制
    @objc private func toggleWindow() {
        if window == nil {
            let rect = NSRect(x: 0, y: 0, width: 800, height: 600)
            webVC = WebViewController()
            window = NSWindow(contentRect: rect,
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered,
                              defer: false)
            window?.contentViewController = webVC
            window?.center()
            window?.title = "DeepSeek"
            window?.isReleasedWhenClosed = false
        }

        if let win = window {
            if win.isVisible {
                win.orderOut(nil)
            } else {
                win.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                updateWindowTopState()
            }
        }
    }

    @objc private func refreshWebView() { webVC?.reloadWeb() }

    @objc private func toggleAlwaysOnTop(_ sender: NSMenuItem) {
        isAlwaysOnTop.toggle()
        sender.state = isAlwaysOnTop ? .on : .off
        updateWindowTopState()
    }

    private func updateWindowTopState() {
        window?.level = isAlwaysOnTop ? .floating : .normal
    }

    // MARK: - 偏好设置窗口
    @IBAction func openPreferences(_ sender: Any?) {
        if preferencesWindow == nil {
            let settingsView = VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("开关应用").frame(width: 100, alignment: .leading)
                    KeyboardShortcuts.Recorder(for: .toggleWindow)
                }
                HStack {
                    Text("刷新页面").frame(width: 100, alignment: .leading)
                    KeyboardShortcuts.Recorder(for: .refreshWeb)
                }
                Spacer()
            }
            .padding()
            .frame(width: 400, height: 100)

            let hosting = NSHostingController(rootView: settingsView)
            hosting.view.frame.size = CGSize(width: 400, height: 100)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 100),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = hosting
            window.title = "快捷键设置"
            window.center()
            window.delegate = self

            preferencesWindow = NSWindowController(window: window)
        }

        preferencesWindow?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow,
           preferencesWindow?.window == w {
            preferencesWindow = nil
        }
    }

    // MARK: - 开机启动
    @objc private func toggleAutoLaunch(_ sender: NSMenuItem) {
        autoLaunchEnabled.toggle()
        sender.state = autoLaunchEnabled ? .on : .off

        if #available(macOS 13.0, *) {
            do {
                if autoLaunchEnabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("❌ 启动项设置失败: \(error)")
            }
        } else {
            let helperID = "\(Bundle.main.bundleIdentifier!).LaunchAtLoginHelper" as CFString
            SMLoginItemSetEnabled(helperID, autoLaunchEnabled)
        }
    }

    // MARK: - 快捷键功能
    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .toggleWindow) { [weak self] in
            self?.toggleWindow()
        }
        KeyboardShortcuts.onKeyUp(for: .refreshWeb) { [weak self] in
            self?.refreshWebView()
        }
    }

    // MARK: - 退出
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
