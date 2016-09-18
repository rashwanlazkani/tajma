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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        start()
    }
    
    func start(){
        guideImageView.image = UIImage(named: guideImages[0])
        guideImageView.frame = CGRect(x: 0, y: 0, width: CGFloat(deviceHelper.screenWidth), height: CGFloat(deviceHelper.screenHeight))
        self.view.addSubview(guideImageView)
        
        addButtons(0)
    }
    
    func swiped(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right :
            // check if index is in range
            if guideImageIndex > 0 {
                guideImageIndex -= 1
            }
            
            guideImageView.image = UIImage(named: guideImages[guideImageIndex])
            
        case UISwipeGestureRecognizerDirection.left:
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
    
    func addButtons(_ index : Int){
        for view in self.view.subviews {
            if view.isKind(of: UIImageView.self){
                if view.tag == 999{
                    view.removeFromSuperview()
                }
            }
            else if view.isKind(of: UIButton.self){
                view.removeFromSuperview()
            }
        }
        
        let closeButton = UIButton()
        let img = UIImage(named: "close")
        closeButton.setImage(img, for: UIControlState())
        closeButton.addTarget(self, action: #selector(startApp), for: .touchUpInside)
        closeButton.frame = CGRect(x: view.frame.width - 45, y: 25, width: 40, height: 40)
        self.view.addSubview(closeButton)
        
        let button1 = UIButton()
        button1.layer.borderColor = UIColor.white.cgColor
        button1.layer.borderWidth = 2
        button1.layer.cornerRadius = 22
        
        let button2 = UIButton()
        button2.layer.borderColor = UIColor.white.cgColor
        button2.layer.borderWidth = 2
        button2.layer.cornerRadius = 22
        
        let gifImageView = UIImageView(frame: CGRect(x: 60, y: DeviceHelper.gifY(), width: view.frame.width - 120, height: DeviceHelper.gifHeight()))
        gifImageView.tag = 999
        switch index {
        case 0 :
            button2.setImage(UIImage(named: "right"), for: UIControlState())
            button2.layer.borderColor = UIColor.white.cgColor
            button2.layer.borderWidth = 2
            button2.layer.cornerRadius = 22
            button2.setTitle(" Visa mig  ", for: UIControlState())
            button2.addTarget(self, action: #selector(getter: next), for: .touchUpInside)
            button2.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button2.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button2.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button2.backgroundColor = UIColor.white
            button2.titleLabel?.font = .boldSystemFont(ofSize: 18)
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), for: UIControlState())
            button1.frame = CGRect(x: self.view.frame.width - 80, y: 20, width: 90, height: 44)
            button2.frame = CGRect(x: 0, y: DeviceHelper.showGuideY(), width: 170, height: 45)
            button2.center.x = self.view.center.x
            view.addSubview(button2)
        case 1, 2 :
            gifImageView.image = UIImage.gifWithName("tajma-gif-\(index)")
            view.addSubview(gifImageView)
            button1.setImage(UIImage(named: "left"), for: UIControlState())
            button1.addTarget(self, action: #selector(previous), for: .touchUpInside)
            button1.layer.cornerRadius = 22
            button1.backgroundColor = UIColor.white
            
            button2.setTitle("Nästa  ", for: UIControlState())
            button2.addTarget(self, action: #selector(getter: next), for: .touchUpInside)
            
            button2.setImage(UIImage(named: "right"), for: UIControlState())
            button2.backgroundColor = UIColor.white
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), for: UIControlState())
            button2.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button2.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button2.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
            button1.frame = CGRect(x: (view.frame.width / 2) - 70, y: view.frame.height - 65, width: 44, height: 44)
            button2.frame = CGRect(x: view.frame.width / 2, y: view.frame.height - 65, width: 125, height: 45)
            button1.center.x = view.center.x - 80
            button2.center.x = view.center.x + 40
            
            view.addSubview(button1)
            view.addSubview(button2)
            
        case 3 :
            let gif = UIImage.gifWithName("tajma-gif-3")
            gifImageView.image = gif
            view.addSubview(gifImageView)
            
            let img = UIImage(named: "left")
            button1.setImage(img, for: UIControlState())
            button1.addTarget(self, action: #selector(previous), for: .touchUpInside)
            button1.backgroundColor = UIColor.white
            
            button2.setTitle("Stäng guide", for: UIControlState())
            button2.backgroundColor = UIColor.white
            button2.addTarget(self, action: #selector(startApp), for: .touchUpInside)
            button2.setTitleColor(UIColor(red: 233/255, green: 64/255, blue: 87/255, alpha: 1), for: UIControlState())
            button2.backgroundColor = UIColor.white
            button2.setTitleColor(UIColor(red: 229/255, green: 66/255, blue: 90/255, alpha: 1), for: UIControlState())
            
            button1.frame = CGRect(x: (view.frame.width / 2) - 70, y: view.frame.height - 65, width: 44, height: 44)
            button2.frame = CGRect(x: view.frame.width / 2, y: view.frame.height - 65, width: 125, height: 45)
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
        swipeGesture.direction = UISwipeGestureRecognizerDirection.left
        swiped(swipeGesture)
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        view.layer.add(animation, forKey: ";SwitchToView1")
    }
    
    func previous() {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .right
        swiped(swipeGesture)
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromLeft
        view.layer.add(animation, forKey: ";SwitchToView1")
    }
    
    func startApp() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        guideImageView.removeFromSuperview()
        performSegue(withIdentifier: "ShowStops", sender: nil)
    }
}
