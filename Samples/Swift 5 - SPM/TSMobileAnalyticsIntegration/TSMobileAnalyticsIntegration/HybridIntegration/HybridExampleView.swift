//
//  HybridExampleView.swift
//  HybridIntegration
//
//  Created by Karl Söderberg on 2023-10-04.
//  Copyright © 2023 TNS Sifo AB. All rights reserved.
//

import UIKit
import SwiftUI
import WebKit
import TSMobileAnalytics

struct ExampleView: View {
    let urlArray = ["https://google.com/", "http://expressen.se/", "https://mobil.dn.se/"]

    var body: some View {
        NavigationView {
            List(urlArray) { urlString in
                NavigationLink(urlString) {
                    VStack {
                        WebView(url: URL(string: urlString)!)
                    }
                    .navigationTitle(urlString)
                }
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        TSMobileAnalytics.addWebView(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        Task { @MainActor in
            webView.load(request)
        }
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: ()) {
        TSMobileAnalytics.removeWebView(webView)
    }
}
