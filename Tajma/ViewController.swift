//
//  ViewController.swift
//  Kollektiv
//
//  Created by Rashwan Lazkani on 2015-05-30.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var navController: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var arrOne = [Int]()
    var arrTwo = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar!.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateViews()
        
        arrOne.append(0)
        arrOne.append(2)
        arrOne.append(4)
        arrOne.append(6)
        arrOne.append(8)
        arrOne.append(10)
        
        arrTwo.append(1)
        arrTwo.append(3)
        arrTwo.append(5)
        arrTwo.append(7)
        arrTwo.append(9)
        arrTwo.append(11)
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.hidden = true
    }
    
    // MARK: - Functions
    func initiateViews(){
        // Gradient view
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 9/255, green: 128/255, blue: 129/255, alpha: 1).CGColor, UIColor(red: 72/255, green: 174/255, blue: 151/255, alpha: 1).CGColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, navController.frame.size.height)
        navController.layer.insertSublayer(gradient, atIndex: 0)
        
        // SearchBar
        var textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        searchBar.setImage(UIImage(named: "SearchWhite"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal);
        
        var textfield:UITextField = searchBar.valueForKey("searchField") as! UITextField
        var attributedString = NSAttributedString(string: "Sök hållplats", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textfield.attributedPlaceholder = attributedString
        
        // TableView
        tableView.separatorColor = UIColor(red: 206/255, green: 204/255, blue: 199/255, alpha: 1)
    }
    
    // MARK: - Events
    @IBAction func segmentedControl_Changed(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (arrOne.count < 10 || arrTwo.count < 10){
            return 14
        }
        else{
            return 14
        }
        
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        tableView.backgroundColor = UIColor.whiteColor()
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if(indexPath.row % 2 == 0){
            cell!.backgroundColor = UIColor(red: 236/255, green: 234/255, blue: 227/255, alpha: 1)
        } else{
            cell!.backgroundColor = UIColor(red: 242/255, green: 239/255, blue: 233/255, alpha: 1)
        }
        
        // Behövs inte sen?
        if (segmentedControl.selectedSegmentIndex == 0){
            if (indexPath.row >= arrOne.count){
                cell!.textLabel!.text = nil
            }
            else{
                cell!.textLabel!.text = String(arrOne[indexPath.row])
            }
        }
        else{
            if (indexPath.row >= arrOne.count){
                cell!.textLabel!.text = nil
            }
            else{
                cell!.textLabel!.text = String(arrTwo[indexPath.row])
            }
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //getLinesAtStop(stopWrapper.stops[indexPath.row].id, indexPath: indexPath.row)
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "ShowLinesView"
        {
            println("TEST")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

