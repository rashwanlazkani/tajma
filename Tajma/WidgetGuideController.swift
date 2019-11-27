//
//  WidgetGuideController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2017-01-16.
//  Copyright © 2017 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WidgetGuideController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationBar.items?[0].title = "Tajmas Widget"
        
        imageView.image = UIImage.gifImageWithName("high-quality-widget-guide")
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
