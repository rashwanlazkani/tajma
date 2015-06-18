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
    
    
    @IBOutlet weak var table: UITableView!
    
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
            //viewLoadingDataInput()
            
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
            //viewLoadingDataInput()
            
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
        if (linesAtStop.count > iPhoneModelSize()){
            return iPhoneModelSize()
        }
        else{
            return linesAtStop.count
        }
    }
    
    func iPhoneModelSize() -> Int{
        let modelName = UIDevice.currentDevice().modelName

        switch modelName {
            case "iPhone 4", "iPhone 4S" :
                return 9
            case "iPhone 5", "iPhone 5C", "iPhone 5S" :
                return 11
            case "iPhone 6" :
                return 14
            case "iPhone 6 Plus" :
                return 17
            default:
            return 20
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.userInteractionEnabled = false
        
        if (linesAtStop.count == 0){
            var tempLabel = UILabel(frame: CGRectMake(8, 4, 330, 30))
            tempLabel.textAlignment = NSTextAlignment.Left
            tempLabel.textColor = UIColor.grayColor()
            tempLabel.font = UIFont.boldSystemFontOfSize(16)
            
            tempLabel.text = "Laddar data..."
            cell.addSubview(tempLabel)

            return cell
        }
        
        for view in cell.subviews{
            if (toString(view.dynamicType) != "_UITableViewCellSeparatorView") {
                view.removeFromSuperview()
            }
        }

        var stopLabel = UILabel(frame: CGRectMake(8, 4, 330, 30))
        stopLabel.textAlignment = NSTextAlignment.Left
        stopLabel.textColor = UIColor.grayColor()
        stopLabel.font = UIFont.boldSystemFontOfSize(16)
        
        var distanceLabel = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
        distanceLabel.textAlignment = NSTextAlignment.Left
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = distanceLabel.font.fontWithSize(12)
        
        var directionWidth = 0
        
        switch iPhoneModelSize() {
            // 5
            case 11 :
                directionWidth = 160
            // 6
            case 14 :
                directionWidth = 210
            // 6P
            case 17 :
                directionWidth = 245
            // Simulator, iPad osv
            default:
                directionWidth = 250
        }

        
        var directionLabel = UILabel(frame:  CGRect(x: 52, y: 4, width: directionWidth, height: 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor.whiteColor()
        directionLabel.font = directionLabel.font.fontWithSize(14)
        
        var snameLabel = UILabel(frame: CGRectMake(8, 4, 40, 30))
        snameLabel.textAlignment = NSTextAlignment.Left
        snameLabel.textColor = UIColor.whiteColor()
        snameLabel.font = UIFont.boldSystemFontOfSize(14)
        
        var depLabelOne = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
        depLabelOne.textColor = UIColor.whiteColor()
        depLabelOne.font = depLabelOne.font.fontWithSize(14)
        
        var depLabelTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 25, 4, 30, 30))
        depLabelTwo.textColor = UIColor.lightGrayColor()
        depLabelTwo.font = depLabelTwo.font.fontWithSize(14)
        
        var letterSname = linesAtStop[indexPath.row].sname.toInt()
        // Linje med bokstäver
        if (letterSname == nil){
            snameLabel.font = UIFont.boldSystemFontOfSize(10)
        }
        
        if (indexPath.row >= iPhoneModelSize() - 1){
            stopLabel.text =  "Max antal linjer. Listar närmaste avgångar."
            
            stopLabel.font = stopLabel.font.fontWithSize(12)
            cell.addSubview(stopLabel)
            
            return cell
        }

        // Inget stopp || Inget stopp i närheten || Inga avgångar hittades
        if (linesAtStop[indexPath.row].isStop && linesAtStop[indexPath.row].distance == 99999){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            
            stopLabel.textColor = UIColor.whiteColor()
            stopLabel.font = stopLabel.font.fontWithSize(12)
            
            cell.addSubview(stopLabel)
        }
            // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].isStop){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            distanceLabel.text = String(linesAtStop[indexPath.row].distance) + " m"
            
            self.tableView.layoutMargins = UIEdgeInsetsZero
            
            cell.addSubview(stopLabel)
            cell.addSubview(distanceLabel)
            
            return cell
            
        }
            // Linje på hållplats
        else{
            snameLabel.text = linesAtStop[indexPath.row].sname
            var index = 0
            for rtTime in linesAtStop[indexPath.row].rtTimes{
                
                if (index == 0 && rtTime == 0){
                    depLabelOne.text = "Nu"
                }
                else if (index == 1 && rtTime == 0){
                    depLabelTwo.text = "Nu"
                }
                else if (index == 0){
                    if (rtTime < 0){
                        depLabelOne.text = "0"
                    }
                    else{
                        depLabelOne.text = String(rtTime)
                    }
                }
                else if (index == 1){
                    if (rtTime < 0){
                        depLabelTwo.text = "0"
                    }
                    else{
                        depLabelTwo.text = String(rtTime)
                    }
                }
                
                index++
                
            }
            
            directionLabel.text = linesAtStop[indexPath.row].direction
            
            cell.addSubview(snameLabel)
            cell.addSubview(directionLabel)
            cell.addSubview(depLabelOne)
            cell.addSubview(depLabelTwo)
            
        }
        
        tableView.rowHeight = 36
        
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
        
        println(lat)
        println(long)
        
        var userStops = dbService.getStops()
        
        linesAtStop = [TodayLabel]()
        
        var tempArr = [-10, -10]
        
        if (userStops.count == 0){
            var noStop = "Ingen hållplats har lagts till."
            
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
            
            return
            
        }
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            var noStop = "Ingen hållplats i närheten."
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
        }
        else{
            for stop in stops{
                
                var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
                    linesAtStop.append(todayLabel)
                    continue
                }
                
                for departure in stop.departures!{
                    
                    var departureTimesArr = [Int]()
                    
                    var index = 0
                    
                    departure.rtTimes.sort({$0 < $1})
                    
                    for rtTime in departure.rtTimes{
                        // Hämta endast två tider
                        if (index == 2){
                            continue
                        }
                        if rtTime == 0{
                            departureTimesArr.append(0)
                        }
                        else{
                            departureTimesArr.append(rtTime)
                        }
                        index++
                    }
                    
                    var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: departureTimesArr, isStop: false)
                    
                    linesAtStop.append(todayLabel)
                }
                
            }
            
            //linesAtStop.sort({ $0.distance < $1.distance ? $0.rtTimes[0] < $1.rtTimes[0] : $0.distance < $1.distance })
            
            let temp = linesAtStop.sorted {
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
            
            linesAtStop = temp

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
        // LADDAR DATA TEXT
        var todayLabel = TodayLabel(stopName: "Laddar data...", distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: [], isStop: true)
        linesAtStop.append(todayLabel)
        
        updateTable()
    }
    
    func userNeedToTurnOnLocalization(){
        linesAtStop = [TodayLabel]()
        
        var todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: [], isStop: true)
        linesAtStop.append(todayLabel)
        
        locationService = false
        
        updateTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
