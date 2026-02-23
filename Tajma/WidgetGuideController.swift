//
//  WidgetGuideController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2017-01-16.
//  Copyright © 2017 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WidgetGuideController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20
        
        do {
            // TODO: Add gif
            //let gif = try UIImage(gifName: "high-quality-widget-guide.gif")
            //let imageview = UIImageView(gifImage: gif, loopCount: -1)
            let image = UIImage(named: "high-quality-widget-guide.gif")
            let imageview = UIImageView(image: image)
            imageview.frame = CGRect(x: self.view.frame.midX - 137, y: 115 + topPadding, width: 274, height: 492)
            view.addSubview(imageview)
        } catch {
            print(error)
        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
