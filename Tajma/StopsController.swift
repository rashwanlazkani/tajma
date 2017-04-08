//
//  ViewController.swift
//  Kollektiv
//
//  Created by Rashwan Lazkani on 2015-05-30.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import CoreLocation

class StopsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    @IBOutlet var navController: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let lineService = LineService()
    var stopService = StopService()
    let deviceHelper = DeviceHelper()
    var stops = [Stop]()
    var lines = [Line]()
    let locationManager = CLLocationManager()
    var lat : String = ""
    var long : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DbService.sharedInstance.updateOptionals()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        searchBar!.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        setRateSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        navController.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if segmentedControl.selectedSegmentIndex == 1 {
            stops = DbService.sharedInstance.getStops()
        }
        
        lines = DbService.sharedInstance.getLines()
        tableView.reloadData()
    }
    
    // MARK: - Functions
    func initiateViews(){
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        searchBar.setImage(UIImage(named: "search-white"), for: UISearchBarIcon.search, state: UIControlState())
        searchBar.setImage(UIImage(named: "erase"), for: UISearchBarIcon.clear, state: UIControlState())
        searchBar.tintColor = UIColor.white
        let textfield:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.white])
        textfield.attributedPlaceholder = attributedString
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // För att sätta bakgrundfärg och opacitet på placeholdertext för searchBar
        let txt:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        let attr = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        txt.attributedPlaceholder = attr
        
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1).cgColor
        segmentedControl.backgroundColor = UIColor(red: 210/255, green: 43/255, blue: 69/255, alpha: 0.75)
    }
    
    func setRateSettings(){
        let rate = RateMyApp.sharedInstance
        rate.appID = Constants.appID
        
        DispatchQueue.main.async(execute: { () -> Void in
            rate.trackAppUsage()
        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.segmentedControl.selectedSegmentIndex = 0
        locationManager.startUpdatingLocation()
        lat = ""
        long = ""
    }
    
    func getNearestStops() {
        self.activityIndicator.startAnimating()
        self.segmentedControl.isEnabled = false
        
        stopService.getNearestStops(lat, long: long, onSuccess: { stops -> Void in
            DispatchQueue.main.async(execute: {
                self.stops = stops
                if self.stops.count == 0 {
                    self.display("Inga hållplatser i närheten.", type: Error.nearest)
                }
                self.tableView!.reloadData()
                self.locationManager.stopUpdatingLocation()
                self.segmentedControl.isEnabled = true
                self.activityIndicator.stopAnimating()
            })
            }, onError:{ error -> Void in
                self.display("Ett fel har uppstått med hämtning av närmaste hållplatser.", type: Error.location)
        })
    }
    
    func display(_ error: String, type: Error) {
        let alert = UIAlertController(title: "Tajma", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Försök igen", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
            switch type {
            case Error.location :
                return self.locationManager.startUpdatingLocation()
            case Error.nearest :
                return self.getNearestStops()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func segmentedControl_Changed(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            lat = ""
            long = ""
            self.locationManager.startUpdatingLocation()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            stops = DbService.sharedInstance.getStops()
        }
        
        self.segmentedControl.setTitle("Nära mig", forSegmentAt: 0)
        self.searchBar.text = ""
        lines = DbService.sharedInstance.getLines()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        segmentedControl.selectedSegmentIndex = 0
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        stopService.getStopsByInput(searchBar.text!, onSuccess: { stops -> Void in
            DispatchQueue.main.async(execute: {
                self.stops = stops
                self.lines = DbService.sharedInstance.getLines()
                
                if self.stops.count > 0 {
                    self.segmentedControl.setTitle("Sökresultat", forSegmentAt: 0)
                }
                
                searchBar.resignFirstResponder()
                self.tableView!.reloadData()
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            }, onError:{ error -> Void in
                self.display("Ett fel har uppstått med sökningen.", type: Error.location)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !lat.isEmpty && !long.isEmpty {
            return
        }
        
        if Reachability.isConnectedToNetwork() != true {
            stops = [Stop]()
            return
        }
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        lat = String(location.latitude)
        long = String(location.longitude)
        locationManager.stopUpdatingLocation()
        getNearestStops()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.", type: Error.location)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return stops.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let currentStop = stops[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as! StopCell
    
        cell.name.text = stops[(indexPath as NSIndexPath).row].name
        
        if (indexPath as NSIndexPath).row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
    
        if (!lines.filter{$0.stopId == currentStop.id}.isEmpty) {
            cell.checkmark.image = UIImage(named: "check-red")
        } else {
            cell.checkmark.image = UIImage()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        searchBar.resignFirstResponder()
        self.searchBar!.text = ""
        self.performSegue(withIdentifier: "ShowLinesView", sender: stops[(indexPath as NSIndexPath).row])
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if segue.identifier == "ShowLinesView" {
            // TODO: Click sluta sök
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let lines = segue.destination as! LinesViewController
            lines.stop = sender as! Stop
            lines.updateLines()
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
