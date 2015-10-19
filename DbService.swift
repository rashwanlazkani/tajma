//
//  File.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-19.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

class DbService {
    static func setSharedURL(){
        
        print(Realm.Configuration.defaultConfiguration.path!)
        
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        let realmPath = directory.URLByAppendingPathComponent("default.realm")
        
        let urlSubString = realmPath.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        Realm.Configuration.defaultConfiguration.path = urlSubString
        
        print(Realm.Configuration.defaultConfiguration.path!)

    }
}