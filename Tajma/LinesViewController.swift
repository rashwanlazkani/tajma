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
    let dbService = DBService()
    let phoneSize = PhoneSize()
    var checkBoxService = CheckBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.hidden = false

        self.scrollView.bounces = true
        self.scrollView.alwaysBounceVertical = true
        
        initiateViews()
        drawLinesTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        navigationController?.navigationBar.hidden = true
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.navigationController?.navigationBar.translucent = true
        }
    }
    
    // MARK: - Functions
    func initiateViews(){
        var title = UILabel(frame: CGRectMake(0, 4, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = UIFont.boldSystemFontOfSize(16)
        title.text = stop.name
        
        var navBarTitleView = UIView(frame: CGRect(x: phoneSize.width / 2, y: 0, width: 200, height: 44))
        navBarTitleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = navBarTitleView
        
        navBarTitleView.addSubview(title)
        
        // NavBar
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 240/255, green: 80/255, blue: 80/255, alpha: 1)
        
        self.navigationController?.navigationBar.translucent = false
        
        scrollView.backgroundColor = UIColor.whiteColor()
    }
    
    func buttonClicked(sender : UIButton){
        println("HJASHJS")
    }
    
    func drawLinesTableView(){
        var height = 0
        var tag = 0
        
        self.lineWrapper.lines.sort({$0.sname.toInt() < $1.sname.toInt() ? $0.sname < $1.name : $0.name < $1.name })
        
        for line in lineWrapper.lines{
            var checkBox = CheckBox()
            checkBox.setImage(UIImage(named: "unchecked-box") as UIImage!, forState: UIControlState.Normal)
            checkBox.addTarget(checkBox, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            checkBox.tag = tag
            checkBox.frame = CGRectMake(50, 50, 1000, 44)
            checkBox.center = CGPoint(x: scrollView.bounds.width - 25, y: 44 / 2.0)
            
            var stopLine : StopLine
            var isChecked = false
            
            if (contains(Global.allaStopp, line.lineAndDirection)){
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
            /*
            if(tag % 2 == 0){
            view.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
            } else{
            view.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
            }
            */
            var fontSize = CGFloat(16)
            var sname = ""
            var letterSname = line.sname.toInt()
            // Bokstväver
            if (letterSname == nil){
                let snameArr = Array(line.sname)
                sname = String(snameArr[0])
            }
            else if (count(line.sname) > 2){
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
            var directionLabel = UILabel(frame: CGRectMake(0, 8, 330, 30))
            directionLabel.textAlignment = NSTextAlignment.Left
            directionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
            directionLabel.text = "\t     \(line.direction)"
            directionLabel.font = directionLabel.font.fontWithSize(16)
            
            // SepartorView
            var separatorView = UIView(frame: CGRect(x: 0, y: height, width: Int(scrollView.frame.size.width), height: 1))
            separatorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.5)
            
            view.addSubview(checkBox)
            view.addSubview(snameView)
            snameView.addSubview(snameLabel)
            view.addSubview(directionLabel)
            
            scrollView.addSubview(view)
            scrollView.addSubview(separatorView)

            height += 44
            tag++
        }
        
        var separatorView = UIView(frame: CGRect(x: 0, y: height, width: Int(scrollView.frame.size.width), height: 1))
        separatorView.backgroundColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 0.5)
        
        self.view.addSubview(separatorView)
        scrollView.contentSize = CGSize(width: phoneSize.width, height: height)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}