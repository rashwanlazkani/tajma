//
//  TodayViewController.swift
//  TajmaToday
//
//  Created by Rashwan Lazkani on 2015-06-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, NCWidgetProviding, CLLocationManagerDelegate {
    
    var lat  = ""
    var long = ""
    
    var dbService = DBService()
    var departureService = DepartureService()
    var lineService = LineService()
    var linesAtStop = [TodayLabel]()
    
    var departures = [Departure]()
    
    var updateDataTimer = NSTimer()
    
    var timerUpdate = false
    var firstRun = true
    var locationService = false
    
    var preferedViewHeight:CGFloat{
        var height = CGFloat(linesAtStop.count * 44)
        return height
    }
    
    var stops = [Stop]()
    
    //var stops = [String]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()){
            viewLoadingDataInput()
            
            if CLLocationManager.authorizationStatus() == .Denied {
                userNeedToTurnOnLocalization()
                
                return
            }
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            locationService = true
        }
        else{
            userNeedToTurnOnLocalization()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (locationService){
            viewLoadingDataInput()
            
            updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("getLocationAndUpdateView"), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        updateDataTimer.invalidate()
    }
    
    func updateSize(){
        var preferredSize = self.preferredContentSize
        preferredSize.height = self.preferedViewHeight
        self.preferredContentSize = preferredSize
    }
    
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
            getDeparturesAtStop()
            
            firstRun = false
            timerUpdate = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    
    // MARK: - Widget Delegate
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.tableView.reloadData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linesAtStop.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Inget stopp || Inget stopp i närheten || Inga avgångar hittades
        if (linesAtStop[indexPath.row].isStop && linesAtStop[indexPath.row].distance == 99999){
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = linesAtStop[indexPath.row].stopName
            cell.userInteractionEnabled = false
            cell.textLabel?.font = UIFont.systemFontOfSize(12)
        }
            // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].isStop){
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = linesAtStop[indexPath.row].stopName + " " + String(linesAtStop[indexPath.row].distance) + " meter"
            cell.userInteractionEnabled = false
            //cell.textLabel?.font = UIFont.systemFontOfSize(17)
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        }
            // Linje på hållplats
        else{
            var departureText = ""
            var index = 0
            for rtTime in linesAtStop[indexPath.row].rtTimes{
                if (index != 0){
                    departureText += ", "
                }
                if rtTime == 0{
                    departureText += "Nu"
                }
                else{
                    departureText += String(rtTime)
                }
                index++
                
            }
            
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = linesAtStop[indexPath.row].sname + " " + linesAtStop[indexPath.row].direction + " " + departureText
            cell.userInteractionEnabled = false
            cell.textLabel?.font = UIFont.systemFontOfSize(12)
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    func getLocationAndUpdateView(){
        timerUpdate = true
        locationManager.startUpdatingLocation()
    }
    
    func getDeparturesAtStop(){
        
        var userStops = dbService.getStops()
        
        linesAtStop = [TodayLabel]()
        
        if (userStops.count == 0){
            var noStop = "Ingen hållplats har lagts till."
            
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", rtTimes: [], isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
            
            return
            
        }
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            var noStop = "Ingen hållplats i närheten."
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", rtTimes: [], isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
        }
        else{
            for stop in stops{
                
                var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: "", direction: "", rtTimes: [], isStop: true)
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: 99999, sname: "", direction: "", rtTimes: [], isStop: true)
                    linesAtStop.append(todayLabel)
                    continue
                }
                
                for departure in stop.departures!{
                    
                    var departureTimesArr = [Int]()
                    
                    var departureText = departure.sname + " " + departure.direction + " "
                    var index = 0
                    
                    departure.rtTimes.sort({$0 < $1})
                    
                    for rtTime in departure.rtTimes{
                        // Hämta endast två tider
                        if (index == 2){
                            continue
                        }
                        if (index != 0){
                            departureText += ", "
                        }
                        
                        if rtTime == 0{
                            departureTimesArr.append(0)
                            departureText += "Nu"
                        }
                        else{
                            departureTimesArr.append(rtTime)
                            departureText += String(rtTime)
                        }
                        index++
                    }
                    
                    var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, rtTimes: departureTimesArr, isStop: false)
                    
                    linesAtStop.append(todayLabel)
                }
                
            }
            
            self.updateTable()
        }
    }
    
    func updateTable(){
        self.tableView.backgroundColor = UIColor.clearColor()
        self.updateSize()
        self.tableView.reloadData()
    }
    
    func viewLoadingDataInput(){
        linesAtStop = [TodayLabel]()
        
        var todayLabel = TodayLabel(stopName: "Laddar data...", distance: 99999, sname: "", direction: "", rtTimes: [], isStop: true)
        linesAtStop.append(todayLabel)
        
        updateTable()
    }
    
    func userNeedToTurnOnLocalization(){
        linesAtStop = [TodayLabel]()
        
        var todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 99999, sname: "", direction: "", rtTimes: [], isStop: true)
        linesAtStop.append(todayLabel)
        
        locationService = false
        
        updateTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
