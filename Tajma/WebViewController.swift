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
    let deviceHelper = DeviceHelper()
    var titleForView = ""
    
    override func viewDidLoad() {
        let titleLabel = UILabel(frame: CGRectMake(0, 7, 200, 30))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = titleLabel.font.fontWithSize(19)
        titleLabel.text = titleForView
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = titleView
        titleView.addSubview(titleLabel)
        
        webView.delegate = self
        webView.scalesPageToFit = true
        
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
}