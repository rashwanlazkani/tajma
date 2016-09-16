//
//  SharedHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-11-14.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class SharedHelper {
    func getSharedUrl() -> String{
        setSharedFolders()
        let url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        let urlSubString = url.absoluteString!.stringByReplacingOccurrencesOfString("file:///", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return "\(urlSubString)db.sqlite"
    }
    
    func setSharedFolders(){
        // Hämta Shared URL
        let url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        var urlSubString = url.absoluteString!.stringByReplacingOccurrencesOfString("file:///", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // skapa en file manager för att hanera filerna
        let filemgr = NSFileManager.defaultManager()
        let databuffer = filemgr.contentsAtPath(urlSubString)
        
        // Kolla om databas filen finns
        if !filemgr.fileExistsAtPath(urlSubString + "db.sqlite") {
            // Skapa fil
            urlSubString = urlSubString + "db.sqlite"
            filemgr.createFileAtPath(urlSubString, contents: databuffer,
                attributes: nil)
        }
    }
}
