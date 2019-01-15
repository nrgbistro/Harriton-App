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
import SwiftDate

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
                self.downloadLMSDData()
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        let parseQueue = DispatchGroup()
        
        parseQueue.enter()
        
        DispatchQueue(label: "parse-html-content", qos: .utility).async {
            self.todaysLetterDay = self.parseData(dataToParse: self.urlContent, Day: Date().day, Month: (Date().month - 1))
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
                self.downloadLMSDData()
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        
        let parseQueue = DispatchGroup()
        
        var newDate = DateInRegion()
        while(nextLetterDay == "" || nextLetterDay == "No School Today"){
            newDate = newDate + 1.day
            parseQueue.enter()
            DispatchQueue(label: "parse-html-content", qos: .utility).async {
                self.nextLetterDay = self.parseData(dataToParse: self.urlContent, Day: newDate.day, Month: (newDate.month - 1))
                parseQueue.leave()
            }
        }
        parseQueue.wait()
        
        self.nextSchoolDateLabel.text = "On \(newDate.weekdayName)\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        return nextLetterDay
    }
    
    
    // --------
    // Main 'runner' function
    // --------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(getDay() == 7 || getDay() == 1){
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
    func downloadLMSDData() {
        let date = DateInRegion()
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


    // --------
    // Function that takes data input, selected day and month, and returns the letter day from that day
    // --------

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
    func getDay() -> Int {
        return DateInRegion().weekday
    }
}
