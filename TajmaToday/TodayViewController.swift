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
    var webService = WebService()
    let locationManager = CLLocationManager()
    var grayColor = UIColor.darkGray
    var grayColorOpacity = UIColor.darkGray
    var separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
    
    var stops = [Stop]()
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DbService.shared.updateOptionals()
        
        grayColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        grayColorOpacity = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
        separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
        infoText.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        infoText.frame = CGRect(x: 10, y: 10, width: 400, height: 100)
        
        if !Reachability.isConnectedToNetwork() {
            locationManager.stopUpdatingLocation()
            display("Ingen anslutning till internet.")
            return
        }
        
        infoText.isUserInteractionEnabled = true
        let aSelector = #selector(lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        infoText.addGestureRecognizer(tapGesture)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLLocationAccuracyBest
        } else {
            display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        grayColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        grayColorOpacity = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
        separatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.1)
        infoText.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        infoText.frame = CGRect(x: 10, y: 10, width: 400, height: 100)
        
        if !Reachability.isConnectedToNetwork() {
            locationManager.stopUpdatingLocation()
            display("Ingen anslutning, försök igen.")
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            display("Laddar avgångar...")
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        } else {
            display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    private func fetch() {
        guard let location = location else {
            tableView.reloadData()
            display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
            return
        }
        
        webService.getMyDeparturesAt(location, onCompletion: { (stops) in
            self.preferredContentSize = CGSize(width: 0, height: self.contentHeight())
            
            if stops.isEmpty {
                self.display("Ingen vald hållplats i närheten.")
                self.tableView.reloadData()
                return
            }
            
            self.infoText.isHidden = true
            self.stops = stops
            self.locationManager.stopUpdatingLocation()
            self.tableView.reloadData()
        }) { (error) in
            self.display(error.localizedDescription)
            self.tableView.reloadData()
            return
        }
    }
    
    // MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if location?.latitude == 0 {
            if let c = manager.location?.coordinate{
                location = c
            } else {
                location = CLLocationCoordinate2D()
            }
            fetch()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted:
            display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
        case CLAuthorizationStatus.denied:
            display("Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster.")
        default:
            break
        }
    }
    
    private func display(_ message: String){
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        if message == infoText.text {
            return
        }
        
        infoText.text = message
        infoText.isHidden = false
        
        if #available(iOSApplicationExtension 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                infoText.textColor = .white
            } else {
                infoText.textColor = .black
            }
        } else {
            infoText.textColor = .black
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops[section].lines.count == 0 ? 1 : stops[section].lines.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ("\(stops[section].name) \(String(describing: stops[section].distance))m")
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        let name = UILabel(frame: CGRect(x: 15, y: 10, width: DeviceHelper.getLabelWidth(), height: 18))
        name.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
        
        // Hållplatsnamn
        if #available(iOSApplicationExtension 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                name.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
            } else {
                name.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
            }
        } else {
            name.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        }
        
        name.text = stops[section].name.components(separatedBy: ",")[0]
        
        let distance = UILabel(frame: CGRect(x: tableView.bounds.width - 110, y: 10, width: 95, height: 18))
        distance.font = UIFont.systemFont(ofSize: 15.0)
        
        distance.textAlignment = .right
        
        if #available(iOSApplicationExtension 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                distance.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
            } else {
                distance.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
            }
        } else {
            distance.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        }
        
        distance.text = stops[section].distance == nil ? "- m" : ("\(String(describing: stops[section].distance!)) m")
        
        view.addSubview(name)
        view.addSubview(distance)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WidgetBodyCell
        
        let currentStop = stops[indexPath.section]
        if currentStop.lines.isEmpty {
            cell.snameDirection.text = "Inga avgångar hittades"
            cell.firstDep.text = ""
            cell.secondDep.text = ""
            return cell
        }
        
        let currentLine = currentStop.lines[indexPath.row]
        currentLine.departures.sort(by: { $0 < $1 })
        cell.snameDirection.text = "\(currentLine.sname) \(currentLine.direction)"
        
        for (index, time) in currentLine.departures.enumerated() {
            if time == 0 {
                if index == 0 {
                    cell.firstDep.text = "Nu"
                } else if index == 1 {
                    cell.secondDep.text = "Nu"
                }
            } else if index == 0 {
                cell.firstDep.text = time < 0 ? "0" : String(time)
            } else if index == 1 {
                cell.secondDep.text = time < 0 ? "0" : String(time)
            }
        }

        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
        separatorView.backgroundColor = UIColor(red: 00/255, green: 00/255, blue: 00/255, alpha: 0.05)
        
        return separatorView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMainApp(nil)
    }
    
    func openMainApp(_ sender: UIButton?) {
        if infoText.text != "Kunde inte fastställa din position. Gå till Inställningar -> Tajma och tillåt platstjänster." {
            let url = URL(fileURLWithPath: "Tajma://home")
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: 0.0, height: 300.0)
        } else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            self.preferredContentSize = CGSize(width: 0, height: contentHeight())
        }
    }
    
    private func contentHeight() -> CGFloat {
        var count = stops.count
        var height = stops.count * 39 // header
        for stop in stops {
            height += (stop.lines.count == 0 ? 1 : stop.lines.count) * 30 // avgång
            count += stop.lines.count == 0 ? 1 : stop.lines.count
        }
        return CGFloat(height)
    }
    
    @objc func lblTapped(){
        openMainApp(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
