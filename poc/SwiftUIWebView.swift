//
//  SwiftUIWebView.swift
//  poc
//
//  Created by David Frontegg on 24/10/2022.
//

import Foundation
import WebKit
import SwiftUI
import AuthenticationServices
 

class FronteggWebView: WKWebView, WKNavigationDelegate {
    var accessoryView: UIView?
    var fronteggAuth: FronteggAuth?
    var socialLoginAuth = FronteggSocialLoginAuth()
    
    override var inputAccessoryView: UIView? {
        // remove/replace the default accessory view
        return accessoryView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url,
           let scheme = url.scheme {
            if(scheme != "frontegg" && !url.absoluteString.starts(with: "https://david.frontegg.com")){
                self.socialLoginAuth.startLoginTransition(url) { url, error in
                    if let query = url?.query {
//                        self.fronteggAuth?.isLoading = true
                        var successUrl = URL(string:"https://david.frontegg.com/oauth/account/social/success?\(query)" )!
                        webView.load(URLRequest(url: successUrl))
                    }
                }
                return .cancel
            } else {
                if(url.absoluteString.starts(with: "frontegg://oauth/callback")){
                    let query = url.query ?? ""
//                    self.fronteggAuth?.isLoading = true
                    webView.load(URLRequest(url: URL(string: "frontegg://oauth/success/callback?\(query)")!))
                    return .cancel
                }
                
                return .allow
            }
        } else {
            self.fronteggAuth?.isLoading = false
            return .allow
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        fronteggAuth?.isLoading = false
//        if !(self.fronteggAuth?.isLoading ?? true) {
//            self.fronteggAuth?.isLoading = true
//        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("finish load \(webView.url?.absoluteString)")
        if(webView.url?.absoluteString.hasSuffix("/oauth/account/login") ?? false && fronteggAuth?.isLoading ?? true){
            fronteggAuth?.isLoading = false
        }
    }
    
}

struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    let webView: FronteggWebView
    private var httpCookieStore: WKHTTPCookieStore
    private var fronteggAuth: FronteggAuth
    
    init(fronteggAuth: FronteggAuth) {
        self.fronteggAuth = fronteggAuth;
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        let conf = WKWebViewConfiguration()
        conf.userContentController = userContentController
        userContentController.addUserScript(script)
        
//        let preferences = WKPreferences()
//        conf.preferences = preferences

        
        httpCookieStore = WKWebsiteDataStore.default().httpCookieStore;
        let assetsHandler = WkFronteggHandler(fronteggAuth: fronteggAuth)
        
        conf.setURLSchemeHandler(assetsHandler , forURLScheme: "frontegg" )
        conf.websiteDataStore = WKWebsiteDataStore.default()
        
        webView = FronteggWebView(frame: .zero, configuration: conf)
        webView.fronteggAuth = fronteggAuth;
        webView.navigationDelegate = webView;
        
        
        
        print("INIT WEBVIEW")
//                var url = URL(string:"https://david.frontegg.com/oauth/account/login" )!
//        var url = URL(string: "frontegg://oauth/authenticate" )!
//        self.webView.load(URLRequest(url: url))
        
        
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        if var url = URL(string: "frontegg://oauth/authenticate" ) {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
        }
                
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    
    
    
}


fileprivate final class InputAccessoryHackHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
}

extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
