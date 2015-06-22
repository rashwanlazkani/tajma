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
    var stops = [Stop]()
    let locationManager = CLLocationManager()
    var preferedViewHeight:CGFloat{
        var height = CGFloat(linesAtStop.count * 44)
        return height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()){
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
            updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("getLocationAndUpdateView"), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        updateDataTimer.invalidate()
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
        // Om mer än maxlängd
        if (linesAtStop.count > iPhoneModelSize()){
            return iPhoneModelSize()
        }
        else{
            return linesAtStop.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Rensa alla views
        for view in cell.subviews{
            if (toString(view.dynamicType) != "_UITableViewCellSeparatorView") {
                view.removeFromSuperview()
            }
        }
    
        var stopLabel = UILabel(frame: CGRectMake(8, 4, 330, 30))
        stopLabel.textAlignment = NSTextAlignment.Left
        stopLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        stopLabel.font = UIFont.boldSystemFontOfSize(12)
        
        var distanceLabel = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
        distanceLabel.textAlignment = NSTextAlignment.Left
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = distanceLabel.font.fontWithSize(12)
        
        var directionWidth = getDirectionWith()
        
        var directionLabel = UILabel(frame:  CGRect(x: 52, y: 4, width: directionWidth, height: 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor.whiteColor()
        directionLabel.font = directionLabel.font.fontWithSize(12)
        
        var snameLabel = UILabel(frame: CGRectMake(8, 4, 40, 30))
        snameLabel.textAlignment = NSTextAlignment.Left
        snameLabel.textColor = UIColor.whiteColor()
        snameLabel.font = UIFont.boldSystemFontOfSize(12)
        
        var depLabelOne = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
        depLabelOne.textColor = UIColor.whiteColor()
        depLabelOne.font = depLabelOne.font.fontWithSize(12)
        
        var depLabelTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 25, 4, 30, 30))
        depLabelTwo.textColor = UIColor.lightGrayColor()
        depLabelTwo.font = depLabelTwo.font.fontWithSize(12)
        
        var letterSname = linesAtStop[indexPath.row].sname.toInt()
        // Linje med bokstäver
        if (letterSname == nil){
            snameLabel.font = UIFont.boldSystemFontOfSize(12)
        }
        
        // Max antal linjer
        if (indexPath.row >= iPhoneModelSize() - 1){
            stopLabel.text =  "Max antal linjer. Listar närmaste avgångar."
            
            stopLabel.font = stopLabel.font.fontWithSize(12)
            cell.addSubview(stopLabel)
            
            cell.userInteractionEnabled = false
            
            return cell
        }
        
        // Inget stopp || Inget stopp i närheten || Inga avgångar hittades
        if (linesAtStop[indexPath.row].isStop && linesAtStop[indexPath.row].distance == 99999) || (linesAtStop[indexPath.row].distance == 12345678){
            
            for view in cell.subviews{
                view.removeFromSuperview()
            }
            
            if (linesAtStop[indexPath.row].distance == 99999){
                stopLabel.text = linesAtStop[indexPath.row].stopName
                
                cell.userInteractionEnabled = true
                cell.addSubview(stopLabel)
            }
            else if (linesAtStop[indexPath.row].distance == 12345678){
                let btnMainApp = UIButton(frame: CGRectMake(10,0, cell.bounds.width - 40, 35))
                btnMainApp.backgroundColor = UIColor.clearColor()
                btnMainApp.setTitle("Lägg till ny hållplats", forState: UIControlState.Normal)
                btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
                btnMainApp.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
                btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
                btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
                btnMainApp.layer.cornerRadius = 5
                
                cell.userInteractionEnabled = true
                cell.addSubview(btnMainApp)
            }
            
            return cell
        }
            // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].isStop){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            distanceLabel.text = String(linesAtStop[indexPath.row].distance) + " m"
  
            cell.addSubview(stopLabel)
            cell.addSubview(distanceLabel)
            cell.userInteractionEnabled = false
            
            return cell
            
        }
        // Sista raden
        else if (indexPath.row == linesAtStop.count - 1){
            
            let btnMainApp = UIButton(frame: CGRectMake(cell.bounds.width / 5,3, 200, 30))
            btnMainApp.backgroundColor = UIColor.clearColor()
            btnMainApp.setTitle("Hantera stopp", forState: UIControlState.Normal)
            btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
            btnMainApp.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
            btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
            btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            btnMainApp.layer.cornerRadius = 5
            
            cell.userInteractionEnabled = true
            
            cell.addSubview(btnMainApp)
        }
            // Linje på hållplats
        else{
            
            cell.userInteractionEnabled = false
            
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
    
    // MARK: - Events
    func openMainApp(sender: UIButton!) {
        var url = NSURL(fileURLWithPath: "Tajma://home")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    
    // MARK: - Functions
    func updateSize(){
        var preferredSize = self.preferredContentSize
        preferredSize.height = self.preferedViewHeight
        self.preferredContentSize = preferredSize
    }
    
    func iPhoneModelSize() -> Int{
        let modelName = UIDevice.currentDevice().modelName

        switch modelName {
            case "iPhone 4", "iPhone 4S" :
                return 8
            case "iPhone 5", "iPhone 5C", "iPhone 5S" :
                return 10
            case "iPhone 6" :
                return 13
            case "iPhone 6 Plus" :
                return 16
            default:
            return 20
        }
    }
    
    func getDirectionWith() -> Int{
        switch iPhoneModelSize() {
            // 5
        case 10 :
            return 160
            // 6
        case 13 :
            return 210
            // 6P
        case 15 :
            return 245
            // Simulator, iPad osv
        default:
            return 250
        }
    }
    
    func getLocationAndUpdateView(){
        timerUpdate = true
        locationManager.startUpdatingLocation()
    }
    
    func getDeparturesAtStop(){
        var userStops = dbService.getStops()
        
        linesAtStop = [TodayLabel]()
        // För att sorteringen ska funka måste alla items i linesAtStop arrayen ha departures
        var tempArr = [-10, -10]
        
//        if (userStops.count == 0){
//            var noStop = "Ingen hållplats har lagts till. Öppna närmaste."
//            
//            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
//            linesAtStop.append(todayLabel)
//            
//            updateTable()
//            
//            return
//            
//        }
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (userStops.count == 0 || stops.count == 0){
            var noStop = "Ingen vald hållplats i närheten :("
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
            
            linesAtStop.append(todayLabel)
            
            var todayButton = TodayLabel(stopName: noStop, distance: 12345678, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: true)
            
            linesAtStop.append(todayButton)
            
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
            
            // Lägger till en rad i slutet för att alltid kunna visa en knapp för att returnera till appen
            var todayLabel = TodayLabel(stopName: "", distance: 10101010, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, isStop: false)
            linesAtStop.append(todayLabel)
            
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