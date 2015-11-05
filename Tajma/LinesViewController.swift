//
//  LinesViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-31.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class LinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var lines = [Line]
    var stop : Stop!
    var currentLinesAndDirections = [String]()
    let deviceHelper = DeviceHelper()
    var isChecked = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return lineWrapper.lines.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
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
        
        let stopLine = StopLine()
        stopLine.stopId = stop.id
        stopLine.stopName = stop.name
        stopLine.lat = stop.lat
        stopLine.long = stop.long
        stopLine.sname = lineWrapper.lines[indexPath.row].sname
        stopLine.tag = checkBox.tag
        stopLine.type = lineWrapper.lines[indexPath.row].type
        stopLine.track = lineWrapper.lines[indexPath.row].track
        stopLine.direction = lineWrapper.lines[indexPath.row].direction
        stopLine.lineAndDirection = lineWrapper.lines[indexPath.row].lineAndDirection
        
        if (Global.addedLinesAtStop.contains(lineWrapper.lines[indexPath.row].lineAndDirection)){
            stopLine.isChecked = true
            checkBox.isChecked = true
        }
        Global.linesAtStop.append(stopLine)
        
        var fontSize = CGFloat(16)
        var sname = ""
        if ((Int(lineWrapper.lines[indexPath.row].sname.substringToIndex(lineWrapper.lines[indexPath.row].sname.startIndex.advancedBy(1)))) == nil){
            let snameArr = Array(lineWrapper.lines[indexPath.row].sname.characters)
            sname = String(snameArr[0])
        }
        else if (lineWrapper.lines[indexPath.row].sname.characters.count > 2){
            fontSize = CGFloat(12)
            sname = lineWrapper.lines[indexPath.row].sname
        }
        else{
            sname = lineWrapper.lines[indexPath.row].sname
        }
        
        let snameView = UIView()
        snameView.frame = CGRectMake(30, 30, 30, 30)
        snameView.layer.cornerRadius = 5
        snameView.center = CGPoint(x: 25, y: 23)
        snameView.backgroundColor = UIColor(rgba: lineWrapper.lines[indexPath.row].fgColor)
        
        let snameLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        snameLabel.textAlignment = NSTextAlignment.Center
        snameLabel.text = sname ?? lineWrapper.lines[indexPath.row].sname
        snameLabel.textColor = UIColor(rgba: lineWrapper.lines[indexPath.row].bgColor)
        snameLabel.font = snameLabel.font.fontWithSize(fontSize)
        
        let directionLabel = UILabel(frame: CGRectMake(0, 8, DeviceHelper.getLabelWidth(), 30))
        directionLabel.textAlignment = NSTextAlignment.Left
        directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        directionLabel.text = "\t     \(lineWrapper.lines[indexPath.row].direction)"
        directionLabel.font = directionLabel.font.fontWithSize(16)
        
        snameView.addSubview(snameLabel)
        cell.addSubview(checkBox)
        cell.addSubview(snameView)
        cell.addSubview(directionLabel)

        if (indexPath.row == lineWrapper.lines.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print(indexPath.row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}