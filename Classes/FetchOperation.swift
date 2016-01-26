//
// FetchOperation.swift
//
// Copyright (c) 2016 Mathias Koehnke (http://www.mathiaskoehnke.com)
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

internal class FetchOperation {

    func fetch<T: HTMLFetchableContentType>(fetchable: HTMLFetchable, completion: (result: Result<T>) -> Void) -> NSURLSessionTask? {
        guard let fetchURL = fetchable.fetchURL else {
            return nil
        }
        
        let request = NSURLRequest(URL: fetchURL)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, urlResponse, error) in
            
            //let result = self.handleResponse(data, response: urlResponse, error: error) >>> T.instanceFromData

            //let responseResult: Result<Response> = Result(error, Response(data: data!, urlResponse: urlResponse!))
            //callback(responseResult >>> parseResponse >>> imageFromData(request), request: request)
        })
        task.resume()
        return task
    }
    
    // TODO implement fetchAll

    private func handleResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<NSData> {
        guard let response = response else {
            return Result.Error(.NetworkRequestFailure)
        }
        let errorDomain : ActionError? = (error == nil) ? nil : .NetworkRequestFailure
        let responseResult: Result<Response> = Result(errorDomain, Response(data: data, urlResponse: response))
        return responseResult >>> parseResponse
    }
}

