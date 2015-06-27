//
//  InterfaceController.swift
//  Tajma WatchKit Extension
//
//  Created by Rashwan Lazkani on 2015-06-27.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    @IBOutlet weak var table: WKInterfaceTable!
    var dbService = DBService()
    var linesAtStop = [TodayLabel]()
    var updateDataTimer = NSTimer()
    var lat  = ""
    var long = ""
    var departureService = DepartureService()
    var locationService = false
    let locationManager = CLLocationManager()
    var timerUpdate = false
    var firstRun = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()){
            if CLLocationManager.authorizationStatus() == .Denied {
                locationOff()
                return
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            locationService = true
        }
        else{
            locationOff()
        }
        
        if (locationService){
            updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("getLocationAndUpdateView"), userInfo: nil, repeats: true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        
        updateDataTimer.invalidate()
        
        super.didDeactivate()
    }
    
    // MARK: - Location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                println("Error: " + error.localizedDescription)
                return
            }
            if (placemarks.count > 0){
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }
            else{
                println("Error with location data")
            }
        })
    }
    
    func displayLocationInfo (placemark : CLPlacemark){
        // Vi har en location, behöver inte titta mer
        self.locationManager.stopUpdatingLocation()
        lat = String(stringInterpolationSegment: placemark.location.coordinate.latitude)
        long = String(stringInterpolationSegment: placemark.location.coordinate.longitude)
        
        if (firstRun || timerUpdate){
            getData()
            
            firstRun = false
            timerUpdate = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    func getLocationAndUpdateView(){
        timerUpdate = true
        locationManager.startUpdatingLocation()
    }
    
    func locationOff(){
        linesAtStop = [TodayLabel]()
        
        var todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: [], row: Row.Info)
        linesAtStop.append(todayLabel)
        
        locationService = false
        updateTable()
    }
    
    func getData(){
        var isStop = 0
        linesAtStop = [TodayLabel]()
        // För att sorteringen ska funka måste alla items i linesAtStop arrayen ha departures
        var tempArr = [-10, -10]
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            var todayLabel = TodayLabel(stopName: "Ingen vald hållplats i närheten :(", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Info)
            linesAtStop.append(todayLabel)
            
            var todayButton = TodayLabel(stopName: "Lägg till ny hållplats", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.ButtonAddStop)
            linesAtStop.append(todayButton)
            
            updateTable()
        }
        else{
            // Koden nedan loopar igenom alla stopp
            // Alla stopp lagras i linesAtStop arrayen
            // linesAtStop sorteras sedan efter distans > rtTimes
            // "Inga avgångar hittades" har en fiktiv distans på 1000000 för att hamna under hållplatsen
            // Sista raden har också en fiktiv distans på 1000001 för att hamna sist för att göra plats för "Gå till appen" knappen
            for stop in stops{
                var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Stop)
                
                isStop++
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: stop.distance, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.NoDepartures)
                    linesAtStop.append(todayLabel)
                }
                else{
                    // Loopa igenom linjer på hållplatsen
                    for departure in stop.departures!{
                        var rtTimesArr = [Int]()
                        var index = 0
                        departure.rtTimes.sort({$0 < $1})
                        
                        for rtTime in departure.rtTimes{
                            // Hämta endast två tider
                            if (index == 2){
                                continue
                            }
                            if rtTime == 0{
                                rtTimesArr.append(0)
                            }
                            else{
                                rtTimesArr.append(rtTime)
                            }
                            index++
                        }
                        
                        var trip = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, snameAndDirection: departure.sname + " " + departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: rtTimesArr, row: Row.Trip)
                        
                        linesAtStop.append(trip)
                    }
                    
                }
            }
            
            
            let sortedList = linesAtStop.sorted {
                switch ($0.distance,$1.distance) {
                    // if neither “category" is nil and contents are equal,
                case let (lhs,rhs) where lhs == rhs:
                    // compare “status” (> because DESC order)
                    return $0.rtTimes[0] < $1.rtTimes[0]
                    // else just compare “category” using <
                case let (lhs, rhs):
                    return lhs < rhs
                }
            }
            
            linesAtStop = sortedList
            
            var temp = [TodayLabel]()
            if (linesAtStop.count > watchSize()){
                var index = 0
                var arr = [String]()
                
                var temp = [TodayLabel]()
                
                for stop in linesAtStop{
                    // Om sista raden endast är en hållplats så vill vi inte visa denna
                    if (index >= watchSize() && stop.snameAndDirection == ""){
                        break
                    }
                    if (stop.snameAndDirection == ""){
                        stop.snameAndDirection += String(index)
                    }
                    if (!contains(arr, stop.snameAndDirection)){
                        temp.append(stop)
                        arr.append(stop.snameAndDirection)
                    }
                    
                    index++
                }
                
                linesAtStop = temp
            }
            
            // VISA EJ ENDAST HÅLLPLATSNAMNET
            // Kollar om vi har fler än 1 stopp och fler än maxrader
            // Visar närmaste avgångar för alla
            
            //linesAtStop = sortedList
            
            self.updateTable()
        }
    }
    
    func watchSize() -> Int{
        switch UIDevice.currentDevice().modelName {
        case "38" :
            return 100
        case "42" :
            return 100
        default:
            return 100
        }
    }
    
    func updateTable(){
        println(UIDevice.currentDevice().name)
        table.setNumberOfRows(linesAtStop.count, withRowType: "Row")
        
        for (index, stop) in enumerate(linesAtStop){
            let row = table.rowControllerAtIndex(index) as! DataRowController
            
            var text = ""
            if (stop.row == Row.Stop){
                // 22
                var strLength = count(stop.stopName)
                if (strLength > 26){
                    var x = stop.stopName.subStringTo(24)
                    text = "\(x) \n Avstånd \(String(stop.distance))m"
                    
                    println(x)
                }
                else{
                    
                }
                
                
                let font = UIFont(name: "Arial", size: 8.0)
                
                text = "\(stop.stopName) \n Avstånd \(String(stop.distance))m"
                
                let attrString = NSAttributedString(
                    string: text,
                    attributes: NSDictionary(
                        object: font!,
                        forKey: NSFontAttributeName) as [NSObject : AnyObject])
                
                row.label.setTextColor(UIColor.greenColor())
                
                row.label.setAttributedText(attrString)
            }
            else{
                
                var tempText = ""
                var index = 0
                for rtTime in stop.rtTimes{
                    
                    if (index == 0 && rtTime == 0){
                        tempText = "Nu"
                    }
                    else if (index == 1 && rtTime == 0){
                        tempText += ", Nu"
                    }
                    else if (index == 0){
                        if (rtTime < 0){
                            tempText = "0"
                        }
                        else{
                            tempText += String(rtTime)
                        }
                    }
                    else if (index == 1){
                        if (rtTime < 0){
                            tempText += ", 0"
                        }
                        else{
                            tempText += ", " + String(rtTime)
                        }
                    }
                    
                    index++
                    
                }
                
                var x = ""
                if (count(stop.snameAndDirection) >= 35){
                    x = stop.snameAndDirection.subStringTo(26) + "..."
                }
                else{
                    x = stop.snameAndDirection
                }
                
                
                text = "\(x) \n Avgång: \(tempText)"
                let font = UIFont(name: "Arial", size: 8.0)
                
                let attrString = NSAttributedString(
                    string: text,
                    attributes: NSDictionary(
                        object: font!,
                        forKey: NSFontAttributeName) as [NSObject : AnyObject])
                
                row.label.setAttributedText(attrString)
            }
            
        }

    }

}
