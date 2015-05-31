//
//  CheckBox.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // images
    let checkedImage = UIImage(named: "checked_checkbox") as UIImage!
    let uncheckedImage = UIImage(named: "unchecked_checkbox") as UIImage!
    
    // bool properties
    var isChecked : Bool = false{
        // varje gång isChecked ändras anropas didSet
        didSet{
            if (isChecked == true){
                self.setImage(checkedImage, forState: .Normal)
            }
            else{
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib(){
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender : UIButton){
        if (isChecked == true){
            for stopline in Global.linesAtStop{
                if (stopline.tag == sender.tag){
                    stopline.isChecked = false
                    isChecked = false

                    return
                }
            }
        }
        else if (isChecked == false){
            for stopline in Global.linesAtStop{
                if (stopline.tag == sender.tag){
                    stopline.isChecked = true
                    isChecked = true

                    return
                }
            }
            
        }
    }

}
