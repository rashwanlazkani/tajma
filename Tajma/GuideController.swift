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
        
        let button1 = UIButton()
        button1.layer.borderColor = UIColor.whiteColor().CGColor
        button1.layer.borderWidth = 2
        button1.layer.cornerRadius = 20
        button1.setTitle("Avsluta", forState: .Normal)
        button1.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
        
        let button2 = UIButton()
        button2.layer.borderColor = UIColor.whiteColor().CGColor
        button2.layer.borderWidth = 2
        button2.layer.cornerRadius = 20
        button2.setTitle("Visa mig >", forState: .Normal)
        button2.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        
        if (DeviceHelper.isFourOrFive()){
            button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 65, 90, 45)
            button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 65, 150, 45)
        }
        else{
            button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 75, 90, 45)
            button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 75, 150, 45)
        }
        self.view.addSubview(button1)
        self.view.addSubview(button2)
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
            if (view.isKindOfClass(UIButton)){
                view.removeFromSuperview()
            }
        }
        
        switch index {
        case 0 :
            let button1 = UIButton()
            button1.layer.borderColor = UIColor.whiteColor().CGColor
            button1.layer.borderWidth = 2
            button1.layer.cornerRadius = 20
            button1.setTitle("Avsluta", forState: .Normal)
            button1.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
            
            let button2 = UIButton()
            button2.layer.borderColor = UIColor.whiteColor().CGColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 20
            button2.setTitle("Visa mig >", forState: .Normal)
            button2.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
            
            if (DeviceHelper.isFourOrFive()){
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 65, 90, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 65, 150, 45)
            }
            else{
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 75, 90, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 75, 150, 45)
            }
            
            self.view.addSubview(button1)
            self.view.addSubview(button2)
        case 1, 2, 3, 4 :
            let button1 = UIButton()
            
            button1.layer.borderColor = UIColor.whiteColor().CGColor
            button1.layer.borderWidth = 2
            button1.layer.cornerRadius = 20
            button1.setTitle("<", forState: .Normal)
            button1.addTarget(self, action: "previous", forControlEvents: .TouchUpInside)
            
            let button2 = UIButton()
            button2.layer.borderColor = UIColor.whiteColor().CGColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 20
            button2.setTitle("Nästa >", forState: .Normal)
            button2.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
            
            if (DeviceHelper.isFourOrFive()){
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 65, 45, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2 + 15, self.view.frame.height - 65, 100, 45)
            }
            else{
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 75, 45, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2 + 15, self.view.frame.height - 75, 100, 45)
            }
            self.view.addSubview(button1)
            self.view.addSubview(button2)
            
        case 5 :
            let button1 = UIButton()
            
            button1.layer.borderColor = UIColor.whiteColor().CGColor
            button1.layer.borderWidth = 2
            button1.layer.cornerRadius = 20
            button1.setTitle("<", forState: .Normal)
            button1.addTarget(self, action: "previous", forControlEvents: .TouchUpInside)
            
            let button2 = UIButton()
            button2.layer.borderColor = UIColor.whiteColor().CGColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 20
            button2.setTitle("TAJMA AVÅNG!", forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            button2.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
            button2.setTitleColor(UIColor(red: 233/255, green: 64/255, blue: 87/255, alpha: 1), forState: UIControlState.Normal)
            
            
            if (DeviceHelper.isFourOrFive()){
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 65, 45, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2 - 50, self.view.frame.height - 65, 200, 45)
            }
            else{
                button1.frame = CGRectMake((self.view.frame.width / 2) - 130, self.view.frame.height - 75, 45, 45)
                button2.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.height - 75, 300, 45)
            }
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