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
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var lineWrapper = LineWrapper()
    var stop : Stop!
    var currentLinesAndDirections = [String]()
    let dbService = DBService()
    let phoneSize = PhoneSize()
    var checkBoxService = CheckBox()
    var checkBoxes = [CheckBox]()
 
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = stop.name
        
        initiateViews()
        showLines()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        navigationController?.navigationBar.hidden = true
    }
    
    // MARK: - Events
    override func didMoveToParentViewController(parent: UIViewController?) {
        if (parent == nil) {
            dbService.addLinesToStop(stop)
        }
    }
    
    // MARK: - Functions
    func initiateViews(){
        // NavBar
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 9/255, green: 128/255, blue: 129/255, alpha: 1)
        activityIndicator.frame = CGRectMake(100, 100, 100, 100);
        self.view.addSubview(activityIndicator)
        
        self.navigationItem.backBarButtonItem!.title = "Backhh"
        
        // TableView
        tableView.separatorColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 1)
    }
    
    func showLines(){
        var tagId = 0
        var viewHeight = 25
        
        for line in lineWrapper.lines{
            var checkBox = CheckBox()
            checkBox.setImage(UIImage(named: "unchecked-box") as UIImage!, forState: UIControlState.Normal)
            checkBox.addTarget(checkBox, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            checkBox.tag = tagId
            checkBox.frame = CGRectMake(50, 50, 50, 50)
            checkBox.center = CGPoint(x: view.bounds.width - 25, y: 44 / 2.0)
            
            var stopLine : StopLine
            
            if (contains(Global.allaStopp, line.lineAndDirection)){
                stopLine = StopLine(stopId: stop.id, sname: line.sname, tag: checkBox.tag, type: line.type, track: line.track, lineAndDirection: line.lineAndDirection, isChecked: true)
                checkBox.isChecked = true
            }
            else{
                stopLine = StopLine(stopId: stop.id, sname: line.sname, tag: checkBox.tag, type: line.type, track: line.track, lineAndDirection: line.lineAndDirection, isChecked: false)
            }
            
            Global.linesAtStop.append(stopLine as StopLine)
            checkBoxes.append(checkBox)
            
            viewHeight += 54
            tagId++
        }
        
        scrollView.contentSize = CGSize(width: phoneSize.width, height: viewHeight)
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return lineWrapper.lines.count
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        var view = UIView()
        view.frame = CGRectMake(30, 30, 30, 30)
        view.layer.cornerRadius = 5
        view.center = CGPoint(x: view.bounds.width, y: 44 / 2.0)
        view.backgroundColor = UIColor(rgba: lineWrapper.lines[indexPath.row].fgColor)
        
        var sname = ""
        var letterSname = lineWrapper.lines[indexPath.row].sname.toInt()
        if (count(lineWrapper.lines[indexPath.row].sname) > 3) || letterSname == nil{
            let snameArr = Array(lineWrapper.lines[indexPath.row].sname)
            sname = String(snameArr[0])
        }
        else{
            sname = lineWrapper.lines[indexPath.row].sname
        }
        
        var label = UILabel(frame: CGRectMake(0, 0, 30, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = sname ?? lineWrapper.lines[indexPath.row].sname
        label.textColor = UIColor(rgba: lineWrapper.lines[indexPath.row].bgColor)
        cell!.textLabel!.text = "\t   " + lineWrapper.lines[indexPath.row].direction
        
        view.addSubview(label)
        cell!.addSubview(view)
        cell!.addSubview(checkBoxes[indexPath.row])
        
        if(indexPath.row % 2 == 0){
            cell!.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
        } else{
            cell!.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
        }
        
        if (indexPath.row == lineWrapper.lines.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
            
            if (indexPath.row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
                //viewWrapper.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
                //viewWrapper.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //getLinesAtStop(stopWrapper.stops[indexPath.row].id, indexPath: indexPath.row)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
