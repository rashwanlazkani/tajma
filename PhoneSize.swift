//
//  PhoneSize.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-07.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class PhoneSize {
    
    private let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var height: Int {
        get {
            return Int(screenSize.height)
        }
    }
    
    var width: Int {
        get {
            return Int(screenSize.width)
        }
    }
}