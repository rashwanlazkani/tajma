//
//  LinesViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-31.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import SINQ

class LinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var lines = [Line]()
    var stop : Stop!
    let deviceHelper = DeviceHelper()
    let lineService = LineService()
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad(){
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        updateMyLines()
        tableView.delegate = self
        tableView.dataSource = self
        initiateViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?){
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
    }
    
    func initiateViews(){
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        
        let title = UILabel(frame: CGRectMake(0, 7, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(19)
        title.text = stop.name.componentsSeparatedByString(",").first
        
        let titleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        titleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = titleView
        titleView.addSubview(title)
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        activityIndicator.center = CGPoint(x: (self.view.frame.width)/2, y: (self.view.frame.height)/3)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        self.view.addSubview(activityIndicator)
    }
    
    func updateLines(){
        activityIndicator.startAnimating()
        // Låser vyn
        print("start")
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        lineService.getAllLinesAtStop(stop.id, onSuccess: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.lines = json
                self.tableView.reloadData()
                print("finnish")
            })
            dispatch_async(dispatch_get_main_queue(),{
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
            }, onError:{ error -> Void in
                print(error)
        })
    }
    
    func updateMyLines(){
        stop.lines = SqliteService.sharedInstance.getLinesAtStop(stop.id)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return lines.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let currentLine = from(lines).elementAt(indexPath.row)
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        
        for view in cell.subviews{
            if(view.isKindOfClass(UILabel) || view.isKindOfClass(UIImage) || view.isKindOfClass(UIView)){
                view.removeFromSuperview()
            }
        }
        
        var image = UIImage(named: "unchecked-box")
        if(from(stop.lines).any({$0.id == currentLine.id})){
            image = UIImage(named: "check-box-red")
            cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
        }
        else{
            cell.backgroundColor = UIColor.clearColor()
        }
        
        let checkbox = UIImageView(image: image!)
        checkbox.frame = CGRectMake(50, 50, 28, 28)
        checkbox.center = CGPoint(x: tableView.bounds.width - 25, y: 44 / 2.0)
        
        var fontSize = CGFloat(16)
        var sname = ""
        if ((Int(currentLine.sname.substringToIndex(currentLine.sname.startIndex.advancedBy(1)))) == nil){
            let snameArr = Array(currentLine.sname.characters)
            sname = String(snameArr[0])
        }
        else if (currentLine.sname.characters.count > 2){
            fontSize = CGFloat(12)
            sname = currentLine.sname
        }
        else{
            sname = currentLine.sname
        }
        
        let snameView = UIView()
        snameView.frame = CGRectMake(30, 30, 30, 30)
        snameView.layer.cornerRadius = 5
        snameView.center = CGPoint(x: 25, y: 23)
        snameView.backgroundColor = UIColor(rgba: currentLine.fgColor)
        
        let snameLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        snameLabel.textAlignment = NSTextAlignment.Center
        snameLabel.text = sname ?? currentLine.sname
        snameLabel.textColor = UIColor(rgba: currentLine.bgColor)
        snameLabel.font = snameLabel.font.fontWithSize(fontSize)
        
        let directionLabel = UILabel(frame: CGRectMake(0, 8, DeviceHelper.getLabelWidth(), 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        directionLabel.text = "\t     \(currentLine.direction)"
        directionLabel.font = directionLabel.font.fontWithSize(16)
        
        let separator = UIView(frame: CGRectMake(0, cell.frame.height - 1, cell.frame.width, 0.5))
        separator.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        snameView.addSubview(snameLabel)
        cell.addSubview(checkbox)
        cell.addSubview(snameView)
        cell.addSubview(directionLabel)
        cell.addSubview(separator)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let currentLine = from(lines).elementAt(indexPath.row)
        currentLine.stopId = stop.id
        if (from(stop.lines).any({$0.id == currentLine.id})){
            SqliteService.sharedInstance.removeLine(currentLine, stopId: stop.id)
        }
        else{
            SqliteService.sharedInstance.addLine(currentLine, stop: stop)
        }
        updateMyLines()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}