//
// Renderer.swift
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


typealias Completion = (result : AnyObject?, response: NSURLResponse?, error: NSError?) -> Void


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

internal class Renderer : NSObject {
    
    var loadMediaContent : Bool = true
    
    private var renderQueue : NSOperationQueue = {
        let instance = NSOperationQueue()
        instance.maxConcurrentOperationCount = 1
        instance.qualityOfService = .UserInitiated
       return instance
    }()
    
    private var webView : WKWebView!
    
    override init() {
        super.init()
        let doneLoadingWithoutMediaContentScript = "window.webkit.messageHandlers.doneLoading.postMessage(document.documentElement.outerHTML);"
        let userScript = WKUserScript(source: doneLoadingWithoutMediaContentScript, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        /// Note: ...
        let bounds = UIScreen.mainScreen().bounds
        let frame = CGRectOffset(bounds, 0, bounds.size.height)
        webView = WKWebView(frame: frame, configuration: config)
        if let window = UIApplication.sharedApplication().windows.first {
            webView.alpha = 0.01
            window.insertSubview(webView, atIndex: 0)
        }
    }
    
    //
    // MARK: Render Page
    //
    
    internal func renderPageWithRequest(request: NSURLRequest, postAction: PostAction? = nil, completionHandler: Completion) {
        enqueueOperationForRequest(request, postAction: postAction, completionHandler: completionHandler)
    }
    
    private func enqueueOperationForRequest(request: NSURLRequest, postAction: PostAction? = nil, completionHandler: Completion) {
        let operation = RenderOperation(webView: webView)
        operation.name = "Request : \(request.URL?.absoluteString)"
        operation.loadMediaContent = loadMediaContent
        operation.postAction = postAction
        operation.completionBlock = { [weak operation] in
            completionHandler(result: operation?.result, response: operation?.response, error: operation?.error)
        }
        operation.requestBlock = { [weak operation] in
            operation?.webView?.loadRequest(request)
        }
        renderQueue.addOperation(operation)
    }
    
    private func enqueueOperationForScript(script: String, willLoadPage: Bool? = false, postAction: PostAction? = nil, completionHandler: Completion?) {
        let operation = RenderOperation(webView: webView)
        operation.name = "Script : \(script)"
        operation.loadMediaContent = loadMediaContent
        operation.postAction = postAction
        
        if let willLoadPage = willLoadPage where willLoadPage == true {
            operation.completionBlock = { [weak operation] in
                completionHandler?(result: operation?.result, response: operation?.response, error: operation?.error)
            }
            operation.requestBlock = { [weak operation] in
                operation?.webView?.evaluateJavaScript(script, completionHandler: { result, error in
                    print("\(result) - \(error)")
                })
            }
        } else {
            operation.completionBlock = { [weak operation] in
                completionHandler?(result: operation?.result, response: operation?.response, error: operation?.error)
            }
            operation.requestBlock = { [weak operation] in
                operation?.webView?.evaluateJavaScript(script, completionHandler: { result, error in
                    let data = result?.dataUsingEncoding(NSUTF8StringEncoding)
                    operation?.completeRendering(operation?.webView, result: data, error: error)
                })
            }
        }
        renderQueue.addOperation(operation)
    }
    
    //
    // MARK: Execute Script
    //
    
    internal func executeScript(script: String, willLoadPage: Bool? = false, postAction: PostAction? = nil, completionHandler: Completion?) {
        enqueueOperationForScript(script, willLoadPage: willLoadPage, postAction: postAction, completionHandler: completionHandler)
    }
}
