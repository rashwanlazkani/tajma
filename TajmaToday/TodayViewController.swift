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
    let locationManager = CLLocationManager()
    
    var stops = [Stop]()
    var lat  = ""
    var long = ""
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

        //self.preferredContentSize = CGSize(width: 50, height: 250)
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        //self.tableView.reloadData()
    }
    
    func displayError(error: String){
        if (error == errorLabel.text){
            return
        }
        self.preferredContentSize = CGSize(width: 300, height: 50)
        errorLabel.text = error
        errorLabel.hidden = false
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
//        count = stops.count
//        from(stops).each({self.count += $0.lines.count})
//        
//        for stop in stops{
//            count += stop.lines.count
//        }
//        
//        if (count > DeviceHelper.iPhoneModelSize()){
//            return DeviceHelper.iPhoneModelSize()
//        }
//        else{
//            return count
//        }
        return stops.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentStop = stops[section]
        return currentStop.name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let currentLine = stops[indexPath.section].lines[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        for view in cell.subviews{
            view.removeFromSuperview()
        }
        
//        let mainLabel = UILabel(frame: CGRectMake(8, 4, DeviceHelper.getLabelWidth(), 30))
//        mainLabel.font = mainLabel.font.fontWithSize(14)
//        let rightOne = UILabel(frame: CGRectMake(tableView.bounds.width - 50, 4, 100, 30))
//        rightOne.font = rightOne.font.fontWithSize(14)
//        let rightTwo = UILabel(frame: CGRectMake(tableView.bounds.width - 60, 4, 30, 30))
//        rightTwo.font = rightTwo.font.fontWithSize(14)
//        
//        let letterSname = Int(currentLine.sname)
//        if (letterSname == nil){
//            mainLabel.textColor = UIColor.whiteColor()
//        }
//        
//        mainLabel.textColor = UIColor.whiteColor()
//        mainLabel.font = UIFont.italicSystemFontOfSize(12)
//        mainLabel.text = currentLine.stop.name
//        cell.addSubview(mainLabel)
//        
//        // Linje
//        rightOne.frame = CGRectMake(tableView.bounds.width - 70, 4, 30, 30)
//        rightOne.textColor = UIColor.whiteColor()
//        rightOne.font = rightOne.font.fontWithSize(14)
//        rightOne.textAlignment = .Right;
//        rightTwo.frame = CGRectMake(tableView.bounds.width - 30, 4, 25, 30)
//        rightTwo.textColor = UIColor.lightGrayColor()
//        rightTwo.font = rightTwo.font.fontWithSize(14)
//        rightTwo.textAlignment = .Right;
//        mainLabel.textColor = UIColor.whiteColor()
//        mainLabel.text = currentLine.sname
//        mainLabel.text! += " " + currentLine.direction
//        
//        for (index, time) in currentLine.departures.times.enumerate(){
//            if (index == 0 && time == 0){
//                rightOne.text = "Nu"
//            }
//            else if (index == 1 && time == 0){
//                rightTwo.text = "Nu"
//            }
//            else if (index == 0){
//                if (time < 0){
//                    rightOne.text = "0"
//                }
//                else{
//                    rightOne.text = String(time)
//                }
//            }
//            else if (index == 1){
//                if (time < 0){
//                    rightTwo.text = "0"
//                }
//                else{
//                    rightTwo.text = String(time)
//                }
//            }
//        }
//        
//        let separatorView = UIView(frame: CGRect(x: 0, y: 36, width: Int(cell.frame.size.width), height: 1))
//        separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.1)
//        
//        cell.addSubview(separatorView)
//        cell.addSubview(mainLabel)
//        cell.addSubview(rightOne)
//        cell.addSubview(rightTwo)
//        
//        if (count < DeviceHelper.iPhoneModelSize()){
//            self.preferredContentSize = CGSizeMake(0, CGFloat(count * 36))
//        }
//        else{
//            self.preferredContentSize = CGSizeMake(0, CGFloat(DeviceHelper.iPhoneModelSize() * 36 + 5))
//        }
        
        
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
        let firstLaunch = NSUserDefaults(suiteName: "group.tajma.today")!.boolForKey("FirstLaunch")
        //let x = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        print(firstLaunch)
        
        print("getData")
        stops = departureService.getMyDepartures((lat as NSString).doubleValue, long: (long as NSString).doubleValue)
        
        if (stops.isEmpty){
            displayError("Ingen vald hållplats i närheten.")
        }
        else{
            for stop in stops{
                
            }
        }
        
        errorLabel.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}