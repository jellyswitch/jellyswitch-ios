//
//  ApplicationController.swift
//  TahoeMountainLabiOS
//
//  Created by David Paola on 3/13/19.
//  Copyright © 2019 David Paola. All rights reserved.
//

import UIKit
import WebKit
import Turbolinks
import SwiftyJSON
import SideMenu

enum ModalActivity {
    case SignIn
    case SignUp
    case NewPost
}

class ApplicationController: UINavigationController {
    
    lazy var menuButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "MenuIcon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(presentSidebar))
    }()
    
    var navItems: [NavItem]?
    
    // MARK: - TurboLinks Requirements
    
    fileprivate lazy var webViewConfiguration: WKWebViewConfiguration = {
        let applicationName = "Jellyswitch"
        let configuration = WKWebViewConfiguration()
        
        configuration.userContentController.add(self, name: "ApplicationController")
        configuration.processPool = WKProcessPool()
        
        guard let deviceToken = UserDefaults.standard
            .data(forKey: "deviceToken")?
            .reduce("", {$0 + String(format: "%02X", $1)}) else {
            configuration.applicationNameForUserAgent =  applicationName
            return configuration
        }
        
        let applicationNameWithDeviceToken = "\(applicationName)  deviceToken: \(deviceToken)"
        configuration.applicationNameForUserAgent = applicationNameWithDeviceToken
        print (applicationNameWithDeviceToken)
        return configuration
    }()
    
    fileprivate lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    // MARK: - View Management
    
    // Called when the view is first loaded into memory and only called
    // once for this instance. Template methods such as viewDidLoad must
    // call super.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Switching this to false will prevent content from sitting beneath scrollbar
        self.navigationBar.isTranslucent = false
        
        let visitable = MainViewController(url: AppSettings.shared.baseUrl)
        self.present(visitable: visitable)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentModal" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ModalViewController
            let identifier = sender as! ModalActivity
            
            controller.delegate = self
            controller.webViewConfiguration = self.webViewConfiguration
            
            switch identifier {
            case .NewPost:
                controller.url = AppSettings.shared.baseUrl.appendingPathComponent("feed_items/new")
                controller.title = "New Post"
            case .SignUp:
                controller.url = AppSettings.shared.baseUrl.appendingPathComponent("signup")
                controller.title = "Sign up"
            case .SignIn:
                controller.url = AppSettings.shared.baseUrl.appendingPathComponent("login")
                controller.title = "Sign in"
            }
        }
        if segue.identifier == "PresentSidebar" {
            let sideMenuNavigationController = segue.destination as! SideMenuNavigationController
            
            sideMenuNavigationController.menuWidth = view.frame.width * 0.8
            sideMenuNavigationController.blurEffectStyle = .extraLight
            sideMenuNavigationController.statusBarEndAlpha = 0
            sideMenuNavigationController.presentationStyle.backgroundColor = UIColor(patternImage: UIImage(named: "SidebarBackground")!)

            
            let navMenuController = sideMenuNavigationController.topViewController as! NavMenuController
            navMenuController.navItems = self.navItems
            navMenuController.delegate = self
        }
    }
    
    // MARK: -
    
    func visit(url: URL) {
        let visitable = MainViewController(url: url)
        self.present(visitable: visitable, action: .Restore)
    }
    
    fileprivate func present(visitable: Turbolinks.VisitableViewController, action: Action = .Advance) {
    
        visitable.navigationItem.rightBarButtonItem = self.menuButton
        
        switch action {
        case .Advance:
            self.pushViewController(visitable, animated: true)
        case .Replace:
            self.popViewController(animated: false)
            self.pushViewController(visitable, animated: false)
        case .Restore:
            self.setViewControllers([visitable], animated: false)
            self.popToRootViewController(animated: false)
        }

        self.session.visit(visitable)
    }
    
    // MARK: - Navigation
    
    @objc func presentSidebar() {
        self.performSegue(withIdentifier: "PresentSidebar", sender: self.menuButton)
    }
 
}

// MARK: - Session Delegate

extension ApplicationController: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {
        if URL.path == "/feed_items/new" {
            self.performSegue(withIdentifier: "PresentModal", sender: ModalActivity.NewPost)
        } /*else if URL.path == "/login" {
            self.performSegue(withIdentifier: "PresentModal", sender: ModalActivity.SignIn)
        } else if URL.path == "/signup" {
            self.performSegue(withIdentifier: "PresentModal", sender: ModalActivity.SignUp)
        } */else {
            let visitable = MainViewController(url: URL)
            self.present(visitable: visitable, action: action)
        }
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        
        // Will show authentication modal elewhere
        // presentAuthenticationController
        
        // Show the Error View Controller
        
        guard let errorCode = ErrorCode(rawValue: error.code) else {
            // TODO: handle
            return
        }
        
        let myError = Error.with(error: error, errorCode: errorCode)
        
        let alert = UIAlertController(title: myError.title, message: myError.message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Default action"), style: .default, handler: { _ in
            
            if let viewController = self.topViewController as? Turbolinks.VisitableViewController {
                viewController.reloadVisitable()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sessionDidStartRequest(_ session: Session) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(_ session: Session) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - Authentication Controller Delegate

extension ApplicationController: ModalViewControllerDelegate {
    func modalViewControllerDidSucceed(_ controller: ModalViewController) {
        session.reload()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKScriptMessageHandler

extension ApplicationController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        /*if let message = message.body as? String {
            let alertController = UIAlertController(title: "Turbolinks", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }*/
        if let dataFromString = (message.body as! NSString).data(using: String.Encoding.utf8.rawValue) {
            guard let json = try? JSON(data: dataFromString) else {
                print("Could not decode JSON for nav menu")
                // TODO: handle error
                return
            }
            
            self.navItems = self.parseNavItems(json: json)
        }
    }
    
    func parseNavItems(json: JSON) -> [NavItem] {
        var navItems: [NavItem] = []
        
        for index in 0..<json.count {
            let title = json[index]["title"].stringValue
            let path = json[index]["path"].stringValue
            
            let url = AppSettings.shared.baseUrl.appendingPathComponent(path)
            
            navItems.append(NavItem(title: title, path: url))
        }
        
        return navItems
    }
}

// MARK: - Nav Menu Controller Delegate

extension ApplicationController: NavMenuControllerDelegate {
    func navMenuController(_: NavMenuController, didSelectItem item: NavItem) {
        self.visit(url: item.path)
        self.dismiss(animated: true, completion: nil)
    }
}

