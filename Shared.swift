//
//  SharedHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-11-14.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class Shared {
    func getSharedUrl() -> String {
        setSharedFolders()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tajma.today")!
        let urlSubString = url.absoluteString.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        return "\(urlSubString)db.sqlite"
    }
    
    func setSharedFolders() {
        // Hämta Shared URL
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tajma.today")!
        var urlSubString = url.absoluteString.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        // skapa en file manager för att hanera filerna
        let fileManager = FileManager.default
        let databuffer = fileManager.contents(atPath: urlSubString)
        
        // Kolla om databas filen finns
        if !fileManager.fileExists(atPath: urlSubString + "db.sqlite") {
            // Skapa fil
            urlSubString = urlSubString + "db.sqlite"
            fileManager.createFile(atPath: urlSubString, contents: databuffer,
                attributes: nil)
        }
    }
}
