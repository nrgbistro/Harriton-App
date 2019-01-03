//
//  HomePageViewController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/25/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit
import SwiftSoup
import Reachability

class HomeViewController: UIViewController {
    
    @IBOutlet weak var letterDayLabel: UILabel!
    
    let defaults = UserDefaults.standard
    var urlContent = ""
    var htmlRetrievalFailed = false
    var continueExecution = true
    var letterDay = "" {
        //after the getLetterDay() func has ran and set the letterDay variable correctly:
        didSet{
            
            defaults.set(getTodaysDate(), forKey: "Date")
            defaults.set(letterDay, forKey: "LetterDay")
            DispatchQueue.main.async {
                self.letterDayLabel.text = self.letterDay
            }
        }
    }
    
    
    // --------
    // Main 'runner' function
    // --------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.isReachable { networkManagerInstance in
            
            var day = Int(Date().day)
            var month = Int(Date().month)
            
            
            if(self.getTodaysDate() == self.defaults.string(forKey: "Date")){
                self.letterDayLabel.text = self.defaults.string(forKey: "LetterDay")
            }
            else{
                self.getLetterDay(Day: day, Month: month)
            }
            if(self.letterDayLabel.text == "" || self.letterDayLabel.text == "ERROR"){
                self.getLetterDay(Day: day, Month: month)
            }
        }
        
        NetworkManager.isUnreachable { networkManagerInstance in
            
            if(!self.isTodayANewDay()) {
                if(self.defaults.string(forKey: "LetterDay") != nil){
                    self.letterDayLabel.text = "CANNOT REFRESH"
                }
                else{
                    self.letterDayLabel.text = self.defaults.string(forKey: "LetterDay")
                }
            }
            else{
                self.letterDayLabel.text = "CANNOT REFRESH"
            }
        }
    }
    
    
    // --------
    // Function that connects to harriton website, and saves its HTML to urlContent
    // Runs in background thread
    // --------
    func getLMSDWebsiteData() {
        if !(isTodayAWeekend()){
            DispatchQueue.main.async {
                self.letterDayLabel.text = "..."
            }
            let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day"
            guard let myURL = URL(string: myURLString) else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
                continueExecution = false
                return
            }
            do {
                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                urlContent = myHTMLString
            } catch {
                
                // Since this is called in a background thread, this forces the following code to run on the main thread, which is required to set text on a storyboard
                DispatchQueue.main.async {
                    self.letterDayLabel.text = "ERROR: Check Connection"
                }
                continueExecution = false
            }
        }
        else{
            DispatchQueue.main.async {
                self.letterDayLabel.text = "NO SCHOOL!"
            }
            continueExecution = false
        }
    }
    
    func getLetterDay(Day:Int, Month:Int) {
        
        
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            self.getLMSDWebsiteData()
            if(self.continueExecution){
                do{
                    let doc = try SwiftSoup.parse(self.urlContent)
                    do{
                        let innerDiv = try doc.select("div.fsCalendarDate,[data-month=\(Month - 1)]:contains(\(Day + 1) + div.fsCalendarInfo")
                        do{
                            let a = try innerDiv.select("a").first()
                            do{
                                if(try a?.text() != nil){
                                    
                                    self.letterDay = (try a?.text())!
                                }
                                else {
                                    self.getLetterDay(Day: Day + 1, Month: Month + 1)
                                }
                            }
                        }
                    }
                }catch{
                    print("CANNOT PARSE WEBSITE DATA")
                }
            }
        }
    }
    
    func getTodaysDate() -> String {
        let date = Date()
        return "\(date.day)-\(date.month)-\(date.year)"
    }
    
    func isTodayAWeekend() -> Bool {
        let CurrentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone?
        dateFormatter.dateFormat = "ccc"
        
        let weekend = dateFormatter.string(from: CurrentDate as Date)
        let isSaturday = "Sat"
        let isSunday = "Sun"
        if weekend == isSaturday || weekend == isSunday {
            return true
        }
        else {
            return false
        }
    }
    
    func isTodayANewDay() -> Bool {
        if(defaults.string(forKey: "Date") == getTodaysDate()) {
            return false
        }
        else{
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Date {
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date().noon)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var day: Int {
        return Calendar.current.component(.day,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
