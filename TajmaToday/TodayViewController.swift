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

class TodayTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
            
            tableView.delegate = self
            tableView.dataSource = self
            
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linesAtStop.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var containerView = UIView()
        
        containerView.removeFromSuperview()
        
        var stopLabel = UILabel(frame: CGRectMake(0, 8, 330, 30))
        stopLabel.textAlignment = NSTextAlignment.Left
        stopLabel.textColor = UIColor.grayColor()
        stopLabel.font = stopLabel.font.fontWithSize(16)
        
        var distanceLabel = UILabel(frame: CGRectMake(tableView.bounds.width - 40, 8, 30, 30))
        distanceLabel.textAlignment = NSTextAlignment.Left
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = distanceLabel.font.fontWithSize(10)

        var directionLabel = UILabel(frame: CGRectMake(55, 8, 300, 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor.whiteColor()
        directionLabel.font = directionLabel.font.fontWithSize(12)
        
        var snameView = UIView()
        snameView.frame = CGRectMake(30, 30, 30, 30)
        snameView.layer.cornerRadius = 5
        snameView.center = CGPoint(x: 25, y: 23)
        snameView.backgroundColor = UIColor(rgba: linesAtStop[indexPath.row].fgColor)
        
        var snameLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        snameLabel.textAlignment = NSTextAlignment.Center
        snameLabel.textColor = UIColor(rgba: linesAtStop[indexPath.row].bgColor)
        snameLabel.font = snameLabel.font.fontWithSize(11)
        
        var depLabelOne = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 8, 30, 30))
        depLabelOne.textColor = UIColor.whiteColor()
        depLabelOne.font = depLabelOne.font.fontWithSize(12)
        
        var depLabelTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 30, 8, 30, 30))
        depLabelTwo.textColor = UIColor.lightGrayColor()
        depLabelTwo.font = depLabelTwo.font.fontWithSize(12)
        
        var sname = ""
        if (count(linesAtStop[indexPath.row].sname) > 3){
            let snameArr = Array(linesAtStop[indexPath.row].sname)
            sname = String(snameArr[0])
        }
        else{
            sname = linesAtStop[indexPath.row].sname
        }
        
        // Inget stopp || Inget stopp i närheten || Inga avgångar hittades
        if (linesAtStop[indexPath.row].isStop && linesAtStop[indexPath.row].distance == 99999){
            cell.textLabel!.textColor = UIColor.grayColor()
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.textLabel!.text = linesAtStop[indexPath.row].stopName
        }
        // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].isStop){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            distanceLabel.text = String(linesAtStop[indexPath.row].distance) + " m"
            
            containerView.addSubview(stopLabel)
            containerView.addSubview(distanceLabel)
        }
        // Linje på hållplats
        else{
            snameLabel.text = sname ?? linesAtStop[indexPath.row].sname
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
            
            containerView.addSubview(snameView)
            snameView.addSubview(snameLabel)
            containerView.addSubview(directionLabel)
            containerView.addSubview(depLabelOne)
            containerView.addSubview(depLabelTwo)
        }
        
        cell.addSubview(containerView)
        cell.userInteractionEnabled = false
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
            
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "",rtTimes: [], isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
            
            return
            
        }
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            var noStop = "Ingen hållplats i närheten."
            var todayLabel = TodayLabel(stopName: noStop, distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "",rtTimes: [], isStop: true)
            linesAtStop.append(todayLabel)
            
            updateTable()
        }
        else{
            for stop in stops{
                
                var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: "", direction: "", fgColor: "", bgColor: "",rtTimes: [], isStop: true)
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: [], isStop: true)
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
                    
                    var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: departureTimesArr, isStop: false)
                    
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
        
        var todayLabel = TodayLabel(stopName: "", distance: 99999, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: [], isStop: true)
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
