//
//  ViewController.swift
//  Kollektiv
//
//  Created by Rashwan Lazkani on 2015-05-30.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet var navController: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let lineService = LineService()
    var stopService = StopsService()
    var lineWrapper = LineWrapper()
    var stopWrapper = StopWrapper()
    let deviceHelper = DeviceHelper()
    
    var webView = UIWebView()
    var btnCloseWebView  = UIButton()
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    var lat : String = ""
    var long : String = ""
    
    override func viewDidAppear(animated: Bool) {
        initiateViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        checkForFirstTimeLaunch()
        initiateViews()
        setRateSettings()
    }
 
    // MARK: - Functions
    func checkForFirstTimeLaunch(){
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if !firstLaunch  {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            
            webView = UIWebView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.tajmahelpappwebsite.rashwanlazkani.se/")!))
            
            btnCloseWebView = UIButton(frame: CGRectMake(view.bounds.width - 100,view.bounds.height - 45, 80, 40))
            btnCloseWebView.backgroundColor = UIColor.clearColor()
            btnCloseWebView.setTitle("Stäng", forState: UIControlState.Normal)
            btnCloseWebView.addTarget(self, action: "closeWebView:", forControlEvents: .TouchUpInside)
            btnCloseWebView.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            btnCloseWebView.titleLabel?.textAlignment = NSTextAlignment.Left
            btnCloseWebView.backgroundColor = UIColor.grayColor()
            btnCloseWebView.layer.cornerRadius = 5
            
            view.addSubview(webView)
            view.addSubview(btnCloseWebView)
        }
    }
    
    func closeWebView(sender: UIButton!){
        btnCloseWebView.removeFromSuperview()
        webView.removeFromSuperview()
    }
    
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
        searchBar.tintColor = UIColor(red: 32/255, green: 106/255, blue: 196/255, alpha: 1)
        let textfield:UITextField = searchBar.valueForKey("searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textfield.attributedPlaceholder = attributedString
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        activityIndicator.center = self.view.center
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
        rate.appID = "689392780"
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rate.trackAppUsage()
        })
    }
    
    func getNearestStops() {
        self.activityIndicator.startAnimating()
        self.segmentedControl.enabled = false
        stopService.getNearestStops(lat, long: long, onCompletion: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stopWrapper = json
                if (self.stopWrapper.stops.count > 0){
                    self.tableView!.reloadData()
                }
                else{
                    let stop = Stop()
                    stop.name = "Fel vid hämtning. Hämta igen."
                    stop.status = Status.Error
                    
                    if (self.stopWrapper.stops.isEmpty || self.stopWrapper.stops[0].status == Status.Error){
                        self.stopWrapper.stops.append(stop)
                        self.tableView!.reloadData()
                    }
                    
                    print(self.stopWrapper.error)
                }
                self.locationManager.stopUpdatingLocation()
                self.segmentedControl.enabled = true
                self.activityIndicator.stopAnimating()
            })
        })
        
    }
    
    func getLinesAtStop(stopId : String, indexPath : Int){
        activityIndicator.startAnimating()
        // Låser vyn
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        lineService.getAllLinesAtStop(stopId, onCompletion: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.lineWrapper = json
                if (self.lineWrapper.lines.count > 0){
                    
                    self.performSegueWithIdentifier("ShowLinesView", sender: indexPath)
                }
                else{
                    print(self.lineWrapper.error)
                }
            })
            dispatch_async(dispatch_get_main_queue(),{
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        })
    }
    
    func addIsChecked(){
        for stop in stopWrapper.stops{
            stop.isChecked = stopService.checkIfUserHasAddedStop(stop).isChecked
        }
    }
    
    // MARK: - Events
    override func didMoveToParentViewController(parent: UIViewController?) {
        // För att uppdatera listan över tillagda stopp när man kommer från linesViewn
        if (segmentedControl.selectedSegmentIndex == 1){
            stopWrapper.stops = RealmService.sharedInstance.getStops()
        }
        else{
            addIsChecked()
        }
        tableView.reloadData()
    }
    
    @IBAction func segmentedControl_Changed(sender: UISegmentedControl) {
        if (segmentedControl.selectedSegmentIndex == 0){
            self.locationManager.startUpdatingLocation()
            self.segmentedControl.setTitle("Nära mig", forSegmentAtIndex: 0)
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
            stopWrapper.stops = RealmService.sharedInstance.getStops()
        }
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        segmentedControl.selectedSegmentIndex = 0
        activityIndicator.startAnimating()
        
        // Låser vyn
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        stopService.getStopsByInput(searchBar.text!, onCompletion: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stopWrapper = json
                if (self.stopWrapper.stops.count > 0){
                    self.segmentedControl.setTitle("Sökresultat", forSegmentAtIndex: 0)
                }
                else{
                    print(self.stopWrapper.error)
                }
                searchBar.resignFirstResponder()
                self.tableView!.reloadData()
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        })
    }

    // MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        lat = String(location.latitude)
        long = String(location.longitude)
        locationManager.stopUpdatingLocation()
        getNearestStops()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user´s location: \(error.localizedDescription)")
        
        stopWrapper.stops = [Stop]()
        
        let stop = Stop()
        stop.name = "Fel vid hämtning. Hämta igen."
        stop.status = Status.Error
        
        self.stopWrapper.stops.append(stop)
        self.tableView!.reloadData()
    }

    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return stopWrapper.stops.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel!.text = stopWrapper.stops[indexPath.row].name
        
        if (stopWrapper.stops[indexPath.row].status == Status.Error){
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            return cell
        }
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        // Sätter bakgrunden på tableView för att inte visa tomma rader
        if (indexPath.row == stopWrapper.stops.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
            
            if (indexPath.row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            }
        }
        
        // Rensar all checkboxar
        for view in cell.subviews{
            if (String(view.dynamicType) == "UIImageView") {
                view.removeFromSuperview()
            }
        }
        
        if (stopWrapper.stops[indexPath.row].isChecked){
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
        if (stopWrapper.stops[indexPath.row].status == Status.Error){
            getNearestStops()
        }
        else{
            getLinesAtStop(stopWrapper.stops[indexPath.row].id, indexPath: indexPath.row)
        }
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "ShowLinesView")
        {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            let row : Int = sender as! Int
            let stop = Stop()
            stop.id = stopWrapper.stops[row].id
            stop.name = stopWrapper.stops[row].name
            stop.lat = stopWrapper.stops[row].lat
            stop.long = stopWrapper.stops[row].long
            
            let lines = segue.destinationViewController as! LinesViewController
            lines.lineWrapper.lines = lineWrapper.lines
            lines.stop = stop
            RealmService.sharedInstance.getLinesAtStop(stop.id)
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}