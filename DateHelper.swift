//
//  DateHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-11-28.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class DateHelper {
    enum SearchDirection {
        case next
        case previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .next:
                return .matchNextTime
            case .previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    static func get(_ direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> Date {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        // weekday is in form 1 ... 7 where as index is 0 ... 6
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1
        let today = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        if consider && (calendar as NSCalendar).component(.weekday, from: today) == nextWeekDayIndex {
            return today
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = (calendar as NSCalendar).nextDate(after: today, matching: nextDateComponent, options: direction.calendarOptions)
        return date!
    }
    
    static func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    static func getDayOfWeek(_ today:String)->Int {
        guard let todayDate = DateFormat.instance.date(from: String(describing: Date())) else { return 1}
        var myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        myCalendar.locale = Locale(identifier: "en_US_POSIX")
        let myComponents = (myCalendar as NSCalendar).components(.weekday, from: todayDate)
        let weekDay = myComponents.weekday
        return weekDay!
    }
}
