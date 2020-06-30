//
//  AuthenticationController.swift
//  TahoeMountainLabiOS
//
//  Created by David Paola on 3/13/19.
//  Copyright © 2019 David Paola. All rights reserved.
//

import UIKit
import WebKit

protocol ModalViewControllerDelegate: class {
    func modalViewControllerDidSucceed(_ controller: ModalViewController)
}

class ModalViewController: UIViewController {
    var url: URL?
    var webViewConfiguration: WKWebViewConfiguration?
    weak var delegate: ModalViewControllerDelegate?
    
    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(self.webView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: [ "view": self.webView ]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: [ "view": self.webView ]))
        
        if let url = self.url {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc @IBAction func cancelModal(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModalViewController: WKNavigationDelegate {
    
    // Posthook
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.allow)
            return
        }
        
        guard let url = httpResponse.url else {
            decisionHandler(.allow)
            return
        }
        
        // TODO: Error handling, do something with httpResponse.statusCode
        
        if url != self.url {
            delegate?.modalViewControllerDidSucceed(self)
        }
        
        decisionHandler(.allow)
    }
}
