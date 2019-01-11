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
    @IBOutlet weak var tomorrowLetterDayLabel: UILabel!
    
    let defaults = UserDefaults.standard
    var urlContent = ""
    var todaysLetterDay = ""
    
    
    
    func getTodaysLetterDay() -> String {
        if(todaysLetterDay != ""){
            return todaysLetterDay
        }
        
        if(urlContent == ""){
            let downloadQueue = DispatchGroup()
            
            downloadQueue.enter()
            DispatchQueue(label: "download-content", qos: .utility).async {
                self.downloadData()
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        
        let parseQueue = DispatchGroup()
        
        parseQueue.enter()
        
        DispatchQueue(label: "parse-html-content", qos: .utility).async {
            self.todaysLetterDay = parseData(dataToParse: self.urlContent, Day: 12, Month: 0)
            parseQueue.leave()
        }
        
        parseQueue.wait()
        
        return todaysLetterDay
    }
    
    
    // --------
    // Main 'runner' function
    // --------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(getTodaysLetterDay())
        letterDayLabel.text = getTodaysLetterDay()
        
        /*
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
         */
    }
    
    
    // --------
    // Function that connects to harriton website, and saves its HTML to urlContent
    // --------
    func downloadData() {
        let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) is not a valid URL")
            return
        }
        do {
            urlContent = try String(contentsOf: myURL, encoding: .ascii)
        } catch {
            print("oh boi")
            }
        }
    }

    func parseData(dataToParse:String, Day:Int, Month:Int) -> String {
        do{
            let doc = try SwiftSoup.parse(dataToParse)
            do{
                let innerDiv = try doc.select("div.fsCalendarDate[data-day=\(Day)][data-month=\(Month)] + div.fsCalendarInfo")
                do{
                    let a = try innerDiv.select("a.fsCalendarEventTitle")
                    if(try a.text() != ""){
                        return (try a.text())
                    }
                    else{
                        return "No School Today"
                    }
                }
            }
        }
        catch{
            return "ERROR"
        }
    }
 
 /*
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
    }*/
//}

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
