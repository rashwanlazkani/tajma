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
    var location = CLLocationCoordinate2D()
    var isFromBackground = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DbService.sharedInstance.updateOptionals()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        setRateSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isFromBackground = false
        navigationController?.navigationBar.isHidden = true
        navController.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            location = CLLocationCoordinate2D()
            self.locationManager.startUpdatingLocation()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            stops = DbService.sharedInstance.getStops()
        }
        
        lines = DbService.sharedInstance.getLines()
        tableView.reloadData()
    }
    
    // MARK: - Functions
    func initiateViews(){
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        searchBar.setImage(UIImage(named: "search-white"), for: UISearchBar.Icon.search, state: UIControl.State())
        searchBar.setImage(UIImage(named: "erase"), for: UISearchBar.Icon.clear, state: UIControl.State())
        searchBar.tintColor = UIColor.white
        let textfield:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        textfield.attributedPlaceholder = attributedString
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // För att sätta bakgrundfärg och opacitet på placeholdertext för searchBar
        let txt:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        let attr = NSAttributedString(string: "Sök hållplats", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
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
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        if isFromBackground {
            self.segmentedControl.selectedSegmentIndex = 0
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        isFromBackground = true
    }
    
    func getNearestStops() {
        self.activityIndicator.startAnimating()
        self.segmentedControl.isEnabled = false
        
        stopService.getNearestStops(location.latitude, long: location.longitude, onSuccess: { stops -> Void in
            DispatchQueue.main.async(execute: {
                self.stops = stops
                if self.stops.count == 0 {
                    self.display("Inga hållplatser i närheten.", type: .nearest)
                }
                self.tableView!.reloadData()
                self.locationManager.stopUpdatingLocation()
                self.segmentedControl.isEnabled = true
                self.activityIndicator.stopAnimating()
            })
            }, onError:{ error -> Void in
                self.display("Ett fel har uppstått med hämtning av närmaste hållplatser.", type: .location)
        })
    }
    
    func display(_ error: String, type: ErrorType) {
        let alert = UIAlertController(title: "Tajma", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Försök igen", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            switch type {
            case .location :
                return self.locationManager.startUpdatingLocation()
            case .nearest :
                return self.getNearestStops()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func segmentedControl_Changed(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            location = CLLocationCoordinate2D()
            self.locationManager.startUpdatingLocation()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let swedish = Locale(identifier: "sv")
            stops = DbService.sharedInstance.getStops().sorted(by: { (first, second) -> Bool in
                first.name.compare(second.name, locale: swedish) == .orderedAscending
            })
        }
        
        self.segmentedControl.setTitle("Nära mig", forSegmentAt: 0)
        self.searchBar.text = ""
        lines = DbService.sharedInstance.getLines()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            stopService.getStopsByInput(searchText, onSuccess: { stops -> Void in
                DispatchQueue.main.async(execute: {
                    self.stops = stops
                    self.lines = DbService.sharedInstance.getLines()
                    
                    if self.stops.count > 0 {
                        self.segmentedControl.setTitle("Sökresultat", forSegmentAt: 0)
                    }
                    
                    self.tableView!.reloadData()
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }, onError:{ error -> Void in
                self.display("Ett fel har uppstått med sökningen.", type: .location)
            })
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            self.view.endEditing(true)
            return
        }
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
                self.display("Ett fel har uppstått med sökningen.", type: .location)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !location.latitude.isZero || !location.longitude.isZero {
            return
        } else if Reachability.isConnectedToNetwork() != true {
            stops = [Stop]()
            return
        }
        
        if let coordinate = manager.location?.coordinate {
            location = coordinate
        }

        locationManager.stopUpdatingLocation()
        getNearestStops()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.", type: .location)
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
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
