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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var lines = [Line]()
    var stop : Stop!
    let deviceHelper = Device()
    let departureService = DepartureService()
    let lineService = LineService()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        updateUserLines()
        
        activityIndicator.startAnimating()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.title = stop.name.components(separatedBy: ",").first
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLines), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        updateLines()
    }
    
    @objc func updateLines(){
        activityIndicator.startAnimating()
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
                    let alert = UIAlertController(title: "Tajma", message: "Inga avgångar för tillfället på denna hållplats, försök igen senare.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (alert) -> Void in
                        self.navigationController!.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
        })
    }
    
    func updateUserLines() {
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
        
        if stop.lines.filter({$0.id == currentLine.id}).isEmpty {
            cell.checkbox.image = UIImage(named: "unchecked-box")
        } else {
            cell.checkbox.image = UIImage(named: "check-box-red")
        }
        
        var sname = ""
        if (Int(currentLine.sname.substring(to: currentLine.sname.index(currentLine.sname.startIndex, offsetBy: 1)))) == nil {
            let snameArr = Array(currentLine.sname)
            sname = String(snameArr[0]) + String(snameArr[1]) + String(snameArr[2])
            cell.snameLabel.font = cell.snameLabel.font.withSize(12)
        } else if currentLine.sname.count > 2 {
            sname = currentLine.sname
            cell.snameLabel.font = cell.snameLabel.font.withSize(12)
        } else {
            sname = currentLine.sname
        }
        
        cell.snameLabel.text = sname
        cell.snameLabel.textColor = UIColor(hex: currentLine.bgColor)
        cell.snameView.backgroundColor = UIColor(hex: currentLine.fgColor)

        cell.directionLabel.text = "\(currentLine.direction)"
        for (index, departure) in currentLine.departures.times.enumerated() {
            if index == 0 {
                if departure < 1 {
                    cell.firstDeparture.text = "Nu"
                } else {
                    cell.firstDeparture.text = String(departure)
                }
            } else if index == 1 {
                if departure < 1 {
                    cell.secondDeparture.text = "Nu"
                } else {
                    cell.secondDeparture.text = String(departure)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! LineCell
        let currentLine = lines[(indexPath as NSIndexPath).row - 1]
        currentLine.stopId = stop.id
        if stop.lines.filter({$0.id == currentLine.id}).isEmpty {
            DbService.sharedInstance.addLine(currentLine, stop: stop)
            cell.checkbox.image = UIImage(named: "check-box-red")
        } else {
            DbService.sharedInstance.removeLine(currentLine, stopId: stop.id)
            cell.checkbox.image = UIImage(named: "unchecked-box")
        }
        updateUserLines()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 28
        } else {
            return 44
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
         _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
