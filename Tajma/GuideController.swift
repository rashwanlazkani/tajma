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
    
    var guideImageIndex = 0
    let guideImages = ["guide_1", "guide_2", "guide_3", "guide_4"]
    let guideImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        navigationController?.navigationBar.hidden = true
        start()
    }
    
    func start(){
        guideImageView.image = UIImage(named: guideImages[0])
        guideImageView.frame = CGRectMake(0, 0, CGFloat(deviceHelper.screenWidth), CGFloat(deviceHelper.screenHeight))
        self.view.addSubview(guideImageView)
        
        addButtons(0)
    }
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.Right :
            // check if index is in range
            if guideImageIndex > 0 {
                guideImageIndex -= 1
            }
            
            guideImageView.image = UIImage(named: guideImages[guideImageIndex])
            
        case UISwipeGestureRecognizerDirection.Left:
            // check if index is in range
            if guideImageIndex < guideImages.count - 1{
                guideImageIndex += 1
            }
            
            guideImageView.image = UIImage(named: guideImages[guideImageIndex])
        default:
            break //stops the code/codes nothing.
        }
        addButtons(guideImageIndex)
    }
    
    func addButtons(index : Int){
        for view in self.view.subviews {
            if view.isKindOfClass(UIImageView){
                if view.tag == 999{
                    view.removeFromSuperview()
                }
            }
            else if view.isKindOfClass(UIButton){
                view.removeFromSuperview()
            }
        }
        
        let closeButton = UIButton()
        let img = UIImage(named: "close")
        closeButton.setImage(img, forState: .Normal)
        closeButton.addTarget(self, action: #selector(startApp), forControlEvents: .TouchUpInside)
        closeButton.frame = CGRectMake(view.frame.width - 45, 25, 40, 40)
        self.view.addSubview(closeButton)
        
        let button1 = UIButton()
        button1.layer.borderColor = UIColor.whiteColor().CGColor
        button1.layer.borderWidth = 2
        button1.layer.cornerRadius = 22
        
        let button2 = UIButton()
        button2.layer.borderColor = UIColor.whiteColor().CGColor
        button2.layer.borderWidth = 2
        button2.layer.cornerRadius = 22
        
        let gifImageView = UIImageView(frame: CGRect(x: 60, y: DeviceHelper.gifY(), width: view.frame.width - 120, height: DeviceHelper.gifHeight()))
        gifImageView.tag = 999
        switch index {
        case 0 :
            button2.setImage(UIImage(named: "right"), forState: .Normal)
            button2.layer.borderColor = UIColor.whiteColor().CGColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 22
            button2.setTitle(" Visa mig  ", forState: .Normal)
            button2.addTarget(self, action: #selector(next), forControlEvents: .TouchUpInside)
            button2.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.backgroundColor = .whiteColor()
            button2.titleLabel?.font = .boldSystemFontOfSize(18)
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: .Normal)
            button1.frame = CGRectMake(self.view.frame.width - 80, 20, 90, 44)
            button2.frame = CGRectMake(0, DeviceHelper.showGuideY(), 170, 45)
            button2.center.x = self.view.center.x
            view.addSubview(button2)
        case 1, 2 :
            gifImageView.image = UIImage.gifWithName("tajma-gif-\(index)")
            view.addSubview(gifImageView)
            button1.setImage(UIImage(named: "left"), forState: .Normal)
            button1.addTarget(self, action: #selector(previous), forControlEvents: .TouchUpInside)
            button1.layer.cornerRadius = 22
            button1.backgroundColor = .whiteColor()
            
            button2.setTitle("Nästa  ", forState: .Normal)
            button2.addTarget(self, action: #selector(next), forControlEvents: .TouchUpInside)
            
            button2.setImage(UIImage(named: "right"), forState: .Normal)
            button2.backgroundColor = .whiteColor()
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: .Normal)
            button2.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.titleLabel?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.imageView?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            
            button1.frame = CGRectMake((view.frame.width / 2) - 70, view.frame.height - 65, 44, 44)
            button2.frame = CGRectMake(view.frame.width / 2, view.frame.height - 65, 125, 45)
            button1.center.x = view.center.x - 80
            button2.center.x = view.center.x + 40
            
            view.addSubview(button1)
            view.addSubview(button2)
            
        case 3 :
            let gif = UIImage.gifWithName("tajma-gif-3")
            gifImageView.image = gif
            view.addSubview(gifImageView)
            
            let img = UIImage(named: "left")
            button1.setImage(img, forState: .Normal)
            button1.addTarget(self, action: #selector(previous), forControlEvents: .TouchUpInside)
            button1.backgroundColor = UIColor.whiteColor()
            
            button2.setTitle("Stäng guide", forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.addTarget(self, action: #selector(startApp), forControlEvents: .TouchUpInside)
            button2.setTitleColor(UIColor(red: 233/255, green: 64/255, blue: 87/255, alpha: 1), forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: .Normal)
            
            button1.frame = CGRectMake((view.frame.width / 2) - 70, view.frame.height - 65, 44, 44)
            button2.frame = CGRectMake(view.frame.width / 2, view.frame.height - 65, 125, 45)
            button1.center.x = view.center.x - 80
            button2.center.x = view.center.x + 40
            
            view.addSubview(button1)
            view.addSubview(button2)
            
        default:
            return
        }
    }
    
    func next() {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Left
        swiped(swipeGesture)
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        view.layer.addAnimation(animation, forKey: ";SwitchToView1")
    }
    
    func previous() {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .Right
        swiped(swipeGesture)
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromLeft
        view.layer.addAnimation(animation, forKey: ";SwitchToView1")
    }
    
    func startApp() {
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        guideImageView.removeFromSuperview()
        performSegueWithIdentifier("ShowStops", sender: nil)
    }
}