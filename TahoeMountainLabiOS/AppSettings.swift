//
//  File.swift
//  TahoeMountainLabiOS
//
//  Created by David Paola on 7/16/19.
//  Copyright © 2019 David Paola. All rights reserved.
//

import Foundation

final class AppSettings {
    static let shared = AppSettings()
    
    private let settings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "AppSettings", ofType: "plist")!) as! Dictionary<String, NSObject>
    
    private init() {
        
    }
    
    var baseUrl: URL {
        get {
            return URL(string: settings["BaseURL"] as! String)!
        }
    }
    
    var hasSidebarIcon: Bool {
        get {
            return settings["HasSidebarIcon"] as! Bool
        }
    }
    
    var sidebarTitle: String {
        get {
            return settings["SidebarTitle"] as! String
        }
    }
}
