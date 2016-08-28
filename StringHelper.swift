//
//  StringHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-11-27.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class StringHelper {
    static func customVtStopId(id: String) -> String {
        var i = id
        i = (i as NSString).stringByReplacingCharactersInRange(NSRange(location: 3, length: 1), withString: "1")
        i = (i as NSString).stringByReplacingCharactersInRange(NSRange(location: id.characters.count - 2, length: 2), withString: "00")
        return i
    }
}