//
//  Error.swift
//  TahoeMountainLabiOS
//
//  Created by David Paola on 10/1/18.
//  Copyright © 2018 David Paola. All rights reserved.
//

import Foundation
import Turbolinks

struct Error {
    static let HTTPNotFoundError = Error(title: "Page Not Found", message: "There doesn’t seem to be anything here.")
    static let NetworkError = Error(title: "Can’t Connect", message: "Can’t connect to the server. Please try again later.")
    static let UnknownError = Error(title: "Unknown Error", message: "An unknown error occurred.")
    
    let title: String
    let message: String
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    init(HTTPStatusCode: Int) {
        self.title = "Server Error"
        self.message = "The server returned an HTTP \(HTTPStatusCode) response."
    }
    
    static func with(error: NSError, errorCode: ErrorCode) -> Error {
        switch errorCode {
        case .httpFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 404:
                return Error.HTTPNotFoundError
            default:
                return Error(HTTPStatusCode: statusCode)
            }
        case .networkFailure:
            return Error.NetworkError
        }
    }
}
