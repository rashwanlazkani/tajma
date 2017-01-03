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
    
    let lineService = LineService()
    var stopService = StopService()
    let deviceHelper = DeviceHelper()
    let locationHelper = LocationHelper()
    var stops = [Stop]()
    var lines = [Line]()
    
    var cached = [Stop]()
    
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    var lat : String = ""
    var long : String = ""
    
    var horizontalAccuracy = 1000
    
    let guideController = GuideController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DbService.sharedInstance.updateOptionals()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        let loadData = UserDefaults(suiteName: "group.tajma.today")!.bool(forKey: "LoadData")
        if(!loadData){
            self.performSegue(withIdentifier: "ShowGuide", sender: nil)
            UserDefaults(suiteName: "group.tajma.today")!.set(true, forKey: "LoadData")
        }
        else{
            self.locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.distanceFilter = 50
                updateLocation()
            }
            
            self.title = "Bakåt"
            
            searchBar!.delegate = self
            tableView.delegate = self
            tableView.dataSource = self
            
            initiateViews()
            setRateSettings()
            
            lines = DbService.sharedInstance.getLines()
        }
        initiateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        navController.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (segmentedControl.selectedSegmentIndex == 1){
            stops = DbService.sharedInstance.getStops()
        }
        lines = DbService.sharedInstance.getLines()
        tableView.reloadData()
    }
    
    func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        print("Gesture recognized")
    }

    // MARK: - Functions
    func initiateViews(){
        self.view.backgroundColor = UIColor.white
        
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
        
        activityIndicator.center = CGPoint(x: (self.view.frame.width)/2, y: (self.view.frame.height)/3)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.color = UIColor.gray
        self.view.addSubview(activityIndicator)
        
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
        updateLocation()
    }
    
    private func roundToFive(x : Double) -> Int {
        return 5 * Int(round(x / 5.0))
    }
    
    func getNearestStops() {
        self.activityIndicator.startAnimating()
        self.segmentedControl.isEnabled = false
        stopService.getNearestStops(lat, long: long, onSuccess: { json -> Void in
            DispatchQueue.main.async(execute: {
                self.stops = json
                self.cached = json
                if (self.stops.count == 0){
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
    
    func display(_ error: String, type: Error){
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
        if (segmentedControl.selectedSegmentIndex == 0){
            self.updateLocation()
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
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
        
        // Låser vyn
        UIApplication.shared.beginIgnoringInteractionEvents()
        stopService.getStopsByInput(searchBar.text!, onSuccess: { json -> Void in
            DispatchQueue.main.async(execute: {
                self.stops = json
                self.lines = DbService.sharedInstance.getLines()
                if (self.stops.count > 0){
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
    
    func updateLocation(){
        print(horizontalAccuracy)
        if horizontalAccuracy <= 50{
            stops = cached
            tableView.reloadData()
            locationManager.stopUpdatingLocation()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!lat.isEmpty && !long.isEmpty){
            return
        }
        if Reachability.isConnectedToNetwork() != true {
            stops = [Stop]()
            return
        }
        
        lat = manager.location!.coordinate.latitude
        long = manager.location!.coordinate.longitude
        getNearestStops()
    }
    

    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        display("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.", type: Error.location)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return stops.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let currentStop = stops[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        
        cell.addGestureRecognizer(lpgr)
        
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        for view in cell.subviews{
            if(view.isKind(of: UILabel.self)){
                view.removeFromSuperview()
            }
        }
        
        let name = UILabel(frame: CGRect(x: 15, y: 8, width: DeviceHelper.labelWidth(), height: 30))
        name.textAlignment = NSTextAlignment.left
        name.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        name.text = stops[(indexPath as NSIndexPath).row].name
        name.font = name.font.withSize(16)
        
        cell.addSubview(name)
        
        if((indexPath as NSIndexPath).row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        // Rensar all checkboxar
        for view in cell.subviews{
            if (String(describing: type(of: view)) == "UIImageView") {
                view.removeFromSuperview()
            }
        }
        
        if (!lines.filter{$0.stopId == currentStop.id}.isEmpty){
            let imageName = "check-red"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: deviceHelper.screenWidth - 70, y: 12, width: Int(imageView.image?.size.width ?? 16), height: Int(imageView.image?.size.height ?? 16))
            cell.addSubview(imageView)
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
        if (segue.identifier == "ShowLinesView")
        {
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
