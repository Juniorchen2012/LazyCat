//
//  JSBridge.swift
//  LazyCat
//
//  Created by zfu on 2016/10/27.
//  Copyright © 2016年 zfu. All rights reserved.
//

import Foundation
import TVMLKit

@objc protocol JBExports : JSExport {
    static func httpPost(_ urlString: String,_ Referer: String,_ PostData: String) -> String
    static func httpGet(_ urlString: String,_ userAgent: String, _ Referer: String,_ Cookie: String) -> String
}

@objc class JSBridge : NSObject, JBExports {
    static func httpPost(_ urlString: String,_ Referer: String,_ PostData: String) -> String {
        print("call httpPost \(urlString) \(Referer) \(PostData)")
        var resultStr = ""
        let semaphore = DispatchSemaphore(value:0)
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue(Referer, forHTTPHeaderField: "Referer")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/601.5.17 (KHTML, like Gecko) Version/9.1 Safari/601.5.17", forHTTPHeaderField: "User-Agent")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.httpBody = PostData.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if (data != nil) {
                resultStr = String(data: data!, encoding: String.Encoding.utf8)!
            } else {
                resultStr = (error?.localizedDescription)!
            }
            semaphore.signal()
        })
        task.resume()
        if (semaphore.wait(timeout: DispatchTime.distantFuture) == DispatchTimeoutResult.timedOut) {
            print("timeout when request \(urlString)")
        }
        return resultStr
    }
    static func httpGet(_ urlString: String,_ userAgent: String, _ Referer: String,_ Cookie: String) -> String {
        print("call httpGet \(urlString) \(Referer) \(Cookie)")
        var resultStr = ""
        let semaphore = DispatchSemaphore(value:0)
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue(Referer, forHTTPHeaderField: "Referer")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(Cookie, forHTTPHeaderField: "Cookie");
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("close", forHTTPHeaderField: "Connection")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if (data != nil) {
                resultStr = String(data: data!, encoding: String.Encoding.utf8)!
            } else {
                resultStr = (error?.localizedDescription)!
            }
            semaphore.signal()
        })
        task.resume()
        if (semaphore.wait(timeout: DispatchTime.distantFuture) == DispatchTimeoutResult.timedOut) {
            print("timeout when request \(urlString)")
        }
        return resultStr
    }
}
