import Foundation
import UIKit

@MainActor
class MenuViewModel: ObservableObject {
    let items: [MenuItem] = [
        MenuItem(title: "Senaste nytt via Facebook", iconName: "facebook", action: .facebook),
        MenuItem(title: "Betygsätt i App Store", iconName: "betygsatt", action: .appStore),
        MenuItem(title: "Tipsa en vän", iconName: "tipsa", action: .share),
        MenuItem(title: "Lämna Feedback", iconName: "feedback", action: .feedback),
        MenuItem(title: "Så aktiverar du Tajmas Widget", iconName: "omoss", action: .widgetGuide),
        MenuItem(title: "Vanliga frågor", iconName: "vanliga-fragor", action: .faq),
        MenuItem(title: "Om oss", iconName: "omoss", action: .about),
    ]

    func openFacebook() {
        let facebookId = "436544669889188"
        if let url = URL(string: "fb://profile/\(facebookId)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "http://facebook.com/\(facebookId)") {
            UIApplication.shared.open(url)
        }
    }

    func openAppStore() {
        if let url = URL(string: "http://apple.co/1TNxDzk") {
            UIApplication.shared.open(url)
        }
    }

    var shareItems: [Any] {
        ["Hej! Kolla in den här smarta appen som hjälper dig att Tajma avgångarna i kollektivtrafiken:", "", "http://apple.co/1TNxDzk"]
    }

    var faqURL: String { "http://app.tajma.faq.rltech.se" }
    var aboutURL: String { "http://app.tajma.about.rltech.se" }
}
