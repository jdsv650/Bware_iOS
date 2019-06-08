//
//  DestinationWebsiteViewController.swift
//  Bware
//
//  Created by James on 1/4/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import WebKit

class DestinationWebsiteViewController: UIViewController, WKNavigationDelegate {

    var urlAsString :String?
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let urlString = urlAsString
        {
            let url = URL(string: urlString)
            if let u = url {
                webView.load(URLRequest(url: u))
                webView.allowsBackForwardNavigationGestures = true
            }
        }
        else
        {
            Helper.showUserMessage(title: "Website failed to load", theMessage: "Check URL", theViewController: self)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        Helper.showUserMessage(title: "Website failed to load", theMessage: error.localizedDescription, theViewController: self)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Helper.showUserMessage(title: "Website failed to load", theMessage: error.localizedDescription, theViewController: self)
    }



}
