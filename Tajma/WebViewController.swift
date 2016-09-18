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
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 7, width: 200, height: 30))
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.white
        titleLabel.font = titleLabel.font.withSize(19)
        titleLabel.text = titleForView
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = titleView
        titleView.addSubview(titleLabel)
        
        webView.delegate = self
        webView.scalesPageToFit = true
        
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL!)
        webView.loadRequest(request)
    }
}
