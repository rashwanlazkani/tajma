//
//  CheckBox.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    let checkedImage = UIImage(named: "check-box-red") as UIImage!
    let uncheckedImage = UIImage(named: "unchecked-box") as UIImage!
    
    var isChecked : Bool = false{
        didSet{
            if (isChecked == true){
                self.setImage(checkedImage, forState: .Normal)
                self.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
                self.sendSubviewToBack(self)
            }
            else{
                self.setImage(uncheckedImage, forState: .Normal)
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override func awakeFromNib(){
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func buttonClicked(sender : UIButton){
        isChecked = !isChecked
        for stopLine in Global.linesAtStop{
            if (stopLine.tag == sender.tag){
                stopLine.isChecked = isChecked
                RealmService.sharedInstance.updateLinesToStop(stopLine)
                return
            }
            
        }
    }
    
}
