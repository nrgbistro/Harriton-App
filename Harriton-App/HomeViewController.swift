//
//  HomePageViewController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/25/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit
import SwiftSoup

class HomeViewController: UIViewController {
    
    @IBOutlet weak var letterDayLabel: UILabel!
    
    var urlContent = ""
    var htmlRetrievalFailed = false
    var letterDay = "" {
        didSet{
            DispatchQueue.main.async {
                self.letterDayLabel.text = self.letterDay
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let defaults = UserDefaults.standard
        getLetterDay()
    }
    
    
    // --------
    // Function that connects to harriton website, and saves its HTML to urlContent
    // Runs in background thread
    // --------
    func getLMSDWebsiteData() {
        if !(isTodayAWeekend()){
            let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day"
            guard let myURL = URL(string: myURLString) else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
                return
            }
            do {
                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                urlContent = myHTMLString
            } catch let error {
                print("Error: \(error)")
                
                // Since this is called in a background thread, this forces the following code to run on the main thread, which is required to set text on a storyboard
                DispatchQueue.main.async {
                    self.letterDayLabel.text = "ERROR: Check Connection"
                }
            }
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
    
    func getLetterDay() {
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            self.getLMSDWebsiteData()
            do{
                let doc = try SwiftSoup.parse(self.urlContent)
                do{
                    let element = try doc.select("div.fsCalendarToday").first()
                    do{
                        let link = try element?.select("a.fsCalendarEventTitle")
                        do{
                            self.letterDay = (try link?.text())!
                        }
                    }
                }
            }catch{
                print(error)
            }
        }
    }
    
    func getTodaysDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(day)-\(month)-\(year)"
    }
    
    func isTodayAWeekend() -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        if (weekday == 6 || weekday == 7) {
            return true
        }
        else{
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
