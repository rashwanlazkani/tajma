//
//  ViewController.swift
//  Kollektiv
//
//  Created by Rashwan Lazkani on 2015-05-30.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import CoreLocation
import SINQ

class StopsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet var navController: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let lineService = LineService()
    var stopService = StopsService()
    let deviceHelper = DeviceHelper()
    var stops = [Stop]()
    var lines = [Line]()
    
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    var lat : String = ""
    var long : String = ""
    
    let guideController = GuideController()
    
    override func viewDidAppear(animated: Bool) {
        initiateViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let loadData = NSUserDefaults(suiteName: "group.tajma.today")!.boolForKey("LoadData")
        if(!loadData){
            self.performSegueWithIdentifier("ShowGuide", sender: nil)
            NSUserDefaults(suiteName: "group.tajma.today")!.setBool(true, forKey: "LoadData")
        }
        else{
            self.locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
            self.title = "Bakåt"
            
            searchBar!.delegate = self
            tableView.delegate = self
            tableView.dataSource = self
            
            initiateViews()
            setRateSettings()
            
            lines = SqliteService.sharedInstance.getLines()
        }
    }
    
    // MARK: - Functions
    func initiateViews(){
        self.view.backgroundColor = UIColor.whiteColor()
        
        navController.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        self.navigationController?.navigationBar.layer.zPosition = 1
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.tintColor = UIColor(red: 240/255, green: 80/255, blue: 80/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 240/255, green: 80/255, blue: 80/255, alpha: 0)]
        navigationController?.navigationBar.hidden = true
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        searchBar.setImage(UIImage(named: "search-white"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchBar.setImage(UIImage(named: "erase"), forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal)
        searchBar.tintColor = UIColor.whiteColor()
        let textfield:UITextField = searchBar.valueForKey("searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textfield.attributedPlaceholder = attributedString
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        activityIndicator.center = CGPoint(x: (self.view.frame.width)/2, y: (self.view.frame.height)/3)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        self.view.addSubview(activityIndicator)
        
        // För att sätta bakgrundfärg och opacitet på placeholdertext för searchBar
        let txt:UITextField = searchBar.valueForKey("searchField") as! UITextField
        let attr = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        txt.attributedPlaceholder = attr
        
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1).CGColor
        segmentedControl.backgroundColor = UIColor(red: 210/255, green: 43/255, blue: 69/255, alpha: 0.75)
    }
    
    func setRateSettings(){
        let rate = RateMyApp.sharedInstance
        rate.appID = Constants.AppId
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rate.trackAppUsage()
        })
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        self.segmentedControl.selectedSegmentIndex = 0
        locationManager.startUpdatingLocation()
        lat = ""
        long = ""
    }
    
    func getNearestStops() {
        self.activityIndicator.startAnimating()
        self.segmentedControl.enabled = false
        stopService.getNearestStops(lat, long: long, onSuccess: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stops = json
                if (self.stops.count == 0){
                    self.displayError("Inga hållplatser i närheten.", type: Error.Nearest)
                }
                self.tableView!.reloadData()
                
                self.locationManager.stopUpdatingLocation()
                self.segmentedControl.enabled = true
                self.activityIndicator.stopAnimating()
            })
            }, onError:{ error -> Void in
                self.displayError("Ett fel har uppstått med hämtning av närmaste hållplatser.", type: Error.Location)
        })
    }
    
    func displayError(error: String, type: Error){
        let alert = UIAlertController(title: "Tajma", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Försök igen", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
            switch type {
            case Error.Location :
                return self.locationManager.startUpdatingLocation()
            case Error.Nearest :
                return self.getNearestStops()
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Events
    override func didMoveToParentViewController(parent: UIViewController?) {
        // För att uppdatera listan över tillagda stopp när man kommer från linesViewn
        if (segmentedControl.selectedSegmentIndex == 1){
            stops = SqliteService.sharedInstance.getStops()
        }
        lines = SqliteService.sharedInstance.getLines()
        tableView.reloadData()
    }
    
    @IBAction func segmentedControl_Changed(sender: UISegmentedControl) {
        if (segmentedControl.selectedSegmentIndex == 0){
            lat = ""
            long = ""
            self.locationManager.startUpdatingLocation()
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
            stops = SqliteService.sharedInstance.getStops()
        }
        self.segmentedControl.setTitle("Nära mig", forSegmentAtIndex: 0)
        self.searchBar.text = ""
        lines = SqliteService.sharedInstance.getLines()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        segmentedControl.selectedSegmentIndex = 0
        activityIndicator.startAnimating()
        
        // Låser vyn
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        stopService.getStopsByInput(searchBar.text!, onSuccess: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stops = json
                self.lines = SqliteService.sharedInstance.getLines()
                if (self.stops.count > 0){
                    self.segmentedControl.setTitle("Sökresultat", forSegmentAtIndex: 0)
                }
                searchBar.resignFirstResponder()
                self.tableView!.reloadData()
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
            }, onError:{ error -> Void in
                self.displayError("Ett fel har uppstått med sökningen.", type: Error.Location)
        })
    }
    
    // MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!lat.isEmpty && !long.isEmpty){
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        displayError("Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.", type: Error.Location)
    }
    
    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return stops.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let currentStop = from(stops).elementAt(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        for view in cell.subviews{
            if(view.isKindOfClass(UILabel)){
                view.removeFromSuperview()
            }
        }
        
        let name = UILabel(frame: CGRectMake(15, 8, DeviceHelper.getLabelWidth() - 35, 30))
        name.textAlignment = NSTextAlignment.Left
        name.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        name.text = stops[indexPath.row].name
        name.font = name.font.fontWithSize(16)
        
        cell.addSubview(name)
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        // Rensar all checkboxar
        for view in cell.subviews{
            if (String(view.dynamicType) == "UIImageView") {
                view.removeFromSuperview()
            }
        }
        
        if (from(lines).any({$0.stopId == currentStop.id})){
            let imageName = "check-red"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: deviceHelper.screenWidth - 70, y: 12, width: Int(imageView.image?.size.width ?? 16), height: Int(imageView.image?.size.height ?? 16))
            cell.addSubview(imageView)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        searchBar.resignFirstResponder()
        self.searchBar!.text = ""
        self.performSegueWithIdentifier("ShowLinesView", sender: stops[indexPath.row])
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if (segue.identifier == "ShowLinesView")
        {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let lines = segue.destinationViewController as! LinesViewController
            lines.stop = sender as! Stop
            lines.updateLines()
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}