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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (locationService){
            updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("getLocationAndUpdateView"), userInfo: nil, repeats: true)
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
        
        var todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 0, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: [], row: Row.Info)
        linesAtStop.append(todayLabel)
        
        locationService = false
        updateTable()
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
            view.removeFromSuperview()
            /*
            if (toString(view.dynamicType) != "_UITableViewCellSeparatorView" && toString(view.dynamicType) != "UITableViewCellContentView") {
            }
            */
        }
        
        var maxRows = false
        
        var stopLabel = UILabel(frame: CGRectMake(8, 4, 330, 30))
        stopLabel.textAlignment = NSTextAlignment.Left
        stopLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        stopLabel.font = stopLabel.font.fontWithSize(14)
        
        var distanceLabel = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
        distanceLabel.textAlignment = NSTextAlignment.Left
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = distanceLabel.font.fontWithSize(12)
        
        var lblSnameDir = UILabel(frame: CGRect(x: 8, y: 4, width: getLabelWidth(), height: 30))
        lblSnameDir.textAlignment = NSTextAlignment.Left
        lblSnameDir.textColor = UIColor.whiteColor()
        lblSnameDir.font = lblSnameDir.font.fontWithSize(14)
        
        var depLabelOne = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
        depLabelOne.textColor = UIColor.whiteColor()
        depLabelOne.font = depLabelOne.font.fontWithSize(14)
        
        var depLabelTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 25, 4, 30, 30))
        depLabelTwo.textColor = UIColor.lightGrayColor()
        depLabelTwo.font = depLabelTwo.font.fontWithSize(14)
        
        var letterSname = linesAtStop[indexPath.row].sname.toInt()
        // Linje med bokstäver
        if (letterSname == nil){
            lblSnameDir.font = lblSnameDir.font.fontWithSize(14)
        }
        
        // Max antal linjer
        if (indexPath.row == iPhoneModelSize() - 1){
            
            stopLabel.text =  "Max antal linjer. Listar närmaste avgångar"
            stopLabel.frame = CGRectMake(8, 0, 330, 30)
            stopLabel.font = UIFont.italicSystemFontOfSize(12)
            stopLabel.textColor = UIColor.whiteColor()
            
            let btnMainApp = UIButton(frame: CGRectMake(10,30, cell.bounds.width - 40, 35))
            btnMainApp.backgroundColor = UIColor.clearColor()
            btnMainApp.setTitle("Lägg till ny hållplats", forState: UIControlState.Normal)
            btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
            btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
            btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            btnMainApp.layer.cornerRadius = 5
            
            
            cell.userInteractionEnabled = true
            cell.addSubview(stopLabel)
            cell.addSubview(btnMainApp)
            
            tableView.rowHeight = 45
            
            self.preferredContentSize = CGSizeMake(0, CGFloat(iPhoneModelSize() * 38));
            
            return cell
        }
        
        if (indexPath.row >= iPhoneModelSize()){
            let btnMainApp = UIButton(frame: CGRectMake(40,3, cell.bounds.width - 80, 30))
            btnMainApp.backgroundColor = UIColor.clearColor()
            btnMainApp.setTitle("Hantera stopp", forState: UIControlState.Normal)
            btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
            btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
            btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            btnMainApp.layer.cornerRadius = 5
            
            cell.userInteractionEnabled = true
            
            cell.addSubview(btnMainApp)
            
            return cell
        }
        // Inget stopp || Inget stopp i närheten
        if (linesAtStop[indexPath.row].row == Row.Info || linesAtStop[indexPath.row].row == Row.ButtonAddStop){
            
            for view in cell.subviews{
                view.removeFromSuperview()
            }
            
            if (linesAtStop[indexPath.row].row == Row.Info){
                stopLabel.text = linesAtStop[indexPath.row].stopName
                
                cell.userInteractionEnabled = false
                cell.addSubview(stopLabel)
            }
            else if (linesAtStop[indexPath.row].row == Row.ButtonAddStop){
                let btnMainApp = UIButton(frame: CGRectMake(10,0, cell.bounds.width - 40, 35))
                btnMainApp.backgroundColor = UIColor.clearColor()
                btnMainApp.setTitle("Lägg till ny hållplats", forState: UIControlState.Normal)
                btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
                btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
                btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
                btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
                btnMainApp.layer.cornerRadius = 5
                
                cell.userInteractionEnabled = true
                cell.addSubview(btnMainApp)
            }
        }
        // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].row == Row.Stop){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            distanceLabel.text = String(linesAtStop[indexPath.row].distance) + " m"
            
            cell.addSubview(stopLabel)
            cell.addSubview(distanceLabel)
            
            cell.userInteractionEnabled = false
            
            var separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
            
            cell.addSubview(separatorView)
        }
        //Inga avgångar hittades
        else if (linesAtStop[indexPath.row].row == Row.NoDepartures){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            
            stopLabel.font = UIFont.italicSystemFontOfSize(12)
            stopLabel.textColor = UIColor.whiteColor()
            
            cell.userInteractionEnabled = false
            cell.addSubview(stopLabel)
        }
        // Linje på hållplats
        else if (linesAtStop[indexPath.row].row == Row.Trip){
            lblSnameDir.text = linesAtStop[indexPath.row].sname
            lblSnameDir.text! += " " + linesAtStop[indexPath.row].direction
            
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
            
            var separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
            
            cell.addSubview(separatorView)
            cell.addSubview(lblSnameDir)
            cell.addSubview(depLabelOne)
            cell.addSubview(depLabelTwo)
            
            cell.userInteractionEnabled = false
        }
            //Sista raden
        else if (linesAtStop[indexPath.row].row == Row.Button){
            let btnMainApp = UIButton(frame: CGRectMake(40,13, cell.bounds.width - 80, 35))
            btnMainApp.backgroundColor = UIColor.clearColor()
            btnMainApp.setTitle("Hantera stopp", forState: UIControlState.Normal)
            btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
            btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
            btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            btnMainApp.layer.cornerRadius = 5
            
            cell.userInteractionEnabled = true
            
            cell.addSubview(btnMainApp)
            
            var separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
            
            tableView.rowHeight = 45
            
            return cell
            
            //cell.addSubview(separatorView)
        }
        
        self.preferredContentSize = CGSizeMake(0, CGFloat(linesAtStop.count * 36 + 20));
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (linesAtStop.count == 0){
            var view = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height));
            var distanceLabel = UILabel(frame: CGRectMake(0, 4, 200, 30))
            distanceLabel.textAlignment = NSTextAlignment.Left
            distanceLabel.textColor = UIColor.grayColor()
            distanceLabel.font = distanceLabel.font.fontWithSize(14)
            distanceLabel.text = "Laddar hållplatser..."
            
            view.addSubview(distanceLabel)
            
            return view
        }
        else{
            var table = UIView(frame: CGRectZero)
            tableView.tableFooterView = table
            table.hidden = true
            tableView.tableFooterView?.hidden = true
            self.tableView.backgroundColor = UIColor.clearColor()
            
            return table
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35.0
    }
    
    // MARK: - Events
    func openMainApp(sender: UIButton!) {
        println("Click")
        var url = NSURL(fileURLWithPath: "Tajma://home")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    
    // MARK: - Functions
    func getData(){
        var isStop = 0
        linesAtStop = [TodayLabel]()
        // För att sorteringen ska funka måste alla items i linesAtStop arrayen ha departures
        var tempArr = [-10, -10]
        
        // ta data och platta till den med sektioner så att den passar listan
        var stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.count == 0){
            var todayLabel = TodayLabel(stopName: "Ingen vald hållplats i närheten :(", distance: 0, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Info)
            linesAtStop.append(todayLabel)
            
            var todayButton = TodayLabel(stopName: "Lägg till ny hållplats", distance: 0, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.ButtonAddStop)
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
                var todayLabel = TodayLabel(stopName: stop.name, distance: stop.distance, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Stop)
                
                isStop++
                linesAtStop.append(todayLabel)
                
                if (stop.departures?.count == 0){
                    todayLabel = TodayLabel(stopName: "Inga avgångar hittades.", distance: stop.distance, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.NoDepartures)
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
                        
                        var trip = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: rtTimesArr, row: Row.Trip)
                        
                        linesAtStop.append(trip)
                    }
                    
                }
            }
            
            // Lägger till en rad i slutet för att alltid kunna visa en knapp för att returnera till appen
            var todayLabel = TodayLabel(stopName: "", distance: 1000001, sname: "", direction: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Button)
            linesAtStop.append(todayLabel)
            
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
            
            // Kollar om vi har fler än 1 stopp och fler än maxrader
            // Visar närmaste avgångar för alla

            linesAtStop = sortedList
            
            self.updateTable()
        }
    }
    
    func updateTable(){
        self.tableView.backgroundColor = UIColor.clearColor()
        self.updateSize()
        self.tableView.reloadData()
    }
    
    func updateSize(){
        var preferredSize = self.preferredContentSize
        preferredSize.height = self.preferedViewHeight
        self.preferredContentSize = preferredSize
    }
    
    func iPhoneModelSize() -> Int{
        switch UIDevice.currentDevice().modelName {
        case "iPhone 4", "iPhone 4S" :
            return 8
        case "iPhone 5", "iPhone 5C", "iPhone 5S" :
            return 10
        case "iPhone 6" :
            return 13
        case "iPhone 6 Plus" :
            return 16
        default:
            return 13
        }
    }
    
    func getLabelWidth() -> Int{
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}