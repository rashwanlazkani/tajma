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
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                print("Error: " + error.localizedDescription)
                return
            }
            if (placemarks.count > 0){
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }
            else{
                print("Error with location data")
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func getLocationAndUpdateView(){
        timerUpdate = true
        locationManager.startUpdatingLocation()
    }
    
    func locationOff(){
        linesAtStop = [TodayLabel]()
        
        let todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: [], row: Row.Info)
        linesAtStop.append(todayLabel)
        
        locationService = false
        updateTable()
    }
    
    func getData(){
        linesAtStop = [TodayLabel]()
        // För att sorteringen ska funka måste alla items i linesAtStop arrayen ha departures
        let tempArr = [-10, -10]
        
        // ta data och platta till den med sektioner så att den passar listan
        let stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            let todayLabel = TodayLabel(stopName: "Ingen vald hållplats i närheten :(", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Info)
            linesAtStop.append(todayLabel)
            
            let todayButton = TodayLabel(stopName: "Lägg till ny hållplats", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Button)
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
                
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: stop.distance, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.NoDepartures)
                    linesAtStop.append(todayLabel)
                }
                else{
                    // Loopa igenom linjer på hållplatsen
                    for departure in stop.departures!{
                        var rtTimesArr = [Int]()
                        departure.rtTimes.sortInPlace({$0 < $1})
                        for (index, rtTime) in departure.rtTimes.enumerate(){
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
                        }
                        
                        let trip = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, snameAndDirection: departure.sname + " " + departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: rtTimesArr, row: Row.Line)
                        
                        linesAtStop.append(trip)
                    }
                    
                }
            }
            
            // Tom rad för att visa Tajma namnet i början
            let heading = TodayLabel(stopName: "Tajma", distance: -1000, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Stop)
            
            linesAtStop.append(heading)
            
            
            let sortedList = linesAtStop.sort {
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
                var arr = [String]()
                
                var temp = [TodayLabel]()
                
                for (index, stop) in linesAtStop.enumerate(){
                    // Om sista raden endast är en hållplats så vill vi inte visa denna
                    if (index >= watchSize() && stop.snameAndDirection == ""){
                        break
                    }
                    if (stop.snameAndDirection == ""){
                        stop.snameAndDirection += String(index)
                    }
                    if (!arr.contains(stop.snameAndDirection)){
                        temp.append(stop)
                        arr.append(stop.snameAndDirection)
                    }
                }
                
                linesAtStop = temp
            }
            
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
        table.setNumberOfRows(linesAtStop.count, withRowType: "Row")
        
        for (index, stop) in linesAtStop.enumerate(){
            let row = table.rowControllerAtIndex(index) as! DataRowController
            row.group.setBackgroundColor(UIColor.clearColor())
            
            var text = ""
            var font = UIFont()
            
            // Tajma rubrik
            if (stop.distance == -1000){
                row.group.setHeight(30.0)
                row.label.setHeight(30.0)
                font = UIFont(name: "Arial", size: 12.0)!
                
                text = "\(stop.stopName)"
                
                let attrString = NSAttributedString(
                    string: text,
                    attributes: NSDictionary(
                        object: font,
                        forKey: NSFontAttributeName) as [NSObject : AnyObject])
                
                row.label.setTextColor(UIColor.redColor())
                row.label.setAttributedText(attrString)
            }
            // Hållplats
            else if (stop.row == Row.Stop){
                row.group.setHeight(30.0)
                row.label.setHeight(30.0)
            
                font = UIFont(name: "Arial", size: 10.0)!
                var strLength = stop.stopName.characters.count
                
                if (strLength > 26){
                    var stopname = stop.stopName.subStringTo(24)
                    text = "\(stopname) \n\(String(stop.distance))m"
                }
                
                text = "\(stop.stopName) \n\(String(stop.distance))m"
                
                let attrString = NSAttributedString(
                    string: text,
                    attributes: NSDictionary(
                        object: font,
                        forKey: NSFontAttributeName) as [NSObject : AnyObject])
                
                row.label.setTextColor(UIColor.grayColor())
                row.label.setAttributedText(attrString)
            }
            // Avgångar
            else{
                var tempText = ""
                for (index, rtTime) in stop.rtTimes.enumerate(){
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
                }
                
                var snameAndDirection = ""
                if (stop.snameAndDirection.characters.count >= 26){
                    snameAndDirection = stop.snameAndDirection.subStringTo(24) + "..."
                }
                else{
                    snameAndDirection = stop.snameAndDirection
                }
                
                text = "\(snameAndDirection) \n\(tempText)"
                let font = UIFont(name: "Arial", size: 8.0)
                
                let attrString = NSAttributedString(
                    string: text,
                    attributes: NSDictionary(
                        object: font!,
                        forKey: NSFontAttributeName) as [NSObject : AnyObject])
                
                row.label.setAttributedText(attrString)
                row.group.setHeight(30.0)
            }
            
        }

    }

}
