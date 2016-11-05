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
    let lineService = LineService()
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    override func viewDidLoad(){
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        updateMyLines()
        tableView.delegate = self
        tableView.dataSource = self
        initiateViews()
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
        title.font = UIFont.boldSystemFont(ofSize: 20)
        
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
        activityIndicator.startAnimating()
        // Låser vyn
        UIApplication.shared.beginIgnoringInteractionEvents()
        lineService.getAllLinesAtStop(stop.id, onSuccess: { json -> Void in
            DispatchQueue.main.async(execute: {
                self.lines = json
                self.tableView.reloadData()
            })
            DispatchQueue.main.async(execute: {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return lines.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let currentLine = lines[(indexPath as NSIndexPath).row]
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none

        for view in cell.subviews{
            if(view.isKind(of: UILabel.self) || view.isKind(of: UIImage.self) || view.isKind(of: UIView.self)){
                view.removeFromSuperview()
            }
        }
        
        var image = UIImage(named: "unchecked-box")
        if(stop.lines.filter({$0.id == currentLine.id}).isEmpty){
            cell.backgroundColor = UIColor.clear
        }
        else{
            image = UIImage(named: "check-box-red")
            cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
        }
        
        let checkbox = UIImageView(image: image!)
        checkbox.frame = CGRect(x: 50, y: 50, width: 28, height: 28)
        checkbox.center = CGPoint(x: tableView.bounds.width - 25, y: 44 / 2.0)
        
        var fontSize = CGFloat(16)
        var sname = ""
        if ((Int(currentLine.sname.substring(to: currentLine.sname.characters.index(currentLine.sname.startIndex, offsetBy: 1)))) == nil){
            fontSize = CGFloat(12)
            let snameArr = Array(currentLine.sname.characters)
            sname = String(snameArr[0]) + String(snameArr[1]) + String(snameArr[2])
        }
        else if (currentLine.sname.characters.count > 2){
            fontSize = CGFloat(12)
            sname = currentLine.sname
        }
        else{
            sname = currentLine.sname
        }
        
        let snameView = UIView()
        snameView.frame = CGRect(x: 30, y: 30, width: 30, height: 30)
        snameView.layer.cornerRadius = 5
        snameView.center = CGPoint(x: 25, y: 23)
        snameView.backgroundColor = UIColor(rgba: currentLine.fgColor)
        
        let snameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        snameLabel.textAlignment = NSTextAlignment.center
        snameLabel.text = sname
        snameLabel.textColor = UIColor(rgba: currentLine.bgColor)
        snameLabel.font = snameLabel.font.withSize(fontSize)
        
        let directionLabel = UILabel(frame: CGRect(x: 0, y: 8, width: DeviceHelper.labelWidth() + 40, height: 30))
        directionLabel.textAlignment = NSTextAlignment.left
        directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        directionLabel.text = "\t     \(currentLine.direction)"
        directionLabel.font = directionLabel.font.withSize(16)
        
        let separator = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: cell.frame.width, height: 0.5))
        separator.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        snameView.addSubview(snameLabel)
        cell.addSubview(checkbox)
        cell.addSubview(snameView)
        cell.addSubview(directionLabel)
        cell.addSubview(separator)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let currentLine = lines[(indexPath as NSIndexPath).row]
        currentLine.stopId = stop.id
        if (stop.lines.filter({$0.id == currentLine.id}).isEmpty){
            DbService.sharedInstance.addLine(currentLine, stop: stop)
        }
        else{
            DbService.sharedInstance.removeLine(currentLine, stopId: stop.id)
        }
        updateMyLines()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        activityIndicator.stopAnimating()
        
//        if indexPath.row <= 0 && indexPath.section == 0 {
//            self.navigationController?.hidesBarsOnSwipe = false
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//        else {
//            self.navigationController?.hidesBarsOnSwipe = true
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
