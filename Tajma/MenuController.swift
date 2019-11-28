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

class MenuController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var  items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tajma"
        
        self.navigationView.backgroundColor = UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tableView.separatorColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    
        items = ["Senaste nytt via Facebook","Betygsätt i App Store","Tipsa en vän", "Lämna Feedback", "Så aktiverar du Tajmas Widget", "Vanliga frågor", "Om oss"]
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! InfoCell
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1) : UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        
        var image = UIImage()
        switch indexPath.row {
        case 0:
            image = UIImage(named: "facebook")!
        case 1:
            image = UIImage(named: "betygsatt")!
        case 2:
            image = UIImage(named: "tipsa")!
        case 3:
            image = UIImage(named: "feedback")!
        case 4:
            image = UIImage(named: "omoss")!
        case 5:
            image = UIImage(named: "vanliga-fragor")!
        case 6:
            image = UIImage(named: "omoss")!
        default:
            break
        }
        cell.imageV?.image = image
        cell.title.text = items[(indexPath as NSIndexPath).row]
        
        
        if indexPath.row == (items.count - 1) {
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openFacebook(Info.like)
        case 1:
            if let url = URL(string: "http://apple.co/1TNxDzk") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2:
            openShare()
        case 3:
            openMail(Info.feedback)
        case 4:
            self.performSegue(withIdentifier: "ShowWidgetGuide", sender: nil)
        case 5:
            self.performSegue(withIdentifier: "ShowWebView", sender: "http://tajma.faq.lazkani.se")
        case 6:
            self.performSegue(withIdentifier: "ShowWebView", sender: "http://tajma.about.lazkani.se")
        default:
            return
        }
    }
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController,  didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

    // MARK: - Functions
    func openShare() {
        let activityItems = ["Hej! Kolla in den här smarta appen som hjälper dig att Tajma avgångarna i kollektivtrafiken:", "", "http://apple.co/1TNxDzk"]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func openFacebook(_ sender : Info) {
        if sender == Info.like {
            let facebookId = "436544669889188"
            let facebookUrlStr = "fb://profile/\(facebookId)"
            if let facebookUrl = URL(string: facebookUrlStr) {
                if UIApplication.shared.canOpenURL(facebookUrl) {
                    UIApplication.shared.open(facebookUrl, options: [:], completionHandler: nil)
                } else {
                    // redirect to safari because the user doesn't have FaceBook installed
                    if let facebookUrlSafari = URL(string: "http://facebook.com/\(facebookId)") {
                        UIApplication.shared.open(facebookUrlSafari, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func openMail(_ sender : Info) {
        if sender == Info.feedback {
            if !MFMailComposeViewController.canSendMail() {
                print("Cannot send mail")
                return
            }
            
            let toRecipients = ["tajma@lazkani.se"]
            let subject = "Feedback Tajma app"
            let body = "<br><br><p>Jag har en \(UIDevice.modelName).<br> Jag har iOS version \(UIDevice.current.systemVersion).<br</p>"
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(toRecipients)
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: true)
            
            present(mail, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if segue.identifier == "ShowWebView" {
            let web = segue.destination as! WebViewController
            if let url = sender as? String {
                web.url = url
                if url == "http://tajma.about.lazkani.se" {
                    web.titleForView = "Om oss"
                } else if url == "http://tajma.faq.lazkani.se" {
                    web.titleForView = "Vanliga frågor"
                }
            }
        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
         _ = navigationController?.popViewController(animated: true)
    }
}
