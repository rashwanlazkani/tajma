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
import SINQ

class TodayTableViewController: UITableViewController, CLLocationManagerDelegate {
    @IBOutlet weak var errorLabel: UILabel!
    var departureService = DepartureService()
    var lineService = LineService()
    var timer = NSTimer()
    var stops = [Stop]()
    let locationManager = CLLocationManager()
    
    var lat  = ""
    var long = ""
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stops = RealmService.sharedInstance.getStops()

        print("viewDidLoad")
        //self.preferredContentSize = CGSize(width: 50, height: 20)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else{
            locationOff()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        locationManager.startUpdatingLocation()
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("getLocation"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    // MARK: - Location
    func getLocation(){
        locationManager.startUpdatingLocation()
    }
    
    func locationOff(){
        displayError("Du måste slå på lokaliseringen för Tajma.")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        lat = String(location.latitude)
        long = String(location.longitude)
        //locationManager.stopUpdatingLocation()
        getData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user´s location: \(error.localizedDescription)")
        displayError("Kunde inte faställa position, försöker igen...")
        locationManager.requestLocation()
        self.tableView.reloadData()
    }
    
    func displayError(error: String){
        errorLabel.text = error
        tableView.hidden = true
    }
    
    // MARK: - Widget Delegate
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return stops.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count = stops.count
        from(stops).each({self.count += $0.lines.count})
        
        if (count > DeviceHelper.iPhoneModelSize()){
            return DeviceHelper.iPhoneModelSize()
        }
        else{
            return count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentStop = stops[section]
        return currentStop.name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentLine = stops[indexPath.section].lines[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        for view in cell.subviews{
            view.removeFromSuperview()
        }
        
        let mainLabel = UILabel(frame: CGRectMake(8, 4, DeviceHelper.getLabelWidth(), 30))
        mainLabel.font = mainLabel.font.fontWithSize(14)
        let rightOne = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
        rightOne.font = rightOne.font.fontWithSize(14)
        let rightTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
        rightTwo.font = rightTwo.font.fontWithSize(14)

        let letterSname = Int(currentLine.sname)
        // Linje med bokstäver
        if (letterSname == nil){
            mainLabel.textColor = UIColor.whiteColor()
        }
        
//        // Inget stopp || Inget stopp i närheten
//        if (addedLinesAtStop[indexPath.row].row == Row.Info || addedLinesAtStop[indexPath.row].row == Row.Button){
//            mainLabel.textColor = UIColor.grayColor()
//            for view in cell.subviews{
//                view.removeFromSuperview()
//            }
//            
//            if (addedLinesAtStop[indexPath.row].row == Row.Info){
//                mainLabel.text = addedLinesAtStop[indexPath.row].stopName
//                cell.addSubview(mainLabel)
//            }
//            else if (addedLinesAtStop[indexPath.row].row == Row.Button){
//                let btnMainApp = UIButton(frame: CGRectMake(10,cell.bounds.height / 2, cell.bounds.width - 40, 35))
//                btnMainApp.backgroundColor = UIColor.clearColor()
//                btnMainApp.setTitle("Lägg till ny hållplats", forState: UIControlState.Normal)
//                btnMainApp.addTarget(self, action: "openMainApp:", forControlEvents: .TouchUpInside)
//                btnMainApp.titleLabel?.font = UIFont.systemFontOfSize(14.0)
//                btnMainApp.titleLabel?.textAlignment = NSTextAlignment.Left
//                btnMainApp.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
//                btnMainApp.layer.cornerRadius = 5
//                cell.addSubview(btnMainApp)
//            }
//        }
//        // En hållplats (rubrik)
//        if (addedLinesAtStop[indexPath.row].row == Row.Stop){
//            mainLabel.textColor = UIColor.grayColor()
//            mainLabel.text = addedLinesAtStop[indexPath.row].stopName
//            rightTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 55, 30))
//            rightTwo.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
//            rightTwo.font = rightTwo.font.fontWithSize(14)
//            rightTwo.text = String(addedLinesAtStop[indexPath.row].distance) + " m"
//            rightTwo.textAlignment = .Right;
//            cell.addSubview(mainLabel)
//            cell.addSubview(rightTwo)
//            
//            let separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
//            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
//            cell.addSubview(separatorView)
//        }
//        if (addedLinesAtStop[indexPath.row].row == Row.NoDepartures){
//            mainLabel.textColor = UIColor.whiteColor()
//            mainLabel.font = UIFont.italicSystemFontOfSize(12)
//            mainLabel.text = addedLinesAtStop[indexPath.row].stopName
//            cell.addSubview(mainLabel)
//        }
        // Linje
        rightOne.frame = CGRectMake(tableView.bounds.width - 70, 4, 30, 30)
        rightOne.textColor = UIColor.whiteColor()
        rightOne.font = rightOne.font.fontWithSize(14)
        rightOne.textAlignment = .Right;
        rightTwo.frame = CGRectMake(tableView.bounds.width - 30, 4, 25, 30)
        rightTwo.textColor = UIColor.lightGrayColor()
        rightTwo.font = rightTwo.font.fontWithSize(14)
        rightTwo.textAlignment = .Right;
        mainLabel.textColor = UIColor.whiteColor()
        mainLabel.text = currentLine.sname
        mainLabel.text! += " " + currentLine.direction
        
        for (index, time) in currentLine.departures.times.enumerate(){
            if (index == 0 && time == 0){
                rightOne.text = "Nu"
            }
            else if (index == 1 && time == 0){
                rightTwo.text = "Nu"
            }
            else if (index == 0){
                if (time < 0){
                    rightOne.text = "0"
                }
                else{
                    rightOne.text = String(time)
                }
            }
            else if (index == 1){
                if (time < 0){
                    rightTwo.text = "0"
                }
                else{
                    rightTwo.text = String(time)
                }
            }
        }
        
        let separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
        separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
        
        cell.addSubview(separatorView)
        cell.addSubview(mainLabel)
        cell.addSubview(rightOne)
        cell.addSubview(rightTwo)
        
        if (count < DeviceHelper.iPhoneModelSize()){
            self.preferredContentSize = CGSizeMake(0, CGFloat(count * 36))
        }
        else{
            self.preferredContentSize = CGSizeMake(0, CGFloat(DeviceHelper.iPhoneModelSize() * 36 + 5))
        }
        
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.layer.backgroundColor = UIColor.clearColor().CGColor
//    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        print("viewForFooterInSection")
        if (count == 0){
            let view = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height));
            let loadingLabel = UILabel(frame: CGRectMake(0, 4, 200, 15))
            loadingLabel.textAlignment = NSTextAlignment.Left
            loadingLabel.textColor = UIColor.grayColor()
            loadingLabel.font = loadingLabel.font.fontWithSize(14)
            loadingLabel.text = "Laddar hållplatser..."
            view.addSubview(loadingLabel)
            return view
        }
        else if (count > DeviceHelper.iPhoneModelSize()){
            let view = UIView(frame: CGRectMake(0, 120, 300, 36));
            let maxLabel = UILabel(frame: CGRectMake(8, 10, 300, 36))
            maxLabel.text =  "Max antal linjer. Listar närmaste avgångar"
            maxLabel.font = UIFont.italicSystemFontOfSize(12)
            maxLabel.textColor = UIColor.whiteColor()
            view.addSubview(maxLabel)
            return view
        }
        else{
            let table = UIView(frame: CGRectZero)
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
        openMainApp(nil)
    }
    
    // MARK: - Events
    func openMainApp(sender: UIButton!) {
        let url = NSURL(fileURLWithPath: "Tajma://home")
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    
    // MARK: - Functions
    func getData(){
        // ta data och platta till den med sektioner så att den passar listan
        stops = departureService.getMyDepartures(stops, lat: (lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        self.tableView.reloadData()
        
        if (stops.isEmpty){
            displayError("Ingen vald hållplats i närheten.")
        }
//        else{
//            for stop in stops{
//                if (stop.lines.count == 0){
//                    displayError("Inga avgångar hittades.")
//                }
//                else{
//                    for departure in stop.departures.times{
//                        var rtArr = [Int]()
//                        departure.rtTimes.sortInPlace({$0 < $1})
//                        
//                        for (index, rtTime) in departure.rtTimes.enumerate(){
//                            if(index == 2){
//                                continue
//                            }
//                            rtArr.append(rtTime)
//                        }
//                        
//                        let trip = TodayRow()
//                        trip.stopName = stop.name
//                        trip.distance = stop.distance
//                        trip.sname = departure.sname
//                        trip.direction = departure.direction
//                        trip.snameAndDirection = "\(departure.sname) \(departure.direction)"
//                        trip.fgColor = departure.fgColor
//                        trip.bgColor = departure.bgColor
//                        trip.rtTimes = rtArr
//                        trip.row = Row.Line
//                        addedLinesAtStop.append(trip)
//                    }
//                }
//            }

            // Sortera lista på distans och sedan efter avgångar
//            let sortedList = stops.sort {
//                switch ($0.distance,$1.distance) {
//                    // if neither “category" is nil and contents are equal,
//                case let (lhs,rhs) where lhs == rhs:
//                    // compare “status” (> because DESC order)
//                    return $0.rtTimes[0] < $1.rtTimes[0]
//                    // else just compare “category” using <
//                case let (lhs, rhs):
//                    return lhs < rhs
//                }
//            }
//            stops = sortedList
        
//            // Går igenom och kollar om det är max antal stopp
//            // Om max antal så vill vi dölja dubletter av linjer för hållplatser
//            // Ex: Linje 10 mot Centralstationen ska endast visas på den närmaste hållplatsen så att vi kan visa fler linjer
//            if (addedLinesAtStop.count > DeviceHelper.iPhoneModelSize()){
//                var arr = [String]()
//                var temp = [TodayRow]()
//                
//                for (index, stop) in addedLinesAtStop.enumerate(){
//                    // Om sista raden endast är en hållplats så vill vi inte visa denna
//                    if (index == DeviceHelper.iPhoneModelSize() - 1 && stop.snameAndDirection == ""){
//                         break
//                    }
//                    if (stop.snameAndDirection == ""){
//                        stop.snameAndDirection += String(index)
//                    }
//                    if (!arr.contains(stop.snameAndDirection)){
//                        temp.append(stop)
//                        arr.append(stop.snameAndDirection)
//                    }
//                }
//                addedLinesAtStop = temp
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}