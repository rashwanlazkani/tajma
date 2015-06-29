//
//  MiscService.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-06-29.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class DeviceService {
    static func iPhoneModelSize() -> Int{
        switch UIDevice.currentDevice().modelName {
        case "iPhone 4", "iPhone 4S" :
            return 8
        case "iPhone 5", "iPhone 5C", "iPhone 5S" :
            return 10
        case "iPhone 6" :
            return 13
        case "iPhone 6 Plus" :
            return 16
        default:
            return 13
        }
    }
    
    static func getLabelWidth() -> CGFloat{
        switch DeviceService.iPhoneModelSize() {
            // 5
        case 10 :
            return 280.0
            // 6
        case 13 :
            return 330.0
            // 6P
        case 16 :
            return 370.0
            // Simulator, iPad osv
        default:
            return 300
        }
    }
}