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
    let guideImages = ["guide_1", "guide_2", "guide_3", "guide_4"]
    let guideImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
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
        
        addButtons(0)
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right :
                // check if index is in range
                if guideImageIndex > 0 {
                     guideImageIndex--
                }

                guideImageView.image = UIImage(named: guideImages[guideImageIndex])
                
            case UISwipeGestureRecognizerDirection.Left:
                // check if index is in range
                if guideImageIndex < guideImages.count - 1{
                    guideImageIndex++
                }
                
                guideImageView.image = UIImage(named: guideImages[guideImageIndex])
            default:
                break //stops the code/codes nothing.
            }
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
        closeButton.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
        closeButton.frame = CGRectMake(self.view.frame.width - 35, 25, 20, 20)
        self.view.addSubview(closeButton)
        
        let button1 = UIButton()
        button1.layer.borderColor = UIColor.whiteColor().CGColor
        button1.layer.borderWidth = 2
        button1.layer.cornerRadius = 22
        
        let button2 = UIButton()
        button2.layer.borderColor = UIColor.whiteColor().CGColor
        button2.layer.borderWidth = 2
        button2.layer.cornerRadius = 22
        
        let gifImageView = UIImageView(frame: CGRect(x: 60, y: DeviceHelper.gifY(), width: self.view.frame.width - 120, height: DeviceHelper.gifHeight()))
        gifImageView.tag = 999
        switch index {
        case 0 :
            let imgTwo = UIImage(named: "right")
            button2.setImage(imgTwo, forState: .Normal)
            button2.layer.borderColor = UIColor.whiteColor().CGColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 22
            button2.setTitle(" Visa mig  ", forState: .Normal)
            button2.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
            button2.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.backgroundColor = UIColor.whiteColor()
            button2.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: UIControlState.Normal)
            button1.frame = CGRectMake(self.view.frame.width - 80, 20, 90, 44)
            button2.frame = CGRectMake(0, DeviceHelper.showGuideY(), 170, 45)
            button2.center.x = self.view.center.x
            
            self.view.addSubview(button2)
        case 1, 2 :
            if (index == 1){
                let gif = UIImage.gifWithName("tajma-gif-1")
                gifImageView.image = gif
                self.view.addSubview(gifImageView)
            }
            else{
                let gif = UIImage.gifWithName("tajma-gif-2")
                gifImageView.image = gif
                self.view.addSubview(gifImageView)
            }
            
            let img = UIImage(named: "left")
            button1.setImage(img, forState: .Normal)
            button1.addTarget(self, action: "previous", forControlEvents: .TouchUpInside)
            button1.layer.cornerRadius = 22
            button1.backgroundColor = UIColor.whiteColor()
            
            button2.setTitle("Nästa  ", forState: .Normal)
            button2.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
            
            let imgTwo = UIImage(named: "right")
            button2.setImage(imgTwo, forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: UIControlState.Normal)
            button2.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            button2.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            
            button1.frame = CGRectMake((self.view.frame.width / 2) - 70, self.view.frame.height - 65, 44, 44)
            button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 65, 125, 45)
            button1.center.x = self.view.center.x - 80
            button2.center.x = self.view.center.x + 40
            
            self.view.addSubview(button1)
            self.view.addSubview(button2)
            
        case 3 :
            let gif = UIImage.gifWithName("tajma-gif-3")
            gifImageView.image = gif
            self.view.addSubview(gifImageView)
            
            let img = UIImage(named: "left")
            button1.setImage(img, forState: .Normal)
            button1.addTarget(self, action: "previous", forControlEvents: .TouchUpInside)
            button1.backgroundColor = UIColor.whiteColor()
            
            button2.setTitle("Stäng guide", forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
            button2.setTitleColor(UIColor(red: 233/255, green: 64/255, blue: 87/255, alpha: 1), forState: UIControlState.Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), forState: UIControlState.Normal)
            
            button1.frame = CGRectMake((self.view.frame.width / 2) - 70, self.view.frame.height - 65, 44, 44)
            button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 65, 125, 45)
            button1.center.x = self.view.center.x - 80
            button2.center.x = self.view.center.x + 40
            
            self.view.addSubview(button1)
            self.view.addSubview(button2)
            
        default:
            return
        }
    }
    
    func next(){
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Left
        swiped(swipeGesture)
    }
    
    func previous(){
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Right
        swiped(swipeGesture)
    }
    
    func startApp(){
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true
        guideImageView.removeFromSuperview()
        self.performSegueWithIdentifier("ShowStops", sender: nil)
    }
}