//
//  LinesViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-05-31.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class LinesViewController: UIViewController {
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet var scrollView: UIScrollView!
    
    var lineWrapper = LineWrapper()
    var stop : Stop!
    var currentLinesAndDirections = [String]()
    let phoneSize = PhoneSize()
    var checkBoxService = CheckBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false

        self.scrollView.bounces = true
        self.scrollView.alwaysBounceVertical = true
        
        initiateViews()
        drawLinesTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = 1
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
    }
    
    // MARK: - Functions
    func initiateViews(){
        // NavController
        navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 137/255, blue: 239/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        
        let title = UILabel(frame: CGRectMake(0, 6, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(17)
        title.text = stop.name
        
        let navBarTitleView = UIView(frame: CGRect(x: phoneSize.width / 2, y: 0, width: 200, height: 44))
        navBarTitleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = navBarTitleView
        
        navBarTitleView.addSubview(title)
        
        scrollView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    }
    
    func drawLinesTableView(){
        var height = 0
        var tag = 0
        
        //self.lineWrapper.lines.sortInPlace({Int($0.sname) < Int($1.sname) ? $0.sname < $1.name : $0.name < $1.name })
        self.lineWrapper.lines.sortInPlace({Int($0.sname) < Int($1.sname)})
        
        
        for (index, line) in lineWrapper.lines.enumerate(){
            var checkBox = CheckBox()
            checkBox.setImage(UIImage(named: "unchecked-box") as UIImage!, forState: UIControlState.Normal)
            checkBox.addTarget(checkBox, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            checkBox.tag = tag
            checkBox.frame = CGRectMake(50, 50, 1000, 44)
            checkBox.center = CGPoint(x: scrollView.bounds.width - 25, y: 44 / 2.0)
            
            var stopLine : StopLine
            var isChecked = false
            
            if (Global.allaStopp.contains(line.lineAndDirection)){
                stopLine = StopLine(stopId: stop.id, stopName: stop.name, lat: stop.lat, long: stop.long, sname: line.sname, tag: checkBox.tag, type: line.type, track: line.track, direction: line.direction, lineAndDirection: line.lineAndDirection, isChecked: true)
                checkBox.isChecked = true
                
                isChecked = true
            }
            else{
                stopLine = StopLine(stopId: stop.id, stopName: stop.name, lat: stop.lat, long: stop.long, sname: line.sname, tag: checkBox.tag, type: line.type, track: line.track, direction: line.direction, lineAndDirection: line.lineAndDirection, isChecked: false)
                
                isChecked = false
            }
            
            Global.linesAtStop.append(stopLine)
            
            var view = UIView(frame: CGRect(x: 0, y: height, width: Int(scrollView.frame.size.width), height: 44))
            
            var fontSize = CGFloat(16)
            var sname = ""
            var letterSname = Int(line.sname)
            // Bokstväver
            if (line.sname == "16X"){
                fontSize = CGFloat(12)
                sname = line.sname
            }
            else if (letterSname == nil){
                let snameArr = Array(line.sname.characters)
                sname = String(snameArr[0])
            }
            else if (line.sname.characters.count > 2){
                fontSize = CGFloat(12)
                sname = line.sname
            }
            else{
                sname = line.sname
            }
            
            // SnameView
            var snameView = UIView()
            snameView.frame = CGRectMake(30, 30, 30, 30)
            snameView.layer.cornerRadius = 5
            snameView.center = CGPoint(x: 25, y: 23)
            snameView.backgroundColor = UIColor(rgba: line.fgColor)
            
            // SnameLabel
            var snameLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
            snameLabel.textAlignment = NSTextAlignment.Center
            snameLabel.text = sname ?? line.sname
            snameLabel.textColor = UIColor(rgba: line.bgColor)
            snameLabel.font = snameLabel.font.fontWithSize(fontSize)
            
            // DirectionLabel
            var directionLabel = UILabel(frame: CGRectMake(0, 8, DeviceHelper.getLabelWidth(), 30))
            directionLabel.textAlignment = NSTextAlignment.Left
            directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
            directionLabel.text = "\t     \(line.direction)"
            directionLabel.font = directionLabel.font.fontWithSize(16)
            
            // SepartorView
            var separatorView = UIView(frame: CGRect(x: 0, y: height, width: Int(scrollView.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.5)
            
            if (isChecked){
                //directionLabel.font = UIFont.boldSystemFontOfSize(16)
            }
            
            view.addSubview(checkBox)
            view.addSubview(snameView)
            snameView.addSubview(snameLabel)
            view.addSubview(directionLabel)
            
            scrollView.addSubview(view)
            scrollView.addSubview(separatorView)
            
            height += 44
            tag++
            
            if(index % 2 == 0){
                view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            } else{
                view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            }
            
            
            // Sätta bakgrunden på tableView
            if (index == lineWrapper.lines.count - 1){
                if (index % 2 == 0){
                    scrollView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
                }
                else{
                    scrollView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
                }
            }
            
        }
            
        
        var separatorView = UIView(frame: CGRect(x: 0, y: height, width: Int(scrollView.frame.size.width), height: 1))
        separatorView.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        self.view.addSubview(separatorView)
        scrollView.contentSize = CGSize(width: phoneSize.width, height: height)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}