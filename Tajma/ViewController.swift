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
    
    var webView = UIWebView()
    var btnCloseWebView  = UIButton()
    
    let lineService = LineService()
    var stopService = StopsService()
    var lineWrapper = LineWrapper()
    var stopWrapper = StopWrapper()
    let phoneSize = PhoneSize()
        
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    var lat : String = ""
    var long : String = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        searchBar!.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        
        self.title = "Bakåt"
        
        // Förstagångsguide som öppnas första gången appen öppnas
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
        
        // Rate
        let rate = RateMyApp.sharedInstance
        rate.appID = "689392780"
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rate.trackAppUsage()
        })

    }
    
    override func viewDidAppear(animated: Bool) {
        lineWrapper = LineWrapper()
        
        self.navigationController?.navigationBar.layer.zPosition = 1

        navigationController?.navigationBar.barStyle = UIBarStyle.Default
        navigationController?.navigationBar.tintColor = UIColor(red: 240/255, green: 80/255, blue: 80/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 240/255, green: 80/255, blue: 80/255, alpha: 0)]
        
        navigationController?.navigationBar.hidden = true
        
        tableView.reloadData()
    }
 
    // MARK: - Functions
    func initiateViews(){
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // NavController
        navController.backgroundColor = UIColor(red: 45/255, green: 137/255, blue: 239/255, alpha: 1)
          
        // SearchBar
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        searchBar.setImage(UIImage(named: "search-white"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchBar.tintColor = UIColor(red: 32/255, green: 106/255, blue: 196/255, alpha: 1)
        
        let textfield:UITextField = searchBar.valueForKey("searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textfield.attributedPlaceholder = attributedString
        
        // TableView
        tableView.separatorColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        // Activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        self.view.addSubview(activityIndicator)
        
        // För att sätta bakgrundfärg och opacitet på placeholdertext för searchBar
        let txt:UITextField = searchBar.valueForKey("searchField") as! UITextField
        
        let attR = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        
        txt.attributedPlaceholder = attR
        
        // SegmentedControl
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.layer.borderColor = UIColor(red: 45/255, green: 137/255, blue: 239/255, alpha: 1).CGColor
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.backgroundColor = UIColor(red: 32/255, green: 106/255, blue: 196/255, alpha: 1)
    }
    
    func closeWebView(sender: UIButton!){
        btnCloseWebView.removeFromSuperview()
        webView.removeFromSuperview()
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
                    // init
                    //let stop = Stop(id: "0", name: "Fel vid hämtning. Hämta igen.", lat: "0", long: "0", distance: -200, departures: nil)
                    
                    let stop = Stop()
                    stop.id = "0"
                    stop.name = "Fel vid hämtning. Hämta igen."
                    stop.lat = "0"
                    stop.long = "0"
                    stop.distance = -200
                    stop.departures = nil
                    
                    if (self.stopWrapper.stops.isEmpty){
                        self.stopWrapper.stops.append(stop)
                        self.tableView!.reloadData()
                    }
                    // Om true, så har vi gått från att försöka ladda om vid fel till att försöka hämta igen men fel igen
                    else if (self.stopWrapper.stops[0].id != "0" && self.stopWrapper.stops[0].distance != -200){
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
    
    // MARK: - Events
    @IBAction func segmentedControl_Changed(sender: UISegmentedControl) {
        if (segmentedControl.selectedSegmentIndex == 0){
            self.locationManager.startUpdatingLocation()
            getNearestStops()
            self.segmentedControl.setTitle("Nära mig", forSegmentAtIndex: 0)
            searchBar.resignFirstResponder()
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
            stopWrapper.stops = RealmService.sharedInstance.getStops()
        }
        
        tableView.reloadData()
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // För att uppdatera listan över tillagda stopp
        if (parent != nil) {
            if (segmentedControl.selectedSegmentIndex == 1){
                var tempStops : [Stop]
                tempStops = RealmService.sharedInstance.getStops()
                
                if (tempStops.count != stopWrapper.stops.count){
                    stopWrapper.stops = RealmService.sharedInstance.getStops()
                    tableView.reloadData()
                }
            }
            
        }
        else{
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (searchBar.text!.characters.count == 0){
            searchBar.resignFirstResponder()
            return
        }
        let stop = StopsService()
        
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        stop.getStopsByInput(searchBar.text!, onCompletion: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stopWrapper = json
                if (self.stopWrapper.stops.count > 0){
                    self.searchBar!.text = ""
                    self.segmentedControl.setTitle("Sökresultat", forSegmentAtIndex: 0)
                }
                else{
                    print(self.stopWrapper.error)
                }
                
                self.tableView!.reloadData()
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        })
        
        searchBar.resignFirstResponder()
        
    }

    // MARK: - Location Manager
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                print("Error: " + error!.localizedDescription)
                self.getNearestStops()
                return
            }
            if (placemarks!.count > 0){
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            }
            else{
                print("Error with location data")
            }
        })
    }
    
    func displayLocationInfo (placemark : CLPlacemark){
        // Vi har en location, behöver inte titta mer
        self.locationManager.stopUpdatingLocation()
        
        lat = String(stringInterpolationSegment: placemark.location!.coordinate.latitude)
        long = String(stringInterpolationSegment: placemark.location!.coordinate.longitude)
        
        getNearestStops()
        tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Vi fick ett fel och kunde inte hämta location, visa felmeddelande i app.
        print("Error: " + error.localizedDescription)
        
        stopWrapper.stops = [Stop]()
        
        // init
        //let stop = Stop(id: "0", name: "Fel vid hämtning. Hämta igen.", lat: "0", long: "0", distance: -200, departures: nil)
        
        let stop = Stop()
        stop.id = "0"
        stop.name = "Fel vid hämtning. Hämta igen."
        stop.lat = "0"
        stop.long = "0"
        stop.distance = -200
        stop.departures = nil
        
        self.stopWrapper.stops.append(stop)
        self.tableView!.reloadData()
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return stopWrapper.stops.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        
        // Sätta bakgrunden på tableView
        if (indexPath.row == stopWrapper.stops.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
            
            if (indexPath.row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            }
        }
        
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        for view in cell.subviews{
            if (String(view.dynamicType) == "UIImageView") {
                view.removeFromSuperview()
            }
        }
        
        // Kunde inte ladda närmaste stopp
        if (stopWrapper.stops[indexPath.row].id == "0" && stopWrapper.stops[indexPath.row].distance == -200){
            cell.textLabel!.text = stopWrapper.stops[indexPath.row].name
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            return cell
        }
        
        var myStops = RealmService.sharedInstance.getStopsId()
        
        if (myStops.contains(stopWrapper.stops[indexPath.row].id)){
            let imageName = "check-red"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: phoneSize.width - 70, y: 12, width: Int(imageView.image?.size.width ?? 16), height: Int(imageView.image?.size.height ?? 16))
            
            cell.addSubview(imageView)
            
        }
    
        cell.textLabel!.text = stopWrapper.stops[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        searchBar.resignFirstResponder()
        // Hämta om närmaste stopp
        if (stopWrapper.stops[indexPath.row].id == "0" && stopWrapper.stops[indexPath.row].distance == -200){
            getNearestStops()
        }
        // Hämta linjer på stopp
        else{
            getLinesAtStop(stopWrapper.stops[indexPath.row].id, indexPath: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Remove seperator inset
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force your tableview margins (this may be a bad idea)
        if self.tableView.respondsToSelector("setSeparatorInset:") {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if self.tableView.respondsToSelector("setLayoutMargins:") {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "ShowLinesView")
        {
            let row : Int = sender as! Int
            //let stop = Stop(id: stopWrapper.stops[row].id, name: stopWrapper.stops[row].name, lat: stopWrapper.stops[row].lat, long: stopWrapper.stops[row].long, distance: 0, departures: nil)
            
            let stop = Stop()
            stop.id = stopWrapper.stops[row].id
            stop.name = stopWrapper.stops[row].name
            stop.lat = stopWrapper.stops[row].lat
            stop.long = stopWrapper.stops[row].long
            stop.distance = -200
            stop.departures = nil
            
            let lines = segue.destinationViewController as! LinesViewController
            lines.lineWrapper.lines = lineWrapper.lines
            lines.stop = stop
            lineService.getUserLinesAtStop(stop.id)
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}