//
//  LinesViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-31.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class LinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var lines = [Line]()
    var stop : Stop!
    let deviceHelper = DeviceHelper()
    let departureService = DepartureService()
    let lineService = LineService()
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initiateViews()
        activityIndicator.startAnimating()
        updateMyLines()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?){
        super.willMove(toParentViewController: parent)
        if parent == nil {
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
    }
    
    func initiateViews(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        let title = UILabel(frame: CGRect(x: 0, y: 7, width: 200, height: 30))
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor.white
        title.text = stop.name.components(separatedBy: ",").first
        title.font = title.font.withSize(17)
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = titleView
        titleView.addSubview(title)
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        activityIndicator.center = CGPoint(x: (self.view.frame.width)/2, y: (self.view.frame.height)/3)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.color = UIColor.gray
        self.view.addSubview(activityIndicator)
    }
    
    func updateLines(){
        // Låser vyn
        UIApplication.shared.beginIgnoringInteractionEvents()
        departureService.getAllDeparturesFromStop(stop.id, onSuccess: { lines -> Void in
            DispatchQueue.main.async(execute: {
                self.lines = lines
                self.tableView.reloadData()
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            }, onError:{ error -> Void in
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Tajma", message: "Kan inte hämta linjer, försök igen senare.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (alert) -> Void in
                        self.navigationController!.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
        })
    }
    
    func updateMyLines(){
        stop.lines = DbService.sharedInstance.getLinesAtStop(stop.id)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count + 1
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
        
        let currentLine = lines[(indexPath as NSIndexPath).row - 1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineCell
        cell.selectionStyle = .none
        
        if(stop.lines.filter({$0.id == currentLine.id}).isEmpty){
            cell.checkbox.image = UIImage(named: "unchecked-box")
        }
        else{
            cell.checkbox.image = UIImage(named: "check-box-red")
        }
        
        var sname = ""
        if ((Int(currentLine.sname.substring(to: currentLine.sname.characters.index(currentLine.sname.startIndex, offsetBy: 1)))) == nil){
            let snameArr = Array(currentLine.sname.characters)
            sname = String(snameArr[0]) + String(snameArr[1]) + String(snameArr[2])
            cell.snameLabel.font = cell.snameLabel.font.withSize(12)
        }
        else if (currentLine.sname.characters.count > 2){
            sname = currentLine.sname
            cell.snameLabel.font = cell.snameLabel.font.withSize(12)
        }
        else{
            sname = currentLine.sname
        }
        
        cell.snameLabel.text = sname
        cell.snameLabel.textColor = UIColor(rgba: currentLine.bgColor)
        cell.snameView.backgroundColor = UIColor(rgba: currentLine.fgColor)
        cell.directionLabel.text = "\(currentLine.direction)"
        for (index, departure) in currentLine.departures.times.enumerated() {
            if index == 0 {
                if departure < 1 {
                    cell.firstDeparture.text = "Nu"
                }
                else {
                    cell.firstDeparture.text = String(departure)
                }
            }
            else if index == 1 {
                if departure < 1 {
                    cell.secondDeparture.text = "Nu"
                }
                else {
                    cell.secondDeparture.text = String(departure)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as! LineCell
        let currentLine = lines[(indexPath as NSIndexPath).row]
        currentLine.stopId = stop.id
        if (stop.lines.filter({$0.id == currentLine.id}).isEmpty){
            DbService.sharedInstance.addLine(currentLine, stop: stop)
            cell.checkbox.image = UIImage(named: "check-box-red")
        }
        else{
            DbService.sharedInstance.removeLine(currentLine, stopId: stop.id)
            cell.checkbox.image = UIImage(named: "unchecked-box")

        }
        updateMyLines()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 28
        }
        else {
            return 44
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        activityIndicator.stopAnimating()
//        
////        if indexPath.row <= 0 && indexPath.section == 0 {
////            self.navigationController?.hidesBarsOnSwipe = false
////            self.navigationController?.setNavigationBarHidden(false, animated: true)
////        }
////        else {
////            self.navigationController?.hidesBarsOnSwipe = true
////        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
