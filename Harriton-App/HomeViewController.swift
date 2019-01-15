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
    var LMSDUrlContent = ""
    var todaysLetterDay = ""
    var nextLetterDay = ""
    
    
    
    func getTodaysLetterDay() -> String {
        if(todaysLetterDay != ""){
            return todaysLetterDay
        }
        
        if(LMSDUrlContent == ""){
            let downloadQueue = DispatchGroup()
            
            downloadQueue.enter()
            DispatchQueue(label: "download-content", qos: .utility).async {
                let date = DateInRegion()
                self.downloadLMSDData(Year: date.year, Month: date.month, Day: date.day)
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        let parseQueue = DispatchGroup()
        
        parseQueue.enter()
        
        DispatchQueue(label: "parse-html-content", qos: .utility).async {
            self.todaysLetterDay = self.parseData(dataToParse: self.LMSDUrlContent, Day: Date().day, Month: (Date().month - 1))
            parseQueue.leave()
        }
        
        parseQueue.wait()
        
        return todaysLetterDay
    }
    
    
    
    
    
    func getNextLetterDay() -> String {
        if(nextLetterDay != ""){
            return nextLetterDay
        }
        
        if(LMSDUrlContent == ""){
            let downloadQueue = DispatchGroup()
            
            downloadQueue.enter()
            DispatchQueue(label: "download-content", qos: .utility).async {
                self.downloadLMSDData(Year: DateInRegion().year, Month: DateInRegion().month, Day: DateInRegion().day)
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        
        var newDate = DateInRegion() + 17.days
        while(nextLetterDay == "" || nextLetterDay == "No School Today"){
            newDate = newDate + 1.day
            print(newDate)
            self.nextLetterDay = self.parseData(dataToParse: self.LMSDUrlContent, Day: newDate.day, Month: (newDate.month - 1))
            if(newDate.compare(to: <#T##DateInRegion#>, granularity: <#T##Calendar.Component#>)   getLastDateOnCalendar(dataToParse: LMSDUrlContent)){
                
            }
        }
        
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
            todayLetterDayLabel.text = getTodaysLetterDay()
        }
        downloadLMSDData(Year: 2019, Month: 1, Day: 5)
        print(getLastDateOnCalendar(dataToParse: LMSDUrlContent).day)
        //nextLetterDayLabel.text = getNextLetterDay()
        
        
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
    // Function that connects to harriton website, and saves its HTML to LMSDUrlContent
    // --------
    func downloadLMSDData(Year:Int, Month:Int, Day:Int) {
        let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day?cal_date=\(Year)-\(Month)-\(Day)"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) is not a valid URL")
            return
        }
        do {
            LMSDUrlContent = try String(contentsOf: myURL, encoding: .ascii)
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
    
    func getLastDateOnCalendar(dataToParse:String) -> DateComponents {
        do{
            let doc = try SwiftSoup.parse(dataToParse)
            do{
                let div = try doc.select("div.fsCalendarDate").last()
                do{
                    let Day:Int = Int((try div?.attr("data-day"))!)!
                    let Month:Int = Int((try div?.attr("data-month"))!)! + 1
                    let Year:Int = Int((try div?.attr("data-year"))!)!
                    let date = DateComponents(year: Year, month: Month, day: Day)
                    return date
                }
            }
        }
        catch{
            print("Shite")
        }
        return DateComponents()
    }
}
