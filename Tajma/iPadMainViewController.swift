//
//  iPadViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2020-03-28.
//  Copyright © 2020 Rashwan Lazkani. All rights reserved.
//

import CoreLocation
import StoreKit
import UIKit

class iPadMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var stopsTableViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var linesTableView: UITableView!
    @IBOutlet weak var linesTitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let webService = WebService()
    var selectedStop = Stop()
    var stops = [Stop]()
    var lines = [Line]()
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D()
    var isFromBackground = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        linesTableView.delegate = self
        linesTableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopsTableViewTapped))
        stopsTableView.addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(stopsTableViewSwiped))
        swipeGesture.direction = .right
        stopsTableView.addGestureRecognizer(swipeGesture)
        
        self.navigationView.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)

        DbService.shared.updateOptionals()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        initiateViews()
        
        checkAndAskForReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        
        isFromBackground = false
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        case 1:
            stops = DbService.shared.getStops()
        default:
            break
        }

        lines = DbService.shared.getLines()
        stopsTableView.reloadData()
    }
    
    @objc private func stopsTableViewTapped(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: stopsTableView)
        let path = stopsTableView.indexPathForRow(at: location)
        if let indexPathForRow = path {
            self.tableView(stopsTableView, didSelectRowAt: indexPathForRow)
        } else {
            hideLinesView()
        }
    }
    
    @objc private func stopsTableViewSwiped(recognizer: UISwipeGestureRecognizer) {
        hideLinesView()
    }
    
    // MARK: - Functions
    private func initiateViews() {
        segmentedControlWidthConstraint.constant = self.view.frame.maxX - 48
        stopsTableViewWidthConstraint.constant = self.view.frame.maxX
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        searchBar.setImage(UIImage(named: "search-white"), for: UISearchBar.Icon.search, state: UIControl.State.normal)
        searchBar.setImage(UIImage(named: "erase"), for: UISearchBar.Icon.clear, state: UIControl.State.normal)
        searchBar.tintColor = .white
        let textfield:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        textfield.attributedPlaceholder = attributedString
        
        searchBar.placeholder = "Sök hållplats"
        searchBar.set(textColor: .white)
        searchBar.setPlaceholder(textColor: UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4))
        searchBar.setSearchImage(color: .white)
        
        stopsTableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        stopsTableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        stopsTableView.tableFooterView = UIView()
        
        linesTableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        linesTableView.tableFooterView = UIView()
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .white
            let fontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                 NSAttributedString.Key.foregroundColor: UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)]
            segmentedControl.setTitleTextAttributes(fontAttribute, for: .normal)

        } else {
            segmentedControl.layer.masksToBounds = true
            segmentedControl.layer.cornerRadius = 6
            segmentedControl.layer.borderWidth = 1
            segmentedControl.layer.borderColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1).cgColor
            segmentedControl.backgroundColor = UIColor(red: 210/255, green: 43/255, blue: 69/255, alpha: 0.75)
        }
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)], for: UIControl.State.selected)
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        
        linesTitleLabel.text = ""
    }
    
    private func checkAndAskForReview() {
        let appOpenCount = UserDefaults.standard.integer(forKey: "appOpenCount")
        
        switch appOpenCount {
        case 7,50 :
            SKStoreReviewController.requestReview()
        case _ where appOpenCount % 100 == 0 :
            SKStoreReviewController.requestReview()
        default:
            break
        }
    }

    @objc private func applicationDidBecomeActive(_ application: UIApplication) {
        if isFromBackground {
            self.segmentedControl.selectedSegmentIndex = 0
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func applicationDidEnterBackground(_ application: UIApplication) {
        isFromBackground = true
    }
    
    private func getNearestStops() {
        activityIndicator.startAnimating()
        segmentedControl.isEnabled = false
        
        webService.getStops(location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), onCompletion: { (stops) in
            self.stops = stops
            if self.stops.count == 0 {
                self.display("Inga hållplatser i närheten.", type: .nearest)
            }
            self.stopsTableView.reloadData()
            self.locationManager.stopUpdatingLocation()
            self.segmentedControl.isEnabled = true
            self.activityIndicator.stopAnimating()
        }) { (error) in
            self.display("Ett fel har uppstått med hämtning av närmaste hållplatser.", type: .location)
        }
    }
    
    private func display(_ error: String, type: ErrorType) {
        let alert = UIAlertController(title: "Tajma", message: error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Försök igen", style: .default, handler: { (alert) -> Void in
            switch type {
            case .location :
                return self.locationManager.startUpdatingLocation()
            case .nearest :
                return self.getNearestStops()
            }
        }))
        
        self.segmentedControl.isEnabled = true
        self.activityIndicator.stopAnimating()
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func segmentedControl_Changed(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            location = CLLocationCoordinate2D()
            self.locationManager.startUpdatingLocation()
        case 1:
            let swedish = Locale(identifier: "sv")
            stops = DbService.shared.getStops().sorted(by: { (first, second) -> Bool in
                first.name.compare(second.name, locale: swedish) == .orderedAscending
            })
        default:
            break
        }
        
        segmentedControl.setTitle("Nära mig", forSegmentAt: 0)
        searchBar.text = ""
        lines = DbService.shared.getLines()
        searchBar.resignFirstResponder()
        stopsTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            seachForStop(searchBar.text!)
        } else if searchText.count == 0 {
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            self.view.endEditing(true)
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        } else {
            segmentedControl.selectedSegmentIndex = 0
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            seachForStop(searchBar.text!)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !location.latitude.isZero || !location.longitude.isZero {
            return
        } else if !Reachability.isConnectedToNetwork() {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stopsTableView {
            return stops.count
        } else {
            return lines.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stopsTableView {
            return 44
        } else {
            return indexPath.row == 0 ? 28 : 44
        }
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView == stopsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as! StopCell
            
                cell.name.text = stops[indexPath.row].name
                
                cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1) : UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
                
                cell.checkmark.image = lines.first(where: { $0.stopid == stops[indexPath.row].id }) == nil ? UIImage() : UIImage(named: "check-red")
                
                return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.selectionStyle = .none
                return cell
            }
            
            let currentLine = lines[indexPath.row - 1]
            currentLine.departures.sort(by: { $0 < $1 })
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineCell
            cell.selectionStyle = .none
                
            if selectedStop.lines.firstOrDefault({ $0.id == currentLine.id }) == nil {
                cell.checkbox.image = UIImage(named: "unchecked-box")
            } else {
                cell.checkbox.image = UIImage(named: "check-box-red")
            }
                
            var sname = ""
            switch currentLine.sname.count {
            case 1, 2:
                sname = currentLine.sname
            case 3:
                sname = currentLine.sname
                cell.snameLabel.font = cell.snameLabel.font.withSize(12)
            case 4...:
                sname = String(currentLine.sname.prefix(3))
                cell.snameLabel.font = cell.snameLabel.font.withSize(12)
            default:
                break
            }
        
            cell.snameLabel.text = sname
            cell.snameLabel.textColor = UIColor(hex: currentLine.bgColor)
            cell.snameView.backgroundColor = UIColor(hex: currentLine.fgColor)
            cell.directionLabel.text = "\(currentLine.direction)"
            
            for (index, time) in currentLine.departures.enumerated() {
                if time == 0 {
                    if index == 0 {
                        cell.firstDeparture.text = "Nu"
                    } else if index == 1 {
                        cell.secondDeparture.text = "Nu"
                    }
                } else if index == 0 {
                    cell.firstDeparture.text = time < 0 ? "0" : String(time)
                } else if index == 1 {
                    cell.secondDeparture.text = time < 0 ? "0" : String(time)
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == stopsTableView {
            searchBar.resignFirstResponder()
            searchBar!.text = ""
            selectedStop = stops[indexPath.row]
            updateLines()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            selectedStop = stops[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! LineCell
            let currentLine = lines[indexPath.row - 1]
            currentLine.stopid = selectedStop.id
            if selectedStop.lines.filter({$0.id == currentLine.id}).isEmpty {
                DbService.shared.addLine(currentLine, stop: selectedStop)
                cell.checkbox.image = UIImage(named: "check-box-red")
            } else {
                DbService.shared.removeLine(currentLine, stopId: selectedStop.id)
                cell.checkbox.image = UIImage(named: "unchecked-box")
            }
            updateUserLines()
        }
        
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if segue.identifier == "ShowLinesView" {

            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let lines = segue.destination as! LinesViewController
            lines.stop = sender as? Stop
            
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
        }
    }
    
    private func seachForStop(_ searchText: String) {
        webService.getStops(userInput: searchText, onCompletion: { (stops) in
            self.stops = stops
            self.lines = DbService.shared.getLines()
            
            if self.stops.count > 0 {
                self.segmentedControl.setTitle("Sökresultat", forSegmentAt: 0)
            }
            
            self.stopsTableView.reloadData()
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }) { (error) in
             self.display("Ett fel har uppstått med sökningen.", type: .location)
        }
    }
    
    private func updateLines() {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        webService.getDeparturesAt(selectedStop.id, onCompletion: { (lines) in
            self.lines = lines
            self.linesTableView.reloadData()
            self.linesTitleLabel.text = self.selectedStop.name.components(separatedBy: ",").first
            
            self.segmentedControlWidthConstraint.constant = self.view.frame.midX - 48
            self.stopsTableViewWidthConstraint.constant = self.view.frame.midX
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }) { (error) in
           let alert = UIAlertController(title: "Tajma", message: "Inga avgångar för tillfället på denna hållplats, försök igen senare.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.hideLinesView()
            }))
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    private func updateUserLines() {
        selectedStop.lines = DbService.shared.getLinesAtStop(selectedStop.id)
        linesTableView.reloadData()
    }
    
    private func hideLinesView() {
        self.linesTitleLabel.text = ""
        self.segmentedControlWidthConstraint.constant = self.view.frame.maxX - 48
        self.stopsTableViewWidthConstraint.constant = self.view.frame.maxX
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
