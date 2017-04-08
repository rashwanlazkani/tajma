//
//  Extensions.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-09-05.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import ImageIO
import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension Data {
    var string: String {
        return String(data: self, encoding: String.Encoding.utf8) ?? ""
    }
    var json: (dictionary: [String: AnyObject]?, array: [AnyObject]?) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
            return (jsonObject as? [String: AnyObject], jsonObject as? [AnyObject])
        } catch let error as NSError {
            print("JSONSerialization error")
            print("error.code = ",error.code)
            print("error.domain = ",error.domain)
            return (nil,nil)
        }
    }
}

extension Array {
    func firstOrDefault(_ fn: (Element) -> Bool) -> Element? {
        var to = self.filter(fn)
        if to.count > 0 {
            return to[0]
        } else {
            return nil
        }
    }
}

extension Array where Element: Equatable {
    var orderedSetValue: Array  {
        return reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension Date {
    struct Formatter {
        static let custom: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter
        }()
        
        static let customDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        static let customTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    var dateTime: String {
        return Formatter.custom.string(from: self)
    }
    var customTime: String {
        return Formatter.customTime.string(from: self)
    }
    
    var customDate: String {
        return Formatter.customDate.string(from: self)
    }
}

extension String {
    var date: Date? {
        return Date.Formatter.custom.date(from: self)
    }
    
    var customizeStopID: String {
        var id = self
        id = (id as NSString).replacingCharacters(in: NSRange(location: 3, length: 1), with: "1")
        id = (id as NSString).replacingCharacters(in: NSRange(location: id.characters.count - 2, length: 2), with: "00")
        return id
    }
    
    var subStringSnameAndDirection: String{
        var lineAndDirection = self
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "Buss", with: "")
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "Spårvagn", with: "")
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "SVAR", with: "SVART")
        return lineAndDirection
    }
}

extension UIScreen {
    class var width: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
}
