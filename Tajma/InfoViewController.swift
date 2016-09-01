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
    let guide = GuideController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bakåt"
        initiateViews()
        
        self.navigationController?.navigationBar.layer.zPosition = 1
        
        tableView.delegate = self
        tableView.dataSource = self
        
        items = ["Lämna feedback","Tajma på Facebook","Tipsa en vän", "Betygsätt Tajma", "Guide: Så här kommer du igång", "Vanliga frågor", "Om oss"]
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
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        
        let title = UILabel(frame: CGRectMake(0, 6, 200, 30))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(19)
        title.text = "Tajma"
        
        let navBarTitleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        navBarTitleView.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView = navBarTitleView
        
        navBarTitleView.addSubview(title)
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    }
    
    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = items[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
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
        switch indexPath.row {
        case 0:
            openMail(Info.Feedback)
        case 1:
            openFacebook(Info.Like)
        case 2:
            openShare()
        case 3:
            openAppStore()
        case 4:
            openHelp()
        case 5:
            openFaq()
        case 6:
            openAboutUs()
        default:
            return
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }

    // MARK: - Functions
    func openShare(){
        let activityItems = ["Hej! Kolla in den här smarta appen som hjälper dig att Tajma avgångarna i kollektivtrafiken:", "", "http://apple.co/1TNxDzk"]
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openAppStore(){
        UIApplication.sharedApplication().openURL(NSURL(string: "http://apple.co/1TNxDzk")!)
    }
    
    func openFacebook(sender : Info){
        if (sender == Info.Like){
            let fbId = "436544669889188"
            let url = "fb://profile/\(fbId)"
            let fbURL = NSURL(string: url)
            if UIApplication.sharedApplication().canOpenURL(fbURL!){
                UIApplication.sharedApplication().openURL(fbURL!)
                
            } else {
                //redirect to safari because the user doesn't have FaceBook
                UIApplication.sharedApplication().openURL(NSURL(string: "http://facebook.com/\(fbId)")!)
            }

        }
    }
    
    func openMail(sender : Info){
        if (sender == Info.Feedback){
            let toRecipients = ["tajma@golazo.nu"]
            let subject = "Feedback Tajma app"
            let body = "<br><br><p>Jag har en \(UIDevice.currentDevice().modelName).<br> Jag har iOS version \(UIDevice.currentDevice().systemVersion).<br</p>"
            
            mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(toRecipients)
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        }
    }
    
    func openFaq(){
        performSegueWithIdentifier("ShowWebView", sender: "http://www.tajma.faq.golazo.nu")
    }
    
    func openHelp(){
        self.performSegueWithIdentifier("ShowGuide", sender: nil)
    }
    
    func openAboutUs(){
        performSegueWithIdentifier("ShowWebView", sender: "http://www.tajma.about.golazo.nu")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if (segue.identifier == "ShowWebView"){
            let web = segue.destinationViewController as! WebViewController
            web.url = String(sender)
            
            if String(sender) == "http://www.tajma.about.golazo.nu"{
                web.titleForView = "Om oss"
            }
            else if String(sender) == "http://www.tajma.faq.golazo.nu"{
                web.titleForView = "Vanliga frågor"
            }
        }
    }
}