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
        
        getLinesAtStop(stop.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        initiateViews()
        tableView.reloadData()
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
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    }
    
    func getLinesAtStop(stopId : String){
        activityIndicator.startAnimating()
        // Låser vyn
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        lineService.getAllLinesAtStop(stopId, onSuccess: { json -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.lines = json
            })
            dispatch_async(dispatch_get_main_queue(),{
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
            }, onError:{ error -> Void in
                print(error)
        })
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return lines.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let currentLine = from(lines).elementAt(indexPath.row)
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        for view in cell.subviews{
            if(view.isKindOfClass(UILabel) || view.isKindOfClass(Checkbox)){
                view.removeFromSuperview()
            }
        }
        
        let checkBox = Checkbox()
        checkBox.setImage(UIImage(named: "unchecked-box") as UIImage!, forState: UIControlState.Normal)
        checkBox.addTarget(checkBox, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        checkBox.tag = indexPath.row
        checkBox.frame = CGRectMake(50, 50, 1000, 44)
        checkBox.center = CGPoint(x: tableView.bounds.width - 25, y: 44 / 2.0)
        checkBox.tag = indexPath.row
        
        var fontSize = CGFloat(16)
        var sname = ""
        if ((Int(stop.lines[indexPath.row].sname.substringToIndex(stop.lines[indexPath.row].sname.startIndex.advancedBy(1)))) == nil){
            let snameArr = Array(stop.lines[indexPath.row].sname.characters)
            sname = String(snameArr[0])
        }
        else if (stop.lines[indexPath.row].sname.characters.count > 2){
            fontSize = CGFloat(12)
            sname = stop.lines[indexPath.row].sname
        }
        else{
            sname = stop.lines[indexPath.row].sname
        }
        
        let snameView = UIView()
        snameView.frame = CGRectMake(30, 30, 30, 30)
        snameView.layer.cornerRadius = 5
        snameView.center = CGPoint(x: 25, y: 23)
        snameView.backgroundColor = UIColor(rgba: stop.lines[indexPath.row].fgColor)
        
        let snameLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        snameLabel.textAlignment = NSTextAlignment.Center
        snameLabel.text = sname ?? stop.lines[indexPath.row].sname
        snameLabel.textColor = UIColor(rgba: stop.lines[indexPath.row].bgColor)
        snameLabel.font = snameLabel.font.fontWithSize(fontSize)
        
        let directionLabel = UILabel(frame: CGRectMake(0, 8, DeviceHelper.getLabelWidth(), 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        directionLabel.text = "\t     \(stop.lines[indexPath.row].direction)"
        directionLabel.font = directionLabel.font.fontWithSize(16)
        
        snameView.addSubview(snameLabel)
        cell.addSubview(checkBox)
        cell.addSubview(snameView)
        cell.addSubview(directionLabel)
        
        if (indexPath.row == stop.lines.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print(indexPath.row)
        let currentLine = from(lines).elementAt(indexPath.row)
        currentLine.stop = stop
        if (from(stop.lines).any({$0.lineAndDirection == currentLine.lineAndDirection})){
            RealmService.sharedInstance.removeObject(stop.lines[indexPath.row])
        }
        else{
            RealmService.sharedInstance.addObject(stop.lines[indexPath.row])
        }
        getLinesAtStop(stop.id)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}