//
//  WebViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-01-31.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    var url = ""
    
    override func viewDidLoad() {
        webView.delegate = self
        webView.scalesPageToFit = true
        
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
}