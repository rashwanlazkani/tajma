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
    
    let dbService = DBService()
    let lineService = LineService()
    var stopService = StopsService()
    var lineWrapper = LineWrapper()
    var stopWrapper = StopWrapper()
    let phoneSize = PhoneSize()
        
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var lat : String = ""
    var long : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        dbService.addTablesIfNotExists()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        searchBar!.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        
        self.title = "Bakåt"
    }
    
    override func viewDidAppear(animated: Bool) {
        lineWrapper = LineWrapper()
        navigationController?.navigationBar.hidden = true
        tableView.reloadData()
    }
 
    // MARK: - Functions
    func initiateViews(){
        // Gradient view
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 9/255, green: 128/255, blue: 129/255, alpha: 1).CGColor, UIColor(red: 72/255, green: 174/255, blue: 151/255, alpha: 1).CGColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, navController.frame.size.height)
        navController.layer.insertSublayer(gradient, atIndex: 0)
        
        // SearchBar
        var textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        searchBar.setImage(UIImage(named: "SearchWhite"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal);
        
        var textfield:UITextField = searchBar.valueForKey("searchField") as! UITextField
        var attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textfield.attributedPlaceholder = attributedString
        
        // TableView
        tableView.separatorColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 1)
        
        // Activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        self.view.addSubview(activityIndicator)

    }
    
    func getNearestStops() {
        stopService.getNearestStops(lat, long: long, onCompletion: { json -> Void in
            self.activityIndicator.startAnimating()
            dispatch_async(dispatch_get_main_queue(),{
                self.stopWrapper = json
                if (self.stopWrapper.stops.count > 0){
                    self.tableView!.reloadData()
                }
                else{
                    println(self.stopWrapper.error)
                }
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
                    println(self.lineWrapper.error)
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
            getNearestStops()
            searchBar.resignFirstResponder()
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
            stopWrapper.stops = dbService.getStops()
        }
        
        tableView.reloadData()
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // För att uppdatera listan över tillagda stopp
        if (parent != nil) {
            if (segmentedControl.selectedSegmentIndex == 1){
                var tempStops : [Stop]
                tempStops = dbService.getStops()
                
                if (tempStops.count != stopWrapper.stops.count){
                    stopWrapper.stops = dbService.getStops()
                    tableView.reloadData()
                }
            }
            
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (count(searchBar.text) == 0){
            return
        }
        var stop = StopsService()
        
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        stop.getStopsByInput(searchBar.text, onCompletion: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.stopWrapper = json
                if (self.stopWrapper.stops.count > 0){
                    self.searchBar!.text = ""
                }
                else{
                    println(self.stopWrapper.error)
                }
                
                self.tableView!.reloadData()
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        })
        
        searchBar.resignFirstResponder()
        
    }
    
    @IBAction func infoButton_Clicked(sender: UIButton) {
        //self.performSegueWithIdentifier("ShowInfoView", sender: nil)
    }
    
    // MARK: - Location Manager
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                println("Error: " + error.localizedDescription)
                return
            }
            if (placemarks.count > 0){
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }
            else{
                println("Error with location data")
            }
        })
    }
    
    func displayLocationInfo (placemark : CLPlacemark){
        // Vi har en location, behöver inte titta mer
        self.locationManager.stopUpdatingLocation()
        
        lat = String(stringInterpolationSegment: placemark.location.coordinate.latitude)
        long = String(stringInterpolationSegment: placemark.location.coordinate.longitude)
        
        getNearestStops()
        tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
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
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        for view in cell!.subviews{
            if (toString(view.dynamicType) == "UIImageView") {
                view.removeFromSuperview()
            }
        }
        
        if (segmentedControl.selectedSegmentIndex == 0){
            var myStops = dbService.getStopsId()
            
            if (contains(myStops, stopWrapper.stops[indexPath.row].id)){
                let imageName = "darkcheck"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                imageView.frame = CGRect(x: phoneSize.width - 70, y: 12, width: 16, height: 16)
                
                cell?.addSubview(imageView)
                
            }
        }
        
        /*
        if(indexPath.row % 2 == 0){
            cell!.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
        } else{
            cell!.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
        }
        */
        cell!.textLabel!.text = stopWrapper.stops[indexPath.row].name
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        // Sätta bakgrunden på tableView
        /*
        if (indexPath.row == stopWrapper.stops.count - 1){
           tableView.tableFooterView = UIView(frame: CGRectZero)
            
            if (indexPath.row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
            }
        }
        */
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        getLinesAtStop(stopWrapper.stops[indexPath.row].id, indexPath: indexPath.row)
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "ShowLinesView")
        {
            var row : Int = sender as! Int
            var stop = Stop(id: stopWrapper.stops[row].id, name: stopWrapper.stops[row].name, lat: stopWrapper.stops[row].lat, long: stopWrapper.stops[row].long, distance: 0, departures: nil)
            
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

