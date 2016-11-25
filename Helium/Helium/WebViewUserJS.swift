//
//  WebViewUserJS.swift
//  Helium
//
//  Created by shdwprince on 8/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation

class UserJS {
    var include = [NSRegularExpression]()
    var require = [URL]()
    var contents = ""
    var requirements = [String]()

    func shouldEmbedAt(url: URL) -> Bool {
        for regex in self.include {
            if regex.numberOfMatches(in: url.absoluteString, options: [], range: NSMakeRange(0, url.absoluteString.characters.count)) > 0 {
                return true
            }
        }

        return false
    }

    func embedCode() -> String {
        return self.requirements.joined(separator: "\n\n\n\n").appending(self.contents)
    }

    var requirementTasks = [URLSessionTask]()
    func downloadRequirements() {
        if requirementTasks.isEmpty {
            var completionFlags = [Bool]()
            for url in self.require {
                self.requirements.append("")
                completionFlags.append(false)

                let index = self.requirements.count - 1
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data : Data?, _, _) in
                    if let data = data,
                        let script = String.init(data: data, encoding: .utf8) {
                        self.requirements[index] = script
                    }

                    completionFlags[index] = true
                })

                self.requirementTasks.append(task)
                task.resume()
            }

            while true {
                var check = true
                for flag in completionFlags {
                    if !flag {
                        check = false
                    }
                }

                if check {
                    break
                }

                RunLoop.current.run(until: Date().addingTimeInterval(0.5))
            }
        }
    }

    static func parse(contents userJsContents: String) -> UserJS? {
        var include = [NSRegularExpression]()
        var require = [URL]()
        var contents : String?
        
        let getHeaderExpr = try! NSRegularExpression.init(pattern: "==UserScript==(.*?)==/UserScript==(.*)", options: [.dotMatchesLineSeparators])
        let getIncludeExpr = try! NSRegularExpression.init(pattern: "@include\\s+?(.*?)\n", options: [])
        let getRequireExpr = try! NSRegularExpression(pattern: "@require\\s+?(.*?)\n", options: [])

        let headContent = getHeaderExpr.matches(in: userJsContents, options: [], range: NSMakeRange(0, userJsContents.characters.count))
        if headContent.count == 1 {
            contents = (userJsContents as NSString).substring(with: headContent.first!.rangeAt(2))

            let head = (userJsContents as NSString).substring(with: headContent.first!.rangeAt(1))
            for includeExpr in getIncludeExpr.matches(in: head, options: [], range: NSMakeRange(0, head.characters.count)) {
                let expr = (head as NSString).substring(with: includeExpr.rangeAt(1))
                let regexString = expr.replacingOccurrences(of: "*", with: ".*?")
                if let regexExpr = try? NSRegularExpression.init(pattern: regexString, options: []) {
                    include.append(regexExpr)
                }
            }

            for requireExpr in getRequireExpr.matches(in: head, options: [], range: NSMakeRange(0, head.characters.count)) {
                let expr = (head as NSString).substring(with: requireExpr.rangeAt(1))
                if let url = URL.init(string: expr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
                    require.append(url)
                }
            }
        }

        if contents != nil {
            let instance = UserJS.init()
            instance.contents = contents!
            instance.include = include
            instance.require = require
            return instance
        } else {
            return nil
        }
    }

    static var cache = [String: UserJS]()
    static func load(withContentsAt url: URL) -> UserJS? {
        if cache[url.absoluteString] != nil {
            return cache[url.absoluteString]
        } else {
            if let contents = try? String(contentsOf: url),
                let userJs = UserJS.parse(contents: contents) {
                userJs.downloadRequirements()
                cache[url.absoluteString] = userJs
                return userJs
            } else {
                return nil
            }
        }
    }
}

extension WKWebView {
    func callJavascriptFunction(_ fc: String) -> Bool {
        return self.evaluateJavascript("\(fc)();") as? Bool == true
    }
    
    func evaluateJavascript(_ js: String) -> Any? {
        var value : Any?
        var didSet = false
        self.evaluateJavaScript(js) {
            (object: Any?, error: Error?) in
            if let error = error {
                Swift.print(error)
            }
            value = object
            didSet = true
        }

        while !didSet {
            RunLoop.current.run(until: Date().addingTimeInterval(0.016))
        }

        return value
    }

    func embedUserJS(_ location: URL) -> Bool {
        if let js = UserJS.load(withContentsAt: location) {
            let _ = self.evaluateJavascript(js.embedCode())
            return true
        }

        return false
    }
}
