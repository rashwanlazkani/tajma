//
//  OmOssViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-01-10.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit

class OmOssViewController: UIViewController {
    @IBOutlet weak var txtField: UITextView!
    let deviceHelper = DeviceHelper()
    
    override func viewDidLoad() {
        let title = UILabel(frame: CGRectMake(0, 7, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(19)
        title.text = "Om oss"
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = titleView
        titleView.addSubview(title)
        
        txtField.attributedText = attributedText()
    }
    
    func attributedText()->NSAttributedString{
        var size = 0.0
        if UIScreen.mainScreen().bounds.height == 480{
            size = 15.0
        }
        else{
            size = 16.0
        }
        let string = "Vi har som mål med Tajma att förenkla vardagen för dig och dina vänner. Vi arbetar kontinuerligt med uppdateringar av appen. I nuläget fungerar Tajma för Västtrafiks linjer men vi jobbar på att inkludera Skånetrafiken och Storstockholms Lokaltrafik. Om du har några frågor till Tajma-teamet, maila oss gärna på tajma@golazo.nu.\n\nTack för att du använder Tajma!\n\nVänliga hälsningar,\n\nRashwan Lazkani\nUtvecklare\n\nMartin Ohls\nUX Designer\n\nOlof Stranne\nUtvecklare " as NSString
        
        let attrDict: [String : AnyObject] = [NSFontAttributeName:UIFont.systemFontOfSize(CGFloat(size)), NSForegroundColorAttributeName: UIColor.whiteColor()]

        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: attrDict)
        
        let smallerItalicFont = [NSFontAttributeName: UIFont.italicSystemFontOfSize(13)]
        
        attributedString.addAttributes(smallerItalicFont, range: string.rangeOfString("Utvecklare"))
        attributedString.addAttributes(smallerItalicFont, range: string.rangeOfString("UX Designer"))
        attributedString.addAttributes(smallerItalicFont, range: string.rangeOfString("Utvecklare "))
        
        return attributedString
    }
}