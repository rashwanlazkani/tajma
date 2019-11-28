//
//  WebViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-01-31.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var url = ""
    var titleForView = ""
    
    override func viewDidLoad() {
        
        titleLabel.text = titleForView
        
        self.navigationView.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        webView.navigationDelegate = self
    
        activityIndicator.startAnimating()

        if let requestUrl = URL(string: url) {
            webView.load(URLRequest(url: requestUrl))
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
         _ = navigationController?.popViewController(animated: true)
    }
}
