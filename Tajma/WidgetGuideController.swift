//
//  WidgetGuideController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2017-01-16.
//  Copyright © 2017 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WidgetGuideController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationBar.items?[0].title = "Tajmas Widget"
        navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        imageView.image = UIImage.gifImageWithName("high-quality-widget-guide")
        
        switch UIScreen.width {
        case 320:
            bottomConstant.constant = 10
        case 375:
            bottomConstant.constant = 65
        case 414:
            bottomConstant.constant = 125
        default:
            bottomConstant.constant = 105
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
