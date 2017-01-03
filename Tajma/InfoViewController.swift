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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.tintColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    // MARK: - Functions
    func initiateViews(){
        let title = UILabel(frame: CGRect(x: 0, y: 6, width: 200, height: 30))
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        title.font = title.font.withSize(19)
        title.text = "Tajma"
        
        let navBarTitleView = UIView(frame: CGRect(x: deviceHelper.screenWidth / 2, y: 0, width: 200, height: 44))
        navBarTitleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = navBarTitleView
        
        navBarTitleView.addSubview(title)
        
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel!.text = items[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        if((indexPath as NSIndexPath).row % 2 == 0){
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        } else{
            cell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
        
        if ((indexPath as NSIndexPath).row == items.count - 1){
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            if ((indexPath as NSIndexPath).row % 2 == 0){
                tableView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            }
            else{
                tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            openMail(Info.feedback)
        case 1:
            openFacebook(Info.like)
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
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController,  didFinishWith result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }

    // MARK: - Functions
    func openShare(){
        let activityItems = ["Hej! Kolla in den här smarta appen som hjälper dig att Tajma avgångarna i kollektivtrafiken:", "", "http://apple.co/1TNxDzk"]
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    func openAppStore(){
        UIApplication.shared.openURL(URL(string: "http://apple.co/1TNxDzk")!)
    }
    
    func openFacebook(_ sender : Info){
        if (sender == Info.like){
            let fbId = "436544669889188"
            let url = "fb://profile/\(fbId)"
            let fbURL = URL(string: url)
            if UIApplication.shared.canOpenURL(fbURL!){
                UIApplication.shared.openURL(fbURL!)
                
            } else {
                //redirect to safari because the user doesn't have FaceBook
                UIApplication.shared.openURL(URL(string: "http://facebook.com/\(fbId)")!)
            }

        }
    }
    
    func openMail(_ sender : Info){
        if (sender == Info.feedback){
            if !MFMailComposeViewController.canSendMail() {
                print("Cannot send mail")
                return
            }
            
            let toRecipients = ["tajma@golazo.nu"]
            let subject = "Feedback Tajma app"
            let body = "<br><br><p>Jag har en \(UIDevice.current.modelName).<br> Jag har iOS version \(UIDevice.current.systemVersion).<br</p>"
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(toRecipients)
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: true)
            
            present(mail, animated: true, completion: nil)
        }
    }
    
    func openFaq(){
        performSegue(withIdentifier: "ShowWebView", sender: "http://www.tajma.faq.golazo.nu")
    }
    
    func openHelp(){
        self.performSegue(withIdentifier: "ShowGuide", sender: nil)
    }
    
    func openAboutUs(){
        performSegue(withIdentifier: "ShowWebView", sender: "http://www.tajma.about.golazo.nu")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if (segue.identifier == "ShowWebView"){
            let web = segue.destination as! WebViewController
            web.url = String(describing: sender!)
            
            if String(describing: sender) == "http://www.tajma.about.golazo.nu"{
                web.titleForView = "Om oss"
            }
            else if String(describing: sender) == "http://www.tajma.faq.golazo.nu"{
                web.titleForView = "Vanliga frågor"
            }
        }
    }
}
