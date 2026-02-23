import SwiftUI

@main
struct TajmaApp: App {
    init() {
        let count = UserDefaults.standard.integer(forKey: "appOpenCount") + 1
        UserDefaults.standard.set(count, forKey: "appOpenCount")

        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(red: 231/255, green: 63/255, blue: 87/255, alpha: 1),
             .font: UIFont.systemFont(ofSize: 14)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white,
             .font: UIFont.systemFont(ofSize: 14)], for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadMainView()
            } else {
                StopsView()
            }
        }
    }
}
