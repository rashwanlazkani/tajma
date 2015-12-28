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
        case Next
        case Previous
        
        var calendarOptions: NSCalendarOptions {
            switch self {
            case .Next:
                return .MatchNextTime
            case .Previous:
                return [.SearchBackwards, .MatchNextTime]
            }
        }
    }
    
    static func get(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        // weekday is in form 1 ... 7 where as index is 0 ... 6
        let nextWeekDayIndex = weekdaysName.indexOf(dayName)! + 1
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        if consider && calendar.component(.Weekday, fromDate: today) == nextWeekDayIndex {
            return today
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDateAfterDate(today, matchingComponents: nextDateComponent, options: direction.calendarOptions)
        return date!
    }
    
    static func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    static func getDayOfWeek(today:String)->Int {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        myCalendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    }
}