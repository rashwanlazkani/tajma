//
//  StringHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-11-27.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class StringHelper {
    static func customizeStopID(_ id: String) -> String {
        var id = id
        id = (id as NSString).replacingCharacters(in: NSRange(location: 3, length: 1), with: "1")
        id = (id as NSString).replacingCharacters(in: NSRange(location: id.characters.count - 2, length: 2), with: "00")
        return id
    }
    
    static func subStringSnameAndDirection(_ lineAndDirection: String) -> String{
        var lineAndDirection = lineAndDirection
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "Buss", with: "")
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "Spårvagn", with: "")
        lineAndDirection = lineAndDirection.replacingOccurrences(of: "SVAR", with: "SVART")
        return lineAndDirection
    }
}
