//
//  WebViewController.swift
//  DeepSeek
//
//  Created by ahu on 2025/10/21.
//

import Cocoa
import WebKit

class WebViewController: NSViewController, WKUIDelegate {
    
    private var webView: WKWebView!
    
    override func loadView() {
        let view = NSView()
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "javaScriptEnabled")
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        
        // ✅ 设置 WKUIDelegate，否则不会响应文件选择等 UI 操作
        webView.uiDelegate = self
        
        view.addSubview(webView)
        
        if let url = URL(string: "https://chat.deepseek.com/") {
            webView.load(URLRequest(url: url))
        }
    }
    
    func reloadWeb() {
        webView.reload()
    }
    
    // ✅ 处理网页中的 <input type="file">
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        
        panel.begin { result in
            if result == .OK {
                completionHandler(panel.urls)
            } else {
                completionHandler(nil)
            }
        }
    }
}
