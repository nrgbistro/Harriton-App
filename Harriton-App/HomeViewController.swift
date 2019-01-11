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
    
    @IBOutlet weak var todayLetterDayLabel: UILabel!
    @IBOutlet weak var nextLetterDayLabel: UILabel!
    @IBOutlet weak var nextSchoolDateLabel: UILabel!
    
    
    let defaults = UserDefaults.standard
    var urlContent = ""
    var todaysLetterDay = ""
    var nextLetterDay = ""
    
    
    
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
            self.todaysLetterDay = parseData(dataToParse: self.urlContent, Day: Date().day, Month: (Date().month - 1))
            parseQueue.leave()
        }
        
        parseQueue.wait()
        
        return todaysLetterDay
    }
    
    
    
    
    
    func getNextLetterDay() -> String {
        nextSchoolDateLabel.lineBreakMode = .byWordWrapping
        nextSchoolDateLabel.numberOfLines = 2
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone?
        dateFormatter.dateFormat = "cccc"
        
        if(nextLetterDay != ""){
            return nextLetterDay
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
        
        if(getDay() == "Fri"){
            let newDate = Date().threeDaysAfter
            parseQueue.enter()
            DispatchQueue(label: "parse-html-content", qos: .utility).async {
                self.nextLetterDay = parseData(dataToParse: self.urlContent, Day: newDate.day, Month: (newDate.month - 1))
                parseQueue.leave()
            }
            self.nextSchoolDateLabel.text = "On \(dateFormatter.string(from: newDate as Date))\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        }
        else if(getDay() == "Sat"){
            let newDate = Date().twoDaysAfter
            parseQueue.enter()
            DispatchQueue(label: "parse-html-content", qos: .utility).async {
                self.nextLetterDay = parseData(dataToParse: self.urlContent, Day: newDate.day, Month: (newDate.month - 1))
                parseQueue.leave()
            }
            self.nextSchoolDateLabel.text = "On \(dateFormatter.string(from: newDate as Date))\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        }
        else if(getDay() == "Sun"){
            let newDate = Date().dayAfter
            parseQueue.enter()
            DispatchQueue(label: "parse-html-content", qos: .utility).async {
                self.nextLetterDay = parseData(dataToParse: self.urlContent, Day: newDate.day, Month: (newDate.month - 1))
                parseQueue.leave()
            }
            self.nextSchoolDateLabel.text = "On \(dateFormatter.string(from: newDate as Date))\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        }
        else{
            let newDate = Date.tomorrow
            parseQueue.enter()
            DispatchQueue(label: "parse-html-content", qos: .utility).async {
                self.nextLetterDay = parseData(dataToParse: self.urlContent, Day: newDate.day, Month: (newDate.month - 1))
                parseQueue.leave()
            }
            self.nextSchoolDateLabel.text = "On \(dateFormatter.string(from: newDate as Date))\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        }
        
        parseQueue.wait()
        
        return nextLetterDay
    }
    
    
    // --------
    // Main 'runner' function
    // --------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(getDay() == "Sat" || getDay() == "Sun"){
            todayLetterDayLabel.text = "No School Today"
        }
        else{
            print(getTodaysLetterDay())
            todayLetterDayLabel.text = getTodaysLetterDay()
        }
        nextLetterDayLabel.text = getNextLetterDay()
        
        
        /*
        NetworkManager.isReachable { networkManagerInstance in
            
            var day = Int(Date().day)
            var month = Int(Date().month)
            
            
            if(self.getTodaysDate() == self.defaults.string(forKey: "Date")){
                self.todayLetterDayLabel.text = self.defaults.string(forKey: "LetterDay")
            }
            else{
                self.getLetterDay(Day: day, Month: month)
            }
            if(self.todayLetterDayLabel.text == "" || self.todayLetterDayLabel.text == "ERROR"){
                self.getLetterDay(Day: day, Month: month)
            }
        }
        
        NetworkManager.isUnreachable { networkManagerInstance in
            
            if(!self.isTodayANewDay()) {
                if(self.defaults.string(forKey: "LetterDay") != nil){
                    self.todayLetterDayLabel.text = "CANNOT REFRESH"
                }
                else{
                    self.todayLetterDayLabel.text = self.defaults.string(forKey: "LetterDay")
                }
            }
            else{
                self.todayLetterDayLabel.text = "CANNOT REFRESH"
            }
        }
         */
    }
    
    
    // --------
    // Function that connects to harriton website, and saves its HTML to urlContent
    // --------
    func downloadData() {
        let date = Date()
        let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day?cal_date=\(date.year)-\(date.month)-\(date.day)"
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
    */
    func getDay() -> String {
        let CurrentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone?
        dateFormatter.dateFormat = "ccc"
        
        return dateFormatter.string(from: CurrentDate as Date)
 
    }
    /*
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
    var twoDaysAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: noon)!
    }
    var threeDaysAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 3, to: noon)!
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
