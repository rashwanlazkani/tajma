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
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        initiateViews()
        
        arrOne.append(0)
        arrOne.append(2)
        arrOne.append(4)
        arrOne.append(6)
        arrOne.append(8)
        arrOne.append(10)
        arrOne.append(0)
        arrOne.append(2)
        arrOne.append(4)
        arrOne.append(6)
        arrOne.append(8)
        arrOne.append(10)
        arrOne.append(8)
        arrOne.append(10)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        navigationController?.navigationBar.hidden = true
    }
    
    // MARK: - Functions
    func initiateViews(){
        // NavBar
        
        var nav = self.navigationController?.navigationBar
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 9/255, green: 128/255, blue: 129/255, alpha: 1).CGColor, UIColor(red: 72/255, green: 174/255, blue: 151/255, alpha: 1).CGColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRectMake(0, 0, nav!.frame.size.width, nav!.frame.size.height)
        
        // 2
        nav!.barStyle = UIBarStyle.Black
        nav!.tintColor = UIColor.whiteColor()
        
        // TableView
        tableView.separatorColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 1)
    }

    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 14
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        tableView.backgroundColor = UIColor.whiteColor()
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        var checked = UIImage(named: "check-box-red")
        var unChecked = UIImage(named: "unchecked-box")
        
        var imageView : UIImageView
        
        if(indexPath.row % 2 == 0){
            cell!.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
            cell!.textLabel!.text = "Hållplats"
            imageView = UIImageView(image: checked)
        } else{
            cell!.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
            cell!.textLabel!.text = "Hållplats"
            imageView = UIImageView(image: unChecked)
        }
        
        if (indexPath.row >= arrOne.count){
            cell!.textLabel!.text = nil
        }
        else{
            
        }
        
        cell!.accessoryView = imageView

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
