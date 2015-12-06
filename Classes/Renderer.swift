//
//  Renderer.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 01/12/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation
import WebKit

internal enum PostActionType {
    case Wait
    case Validate
}

internal struct PostAction {
    var type : PostActionType
    var value : AnyObject
    
    init(type: PostActionType, script: String) {
        self.type = type
        self.value = script
    }
    
    init(type: PostActionType, wait: NSTimeInterval) {
        self.type = type
        self.value = wait
    }
}

internal class Renderer : NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    
    typealias Completion = (result : AnyObject?, response: NSURLResponse?, error: NSError?) -> Void

    private var renderCompletion : Completion?
    private var renderResponse : NSURLResponse?
    private var renderError : NSError?
    
    private var postAction: PostAction?
    private var webView : WKWebView!
    
    override init() {
        super.init()
        webView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading", context: nil)
    }
    
    //
    // MARK: Render Page
    //
    
    internal func renderPageWithRequest(request: NSURLRequest, postAction: PostAction? = nil, completionHandler: Completion) {
        if let _ = renderCompletion {
            NSLog("Rendering already in progress ...")
            return
        }
        self.postAction = postAction
        self.renderCompletion = completionHandler
        self.webView.loadRequest(request)
    }
    
    //
    // MARK: Execute Script
    //
    
    internal func executeScript(script: String, willLoadPage: Bool? = false, postAction: PostAction? = nil, completionHandler: Completion?) {
        if let _ = renderCompletion {
            NSLog("Rendering already in progress ...")
            return
        }
        if let willLoadPage = willLoadPage where willLoadPage == true {
            self.postAction = postAction
            self.renderCompletion = completionHandler
            self.webView.evaluateJavaScript(script, completionHandler: nil)
        } else {
            let javaScriptCompletionHandler = { (result : AnyObject?, error : NSError?) -> Void in
                completionHandler?(result: result, response: nil, error: error)
            }
            self.webView.evaluateJavaScript(script, completionHandler: javaScriptCompletionHandler)
        }
    }
    
    //
    // MARK: Delegates
    //
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        //None of the content loaded after this point is necessary (images, videos, etc.)
        //print("Received script message: \(message.body)")
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        if let _ = renderCompletion {
            renderResponse = navigationResponse.response
        }
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        if let _ = renderCompletion {
            renderError = error
        }
        callRenderCompletion(nil)
    }
    
    private func callRenderCompletion(renderResult: String?) {
        let data = renderResult?.dataUsingEncoding(NSUTF8StringEncoding)
        let completion = renderCompletion
        renderCompletion = nil
        completion?(result: data, response: renderResponse, error: renderError)
        renderResponse = nil
        renderError = nil
    }
    
    func finishedLoading(webView: WKWebView) {
        print("Finish loading")
        webView.evaluateJavaScript("document.documentElement.outerHTML;") { [weak self] result, error in
            print(result)
            print("isLoading: \(webView.loading)")
            self?.callRenderCompletion(result as? String)
        }
    }
    
    func validate(condition: String, webView: WKWebView) {
        webView.evaluateJavaScript(condition) { [weak self] result, error in
            if let result = result as? Bool where result == true {
                self?.finishedLoading(webView)
            } else {
                delay(0.5, completion: {
                    self?.validate(condition, webView: webView)
                })
            }
        }
    }
    
    func waitAndFinish(time: NSTimeInterval, webView: WKWebView) {
        delay(time) {
            self.finishedLoading(webView)
        }
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "loading" && webView.loading == false {
            if let postAction = postAction {
                switch postAction.type {
                case .Validate: validate(postAction.value as! String, webView: webView)
                case .Wait: waitAndFinish(postAction.value as! NSTimeInterval, webView: webView)
                }
                self.postAction = nil
            } else {
                validate("document.readyState == 'complete';", webView: webView)
            }
        }
    }
}

// MARK: Helper

func delay(time: NSTimeInterval, completion: () -> Void) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        completion()
    }
}