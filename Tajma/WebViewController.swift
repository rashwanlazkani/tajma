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
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var url = ""
    let deviceHelper = DeviceHelper()
    var titleForView = ""
    
    override func viewDidLoad() {
        navigationBar.items?[0].title = titleForView
        navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        webView.delegate = self
        webView.scalesPageToFit = true
        
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL!)
        webView.loadRequest(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}
