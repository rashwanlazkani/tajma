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
    @IBOutlet weak var infoLabel: UILabel!
    var departureService = DepartureService()
    var lineService = LineService()
    var timer = NSTimer()
    let locationManager = CLLocationManager()
    
    var stops = [Stop]()
    var lat  = ""
    var long = ""
    var timerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            displayMessage("Laddar avgångar...")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        else{
            displayMessage("Slå på platstjänster för att använda Tajma.")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        infoLabel.userInteractionEnabled = true
        let aSelector : Selector = "lblTapped"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        infoLabel.addGestureRecognizer(tapGesture)
        
        lat = ""
        long = ""
        
        locationManager.startUpdatingLocation()
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("getLocation"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        self.stops = [Stop]()
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        infoLabel.text = ""
    }
    
    // MARK: - Location
    func getLocation(){
        if timerCount >= 4{
            timer.invalidate()
            return
        }
        timerCount++
        lat = ""
        long = ""
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!lat.isEmpty && !long.isEmpty){
            return
        }
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        lat = String(location.latitude)
        long = String(location.longitude)
        
        locationManager.stopUpdatingLocation()
        getData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        displayMessage("Slå på platstjänster för att använda Tajma.")
        locationManager.requestLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.Restricted:
            displayMessage("Slå på platstjänster för att använda Tajma.")
        case CLAuthorizationStatus.Denied:
            displayMessage("Slå på platstjänster för att använda Tajma.")
        default:
            break
        }
    }
    
    func displayMessage(message: String){
        preferredContentSize = CGSizeMake(0, 30)
        if (message == infoLabel.text){
            return
        }
        infoLabel.text = message
        infoLabel.hidden = false
    }
    
    // MARK: - Widget Delegate
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        displayMessage("Laddar data")
        getData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return stops.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops[section].lines.count == 0 ? 1 : stops[section].lines.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ("\(stops[section].name) \(stops[section].distance)m")
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        let name = UILabel(frame: CGRectMake(8, 15, DeviceHelper.getLabelWidth(), 30))
        name.font = name.font.fontWithSize(14)
        name.text = stops[section].name
        name.textColor = UIColor.lightGrayColor()
        
        let distance = UILabel(frame: CGRectMake(tableView.bounds.width - 110, 15, 100, 30))
        distance.font = distance.font.fontWithSize(14)
        distance.textColor = UIColor.lightGrayColor()
        distance.textAlignment = .Right;
        distance.text = String(stops[section].distance) + " m"
        
        let separator = UIView(frame: CGRectMake(0, 45, tableView.frame.width, 1))
        separator.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
    
        view.addSubview(separator)
        view.addSubview(name)
        view.addSubview(distance)
        
        return view
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        for view in cell.subviews{
            view.removeFromSuperview()
        }
        
        let mainLabel = UILabel(frame: CGRectMake(8, 4, DeviceHelper.getLabelWidth(), 30))
        mainLabel.font = mainLabel.font.fontWithSize(14)
        let rightOne = UILabel(frame: CGRectMake(tableView.bounds.width - 150, 4, 100, 30))
        rightOne.font = rightOne.font.fontWithSize(14)
        let rightTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
        rightTwo.font = rightTwo.font.fontWithSize(14)
        
        let currentStop = stops[indexPath.section]
        if (currentStop.lines.isEmpty) {
            mainLabel.text = "Inga avgångar hittades"
            mainLabel.textColor = UIColor.whiteColor()
            cell.addSubview(mainLabel)
            return cell
        }
        
        let currentLine = currentStop.lines[indexPath.row]
        
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
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let table = UIView(frame: CGRectZero)
        tableView.tableFooterView = table
        table.hidden = true
        tableView.tableFooterView?.hidden = true
        self.tableView.backgroundColor = UIColor.clearColor()
        
        return table
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openMainApp(nil)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: - Events
    func openMainApp(sender: UIButton!) {
        if (infoLabel.text == "Klicka här för att slå på platstjänster."){
        }
        else{
            let url = NSURL(fileURLWithPath: "Tajma://home")
            self.extensionContext?.openURL(url, completionHandler: nil)
        }
    }
    
    // MARK: - Functions
    func getData(){
        print("getData lat \(lat) long \(long) INNAN!")
        
        if (lat == "" && long == ""){
            locationManager.startUpdatingLocation()
            return
        }
        
        print("getData lat \(lat) long \(long) EFTER!")
        stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        var count = stops.count
        var height = stops.count * 40
        for stop in stops{
            height += (stop.lines.count == 0 ? 1 : stop.lines.count) * 36
            
            
            count += stop.lines.count == 0 ? 1 : stop.lines.count
        }

        preferredContentSize = CGSizeMake(0, CGFloat(height))
        
        if (stops.isEmpty){
            displayMessage("Ingen vald hållplats i närheten.")
            tableView.reloadData()
            return
        }
        else{
            infoLabel.hidden = true
        }
        
        self.tableView.reloadData()
    }
    
    func lblTapped(){
        openMainApp(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}