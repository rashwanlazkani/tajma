//
//  CheckBox.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // images
    let checkedImage = UIImage(named: "check-box-red") as UIImage!
    let uncheckedImage = UIImage(named: "unchecked-box") as UIImage!
    
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
        
        println(sender.tag)
        
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
    
    func getImage(index : Int) -> UIImage{
        for stopline in Global.linesAtStop{
            if (stopline.tag == index){
                if (stopline.isChecked){
                    return checkedImage
                }
                else{
                    return uncheckedImage
                }
            }
        }
        
        return UIImage()
    }

}
