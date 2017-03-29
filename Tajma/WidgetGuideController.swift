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
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        UIApplication.shared.statusBarStyle = .lightContent
//        imageView.image = UIImage.gifWithName("video-2")
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
