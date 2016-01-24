//
//  DeviceHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-06-29.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class DeviceHelper {
    private let screenSize: CGRect = UIScreen.mainScreen().bounds
    var screenHeight: Int {
        get {
            return Int(screenSize.height)
        }
    }
    var screenWidth: Int {
        get {
            return Int(screenSize.width)
        }
    }
    
    static func iPhoneModelSize() -> Int{
        switch UIDevice.currentDevice().modelName {
        case "iPhone 4", "iPhone 4S" :
            return 8
        case "iPhone 5", "iPhone 5C", "iPhone 5S" :
            return 10
        case "iPhone 6, iPhone 6s" :
            return 13
        case "iPhone 6 Plus, iPhone 6s Plus" :
            return 16
        default:
            return 8
        }
    }
    
    static func getLabelWidth() -> CGFloat{
        switch DeviceHelper.iPhoneModelSize() {
            // 4, 4s
        case 8 :
            return 270.0
            // 5, 5s
        case 10 :
            return 270.0
            // 6, 6s
        case 13 :
            return 320.0
            // 6P, 6sP
        case 16 :
            return 360.0
            // Simulator, iPad osv
        default:
            return 290
        }
    }
    
    static func showGuideY() -> CGFloat{
        switch UIScreen.mainScreen().bounds.height {
            // 4, 4s
        case 480 :
            return 100
            // 5, 5s
        case 568 :
            return 120
            // 6, 6s
        case 667 :
            return 150
            // 6P, 6sP
        case 736 :
            return 150
            // Simulator, iPad osv
        default:
            return 290
        }
    }

    static func gifY() -> CGFloat{
        switch UIScreen.mainScreen().bounds.height {
            // 4, 4s
        case 480 :
            return 100.0
            // 5, 5s
        case 568 :
            return 125.0
            // 6, 6s
        case 667 :
            return 125.0
            // 6P, 6sP
        case 736 :
            return 125.0
            // Simulator, iPad osv
        default:
            return 290
        }
    }
    
    static func gifHeight() -> CGFloat{
        switch UIScreen.mainScreen().bounds.height {
        // 4, 4s
        case 480 :
            return 300.0
        // 5, 5s
        case 568 :
            return 350.0
        // 6, 6s
        case 667 :
            return 450.0
        // 6P, 6sP
        case 736 :
            return 500.0
        // Simulator, iPad osv
        default:
            return 290
        }
    }
    
    static func isFourOrFive() -> Bool{
        if (iPhoneModelSize() == 8) || (iPhoneModelSize() == 10){
            return true
        }
        else{
            return false
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "i386", "x86_64":                          return "Simulator"
            default:                                        return identifier
        }
    }
}