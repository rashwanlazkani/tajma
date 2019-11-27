//
//  LinesViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-31.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class LinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var lines = [Line]()
    var stop: Stop!
    let webService = WebService()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
                self.navigationView.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        titleLabel.text = stop.name.components(separatedBy: ",").first
        
        updateUserLines()
        
        activityIndicator.startAnimating()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.title = stop.name.components(separatedBy: ",").first
        NotificationCenter.default.addObserver(self, selector: #selector(updateLines), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateLines()
    }
    
    @objc private func updateLines(){
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        webService.getDeparturesAt(stop.id, onCompletion: { (lines) in
            self.lines = lines
            self.tableView.reloadData()
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }) { (error) in
           let alert = UIAlertController(title: "Tajma", message: "Inga avgångar för tillfället på denna hållplats, försök igen senare.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (alert) -> Void in
                self.navigationController!.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    private func updateUserLines() {
        stop.lines = DbService.shared.getLinesAtStop(stop.id)
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
        
        let currentLine = lines[indexPath.row - 1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineCell
        cell.selectionStyle = .none
        
        if stop.lines.firstOrDefault({ $0.id == currentLine.id }) == nil {
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
        
        for (index, departure) in currentLine.departures.enumerated() {
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let cell = tableView.cellForRow(at: indexPath) as! LineCell
        let currentLine = lines[indexPath.row - 1]
        currentLine.stopid = stop.id
        if stop.lines.filter({$0.id == currentLine.id}).isEmpty {
            DbService.shared.addLine(currentLine, stop: stop)
            cell.checkbox.image = UIImage(named: "check-box-red")
        } else {
            DbService.shared.removeLine(currentLine, stopId: stop.id)
            cell.checkbox.image = UIImage(named: "unchecked-box")
        }
        updateUserLines()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 28 : 44
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
