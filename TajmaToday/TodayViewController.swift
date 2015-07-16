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
    
    // Behövs då en bugg finns att denna inte alltid öppnas
    // http://stackoverflow.com/questions/24128024/today-extension-has-a-title-but-no-body-ios-8
    override func awakeFromNib() {
        self.preferredContentSize = CGSize(width: 50, height: 20)
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
        
        println(DeviceService.iPhoneModelSize())
        
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
        
        var todayLabel = TodayLabel(stopName: "Du måste slå på lokaliseringen för TajmApp.", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: [], row: Row.Info)
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
        if (linesAtStop.count > DeviceService.iPhoneModelSize()){
            return DeviceService.iPhoneModelSize()
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
        }
        
        var maxRows = false
        
        var stopLabel = UILabel(frame: CGRectMake(8, 4, 330, 30))
        stopLabel.textAlignment = NSTextAlignment.Left
        stopLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        stopLabel.font = stopLabel.font.fontWithSize(14)
        
        var distanceLabel = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
        distanceLabel.textAlignment = NSTextAlignment.Left
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = distanceLabel.font.fontWithSize(14)

        var lblSnameDir = UILabel(frame: CGRect(x: 8, y: 4, width: DeviceService.getLabelWidth(), height: 30))
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
    
        // Inget stopp || Inget stopp i närheten
        if (linesAtStop[indexPath.row].row == Row.Info || linesAtStop[indexPath.row].row == Row.Button){
            
            for view in cell.subviews{
                view.removeFromSuperview()
            }
            
            if (linesAtStop[indexPath.row].row == Row.Info){
                stopLabel.text = linesAtStop[indexPath.row].stopName
                
                cell.addSubview(stopLabel)
            }
            else if (linesAtStop[indexPath.row].row == Row.Button){
                let btnMainApp = UIButton(frame: CGRectMake(10,0, cell.bounds.width - 40, 35))
                btnMainApp.backgroundColor = UIColor.clearColor()
                btnMainApp.setTitle("Lägg till ny hållplats", forState: UIControlState.Normal)
                btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
                btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
                btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
                btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
                btnMainApp.layer.cornerRadius = 5
                
                cell.addSubview(btnMainApp)
            }
        }
            // En hållplats (rubrik)
        else if (linesAtStop[indexPath.row].row == Row.Stop){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            distanceLabel.text = String(linesAtStop[indexPath.row].distance) + " m"
            
            cell.addSubview(stopLabel)
            cell.addSubview(distanceLabel)
            
            var separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
            
            cell.addSubview(separatorView)
        }
        //Inga avgångar hittades
        else if (linesAtStop[indexPath.row].row == Row.NoDepartures){
            stopLabel.text = linesAtStop[indexPath.row].stopName
            
            stopLabel.font = UIFont.italicSystemFontOfSize(12)
            stopLabel.textColor = UIColor.whiteColor()
            
            cell.addSubview(stopLabel)
        }
        // Linje
        else if (linesAtStop[indexPath.row].row == Row.Line){
            lblSnameDir.text = linesAtStop[indexPath.row].sname
            lblSnameDir.text! += " " + linesAtStop[indexPath.row].direction
            
            println(lblSnameDir)
            
            for (index, rtTime) in enumerate(linesAtStop[indexPath.row].rtTimes){
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
            }
            
            var separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
            
            cell.addSubview(separatorView)
            cell.addSubview(lblSnameDir)
            cell.addSubview(depLabelOne)
            cell.addSubview(depLabelTwo)
        }
        
        if (linesAtStop.count < DeviceService.iPhoneModelSize()){
            self.preferredContentSize = CGSizeMake(0, CGFloat(linesAtStop.count * 36))
        }
        else{
            self.preferredContentSize = CGSizeMake(0, CGFloat(DeviceService.iPhoneModelSize() * 36 + 5))
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (linesAtStop.count == 0){
            var view = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height));
            var loadingLabel = UILabel(frame: CGRectMake(0, 4, 200, 15))
            loadingLabel.textAlignment = NSTextAlignment.Left
            loadingLabel.textColor = UIColor.grayColor()
            loadingLabel.font = loadingLabel.font.fontWithSize(14)
            loadingLabel.text = "Laddar hållplatser..."
            
            view.addSubview(loadingLabel)
            
            return view
        }
        else if (linesAtStop.count > DeviceService.iPhoneModelSize()){
             var view = UIView(frame: CGRectMake(0, 120, 300, 36));
            
            var maxLabel = UILabel(frame: CGRectMake(8, 10, 300, 36))
            
            // Max antal linjer
            maxLabel.text =  "Max antal linjer. Listar närmaste avgångar"
            maxLabel.font = UIFont.italicSystemFontOfSize(12)
            maxLabel.textColor = UIColor.whiteColor()
                
            view.addSubview(maxLabel)
            
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
        return 35.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var url = NSURL(fileURLWithPath: "Tajma://home")
        self.extensionContext?.openURL(url!, completionHandler: nil)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
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
            var todayLabel = TodayLabel(stopName: "Ingen vald hållplats i närheten :(", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Info)
            linesAtStop.append(todayLabel)
            
            var todayButton = TodayLabel(stopName: "Lägg till ny hållplats", distance: 0, sname: "", direction: "", snameAndDirection: "", fgColor: "", bgColor: "", rtTimes: tempArr, row: Row.Button)
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
                        departure.rtTimes.sort({$0 < $1})
                        
                        for (index, rtTime) in enumerate(departure.rtTimes){
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
                        
                        var trip = TodayLabel(stopName: stop.name, distance: stop.distance, sname: departure.sname, direction: departure.direction, snameAndDirection: departure.sname + " " + departure.direction, fgColor: departure.fgColor, bgColor: departure.bgColor, rtTimes: rtTimesArr, row: Row.Line)
                        
                        linesAtStop.append(trip)
                    }
                    
                }
            }
            
            // Sortera lista på distans och sedan efter avgångar
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
            
            // Går igenom och kollar om det är max antal stopp
            // Om max antal så vill vi dölja dubletter av linjer för hållplatser
            // Ex: Linje 10 mot Centralstationen ska endast visas på den närmaste hållplatsen så att vi kan visa fler linjer
            var temp = [TodayLabel]()
            if (linesAtStop.count > DeviceService.iPhoneModelSize()){
                var arr = [String]()
                var temp = [TodayLabel]()
                
                for (index, stop) in enumerate(linesAtStop){
                    // Om sista raden endast är en hållplats så vill vi inte visa denna
                    if (index == DeviceService.iPhoneModelSize() - 1 && stop.snameAndDirection == ""){
                         break
                    }
                    if (stop.snameAndDirection == ""){
                        stop.snameAndDirection += String(index)
                    }
                    if (!contains(arr, stop.snameAndDirection)){
                        temp.append(stop)
                        arr.append(stop.snameAndDirection)
                    }
                }
                
                linesAtStop = temp
            }

            self.updateTable()
        }
    }
    
    func updateTable(){
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}