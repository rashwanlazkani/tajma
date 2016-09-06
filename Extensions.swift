//
//  Extensions.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-09-05.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

extension Array {
    func firstOrDefault(fn: (Element) -> Bool) -> Element? {
        var to = self.filter(fn)
        if(to.count > 0){
            return to[0]
        } else{
            return nil
        }
    }
}

extension Array where Element: Equatable {
    var orderedSetValue: Array  {
        return reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
}