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
        let title = UILabel(frame: CGRect(x: 0, y: 7, width: 200, height: 30))
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor.white
        title.font = title.font.withSize(19)
        title.text = "Om oss"
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = titleView
        titleView.addSubview(title)
        
        txtField.attributedText = attributedText()
    }
    
    func attributedText()->NSAttributedString{
        var size = 0.0
        if UIScreen.main.bounds.height == 480{
            size = 15.0
        } else {
            size = 16.0
        }
        let string = "Vi har som mål med Tajma att förenkla vardagen för dig och dina vänner. Vi arbetar kontinuerligt med uppdateringar av appen. I nuläget fungerar Tajma för Västtrafiks linjer men vi jobbar på att inkludera Skånetrafiken och Storstockholms Lokaltrafik. Om du har några frågor till Tajma-teamet, maila oss gärna på tajma@lazkani.se.\n\nTack för att du använder Tajma!\n\nVänliga hälsningar,\n\nRashwan Lazkani\nUtvecklare\n\nMartin Ohls\nUX Designer\n\nOlof Stranne\nUtvecklare " as NSString
        
        let attrDict: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(size)), NSAttributedString.Key.foregroundColor: UIColor.white]

        let attributedString = NSMutableAttributedString(string: string as String, attributes: attrDict)
        let smallerItalicFont = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 13)]
        
        attributedString.addAttributes(smallerItalicFont, range: string.range(of: "Utvecklare"))
        attributedString.addAttributes(smallerItalicFont, range: string.range(of: "UX Designer"))
        attributedString.addAttributes(smallerItalicFont, range: string.range(of: "Utvecklare "))
        
        return attributedString
    }
}
