//
//  InfoViewController.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-06-20.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import MessageUI
import Social
import MobileCoreServices

class InfoViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    var mail: MFMailComposeViewController!
    var  items = [String]()
    
    var deviceHelper = DeviceHelper()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.layer.zPosition = 1
        
        initiateViews()
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        items = ["Ge oss feedback","Gilla oss på facebook","Dela appen", "Betygsätt Tajma", "Hjälp"]
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
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        
        let title = UILabel(frame: CGRectMake(0, 6, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(17)
        title.text = "Information"
        
        let navBarTitleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        navBarTitleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = navBarTitleView
        
        navBarTitleView.addSubview(title)
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    }
    
    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        cell.textLabel!.text = items[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        
        // Sätta bakgrunden på tableView
        if (indexPath.row == items.count - 1){
            tableView.tableFooterView = UIView(frame: CGRectZero)
            
            if (indexPath.row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0){
            openMail(Info.Feedback)
        }
        else if (indexPath.row == 1){
            openFacebook(Info.Like)
        }
        else if (indexPath.row == 2){
            openShare()
        }
        else if (indexPath.row == 3){
            openAppStore()
        }
        else if (indexPath.row == 4){
            openHelp()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }

    // MARK: - Functions
    func openShare(){
        let activityItems = ["Vill tipsa om en grym app som jag...", "", "https://itunes.apple.com/se/app/instainfo/id689392780?mt=8"]
        
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openAppStore(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/se/app/instainfo/id689392780?mt=8")!)
    }
    
    func openFacebook(sender : Info){
        if (sender == Info.Like){
            let fbId = "100003120646750"
            let url = "fb://profile/\(fbId)"
            let fbURL = NSURL(string: url)
            if UIApplication.sharedApplication().canOpenURL(fbURL!)
            {
                UIApplication.sharedApplication().openURL(fbURL!)
                
            } else {
                //redirect to safari because the user doesn't have FaceBook
                UIApplication.sharedApplication().openURL(NSURL(string: "http://facebook.com/profile/\(fbId)")!)
            }
        }
    }
    
    func openMail(sender : Info){
        if (sender == Info.Feedback){
            let toRecipients = ["Rashwan87@gmail.com"]
            let subject = "Feedback Tajma app"
            let body = "<H3>Feedback</h3><p>Jag har en \(UIDevice.currentDevice().modelName)<br> Jag har iOS version \(UIDevice.currentDevice().systemVersion)<br</p><br><br><br>"
            
            mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(toRecipients)
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        }
    }
    
    func openHelp(){
        let webV:UIWebView = UIWebView(frame: CGRectMake(0, self.navigationController!.navigationBar.bounds.height - 44, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 65))
        webV.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.tajmahelpappwebsite.rashwanlazkani.se/")!))
        self.view.addSubview(webV)
    }
}