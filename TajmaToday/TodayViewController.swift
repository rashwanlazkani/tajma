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

class TodayTableViewController: UITableViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    @IBOutlet weak var infoText: UITextView!
    var departureService = DepartureService()
    var lineService = LineService()
    let locationManager = CLLocationManager()
    var grayColor = UIColor.darkGray
    var grayColorOpacity = UIColor.darkGray
    var separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
    
    var stops = [Stop]()
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            grayColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            grayColorOpacity = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
            separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
            infoText.textColor = grayColorOpacity
            infoText.frame = CGRect(x: 15, y: 15, width: 400, height: 100)
        } else {
            grayColor = UIColor.white
            grayColorOpacity = UIColor.lightGray
            separatorColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            infoText.textColor = UIColor.white
            
            self.preferredContentSize = CGSize(width: 0, height: 60)
        }
        
        if !Reachability.isConnectedToNetwork() {
            locationManager.stopUpdatingLocation()
            display("Ingen anslutning, försök igen.")
            return
        }

        SqliteService.sharedInstance.updateOptionals()
        
        infoText.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        infoText.addGestureRecognizer(tapGesture)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        else{
            display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if #available(iOS 10.0, *) {
            grayColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            grayColorOpacity = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
            separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
            infoText.textColor = grayColorOpacity
            infoText.frame = CGRect(x: 15, y: 15, width: 400, height: 100)
        } else {
            grayColor = UIColor.white
            grayColorOpacity = UIColor.lightGray
            separatorColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
            infoText.textColor = UIColor.white
            
            self.preferredContentSize = CGSize(width: 0, height: 60)
        }
        
        if !Reachability.isConnectedToNetwork() {
            locationManager.stopUpdatingLocation()
            display("Ingen anslutning, försök igen.")
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            display("Laddar avgångar...")
            coordinate = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
        else{
            display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if coordinate?.latitude == 0 {
            if let c = manager.location?.coordinate{
                coordinate = c
            }
            else{
                coordinate = CLLocationCoordinate2D()
            }
            fetch()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted:
            display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
        case CLAuthorizationStatus.denied:
            display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
        default:
            break
        }
    }
    
    func display(_ message: String){
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            preferredContentSize = CGSize(width: 0, height: 60)
        }
        if (message == self.infoText.text){
            return
        }
        infoText.text = message
        infoText.isHidden = false
        
        tableView.reloadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // TODO: Behövs denna nu?
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops[section].lines.count == 0 ? 1 : stops[section].lines.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ("\(stops[section].name) \(stops[section].distance)m")
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        
        let name = UILabel(frame: CGRect(x: 15, y: 15, width: DeviceHelper.getLabelWidth(), height: 30))
        name.font = name.font.withSize(14)
        name.textColor = grayColorOpacity //grayColor
        
        name.text = stops[section].name.components(separatedBy: ",")[0]
        
        let distance = UILabel(frame: CGRect(x: tableView.bounds.width - 110, y: 15, width: 95, height: 30))
        distance.font = distance.font.withSize(14)
        distance.textColor = grayColorOpacity //grayColor
        distance.textAlignment = .right
        
        if let d = stops[section].distance{
            distance.text = ("\(d) m")
        }
        else{
            distance.text = "- m"
        }
        
        let separator = UIView(frame: CGRect(x: 0, y: 45, width: tableView.frame.width, height: 1))
        separator.backgroundColor = separatorColor
        
        view.addSubview(separator)
        view.addSubview(name)
        view.addSubview(distance)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        for view in cell.subviews{
            view.removeFromSuperview()
        }
        
        let mainLabel = UILabel(frame: CGRect(x: 15, y: 4, width: DeviceHelper.labelWidth() - 30, height: 30))
        mainLabel.font = mainLabel.font.withSize(14)
        let rightOne = UILabel(frame: CGRect(x: tableView.bounds.width - 150, y: 4, width: 100, height: 30))
        rightOne.font = rightOne.font.withSize(14)
        let rightTwo = UILabel(frame: CGRect(x: tableView.bounds.width - 60, y: 4, width: 30, height: 30))
        rightTwo.font = rightTwo.font.withSize(14)
        
        let currentStop = stops[(indexPath as NSIndexPath).section]
        if (currentStop.lines.isEmpty) {
            mainLabel.text = "Inga avgångar hittades"
            mainLabel.textColor = grayColor//UIColor.white
            cell.addSubview(mainLabel)
            return cell
        }
        
        let currentLine = currentStop.lines[(indexPath as NSIndexPath).row]
        
        rightOne.frame = CGRect(x: tableView.bounds.width - 75, y: 4, width: 25, height: 30)
        rightOne.textColor = grayColor//UIColor.white
        rightOne.font = rightOne.font.withSize(14)
        rightOne.textAlignment = .right
        rightTwo.frame = CGRect(x: tableView.bounds.width - 35, y: 4, width: 20, height: 30)
        rightTwo.textColor = grayColorOpacity //grayColor
        rightTwo.font = rightTwo.font.withSize(14)
        rightTwo.textAlignment = .right
        mainLabel.textColor = grayColor //UIColor.white
        mainLabel.text = ("\(currentLine.sname) \(currentLine.direction)")
        
        for (index, time) in currentLine.departures.times.enumerated(){
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
        separatorView.backgroundColor = separatorColor
        
        let totalRow = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row != totalRow - 1 {
            cell.addSubview(separatorView)
        }
        
        cell.addSubview(mainLabel)
        cell.addSubview(rightOne)
        cell.addSubview(rightTwo)
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let table = UIView(frame: CGRect.zero)
        tableView.tableFooterView = table
        table.isHidden = true
        tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.clear
        
        table.backgroundColor = UIColor.green
        
        return table
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMainApp(nil)
    }
    
    func openMainApp(_ sender: UIButton?) {
        if (infoText.text == "Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster."){
        }
        else{
            let url = URL(fileURLWithPath: "Tajma://home")
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = CGSize(width: 0.0, height: 300.0)
        }
        else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            self.preferredContentSize = CGSize(width: 0, height: contentHeight())
        }
        
    }
    
    func fetch(){
        var hasError = false
        var error: NSError?
        if let coordinate = coordinate{
            departureService.getMyDepartures(coordinate, onSuccess: { stops -> Void in
                DispatchQueue.main.async(execute: {
                    self.stops = stops

                    self.preferredContentSize = CGSize(width: 0, height: self.contentHeight())
                    
                    if (stops.isEmpty){
                        if hasError{
                            self.display(error!.domain)
                            self.tableView.reloadData()
                            return
                        }
                        self.display("Ingen vald hållplats i närheten.")
                        self.tableView.reloadData()
                        return
                    }
                    else{
                        self.infoText.isHidden = true
                    }
                    
                    self.locationManager.stopUpdatingLocation()
                    self.tableView.reloadData()
                })
                }, onError:{ e -> Void in
                    DispatchQueue.main.async(execute: {
                        hasError = true
                        error = e
                        self.display(e.domain)
                        self.tableView.reloadData()
                        return
                    })
                    
                    return
            })
        }
        else{
            tableView.reloadData()
            display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.")
        }
    }
    
    func contentHeight() -> CGFloat{
        var count = stops.count
        var height = stops.count * 40
        for stop in stops{
            height += (stop.lines.count == 0 ? 1 : stop.lines.count) * 36
            count += stop.lines.count == 0 ? 1 : stop.lines.count
        }
        return CGFloat(height)
    }
    
    func lblTapped(){
        openMainApp(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
