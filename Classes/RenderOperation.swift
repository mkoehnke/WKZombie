//
// RenderOperation.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import WebKit

//========================================
// MARK: RenderOperation
//========================================

internal class RenderOperation : NSOperation {
    
    typealias RequestBlock = (operation: RenderOperation) -> Void

    private(set) weak var webView : WKWebView?
    private var timeout : NSTimer?
    private let timeoutInSeconds : NSTimeInterval = 20.0
    private var stopRunLoop : Bool = false
    
    var loadMediaContent : Bool = true
    var requestBlock : RequestBlock?
    var postAction: PostAction = .None
    
    
    
    internal private(set) var result : NSData?
    internal private(set) var response : NSURLResponse?
    internal private(set) var error : NSError?
    
    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    init(webView: WKWebView) {
        super.init()
        self.webView = webView
    }
    
    override func start() {
        if self.cancelled {
            return
        } else {
            WKZLog("\(name ?? String())")
            WKZLog("[", lineBreak: false)
            executing = true
            setupReferences()
            startTimeout()
            requestBlock?(operation: self)
            
            let updateInterval : NSTimeInterval = 0.1
            var loopUntil = NSDate(timeIntervalSinceNow: updateInterval)
            while !stopRunLoop && NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: loopUntil) {
                loopUntil = NSDate(timeIntervalSinceNow: updateInterval)
                WKZLog(".", lineBreak: false)
            }
        }
    }
    
    func completeRendering(webView: WKWebView?, result: NSData? = nil, error: NSError? = nil) {
        stopTimeout()
        
        if executing == true && finished == false {
            self.result = result ?? self.result
            self.error = error ?? self.error

            cleanupReferences()
            
            executing = false
            finished = true
            
            WKZLog("]\n")
        }
    }
    
    override func cancel() {
        WKZLog("Cancelling Rendering - \(name)")
        super.cancel()
        stopTimeout()
        cleanupReferences()
        executing = false
        finished = true
    }
    
    // MARK: Helper Methods
    
    private func startTimeout() {
        stopRunLoop = false
        timeout = NSTimer(timeInterval: timeoutInSeconds, target: self, selector: #selector(RenderOperation.cancel), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(timeout!, forMode: NSDefaultRunLoopMode)
    }
    
    private func stopTimeout() {
        timeout?.invalidate()
        timeout = nil
        stopRunLoop = true
    }
    
    private func setupReferences() {
        webView?.configuration.userContentController.addScriptMessageHandler(self, name: "doneLoading")
        webView?.navigationDelegate = self
    }
    
    private func cleanupReferences() {
        webView?.navigationDelegate = nil
        webView?.configuration.userContentController.removeScriptMessageHandlerForName("doneLoading")
        webView = nil
    }
}

//========================================
// MARK: WKScriptMessageHandler
//========================================

extension RenderOperation : WKScriptMessageHandler {
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        //None of the content loaded after this point is necessary (images, videos, etc.)
        if let webView = message.webView {
            if message.name == "doneLoading" && loadMediaContent == false {
                if let url = webView.URL where response == nil {
                    response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
                }
                webView.stopLoading()
                self.webView(webView, didFinishNavigation: nil)
            }
        }
    }
}

//========================================
// MARK: WKNavigationDelegate
//========================================

extension RenderOperation : WKNavigationDelegate {
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        response = navigationResponse.response
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        if let response = response as? NSHTTPURLResponse, _ = completionBlock {
            let successRange = 200..<300
            if !successRange.contains(response.statusCode) {
                self.error = error
                self.completeRendering(webView)
            }
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        switch postAction {
        case .Wait, .Validate: handlePostAction(postAction, webView: webView)
        case .None: finishedLoading(webView)
        }
    }
    
}

//========================================
// MARK: Validation
//========================================

extension RenderOperation {
        
    func finishedLoading(webView: WKWebView) {
        webView.evaluateJavaScript("\(Renderer.scrapingCommand);") { [weak self] result, error in
            self?.result = result?.dataUsingEncoding(NSUTF8StringEncoding)
            self?.completeRendering(webView)
        }
    }
    
    func validate(condition: String, webView: WKWebView) {
        if finished == false && cancelled == false {
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
    }
    
    func waitAndFinish(time: NSTimeInterval, webView: WKWebView) {
        delay(time) {
            self.finishedLoading(webView)
        }
    }
    
    func handlePostAction(postAction: PostAction, webView: WKWebView) {
        switch postAction {
        case .Validate(let script): validate(script, webView: webView)
        case .Wait(let time): waitAndFinish(time, webView: webView)
        default: WKZLog("Something went wrong!")
        }
        self.postAction = .None
    }
    
}

//========================================
// MARK: Helper Methods
//========================================

private func delay(time: NSTimeInterval, completion: () -> Void) {
    if let currentQueue = NSOperationQueue.currentQueue()?.underlyingQueue {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, currentQueue) {
            completion()
        }
    } else {
        completion()
    }
}
