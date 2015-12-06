//
//  GuideController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-12-06.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class GuideController: UIViewController{
    let deviceHelper = DeviceHelper()
    
    var guideImageIndex: NSInteger = 0
    let guideImages = ["guide-1", "guide-2", "guide-3", "guide-4", "guide-5", "guide-6"]
    let guideImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        start()
    }
    
    func start(){
        guideImageView.image = UIImage(named: guideImages[0])
        guideImageView.frame = CGRectMake(0, 0, CGFloat(deviceHelper.screenWidth), CGFloat(deviceHelper.screenHeight))
        self.view.addSubview(guideImageView)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
    func swiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right :
                // decrease index first
                guideImageIndex--
                
                // check if index is in range
                if guideImageIndex < 0 {
                    guideImageIndex = 0
                }
                
                guideImageView.image = UIImage(named: guideImages[guideImageIndex])
                
            case UISwipeGestureRecognizerDirection.Left:
                // increase index first
                guideImageIndex++
                
                if guideImageIndex == guideImages.count - 1{
                    let myFirstButton = UIButton()
                    myFirstButton.frame = CGRectMake(0, self.view.frame.height - 75, CGFloat(deviceHelper.screenWidth), 75)
                    myFirstButton.addTarget(self, action: "startApp:", forControlEvents: .TouchUpInside)
                    self.view.addSubview(myFirstButton)
                }
                
                // check if index is in range
                if guideImageIndex > guideImages.count - 1{
                    guideImageIndex = 0
                }
                
                guideImageView.image = UIImage(named: guideImages[guideImageIndex])
            default:
                break //stops the code/codes nothing.
            }
        }
    }
    
    func startApp(sender: UIButton){
        guideImageView.removeFromSuperview()
        self.performSegueWithIdentifier("ShowStops", sender: nil)
    }
}