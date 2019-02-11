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
    @IBOutlet weak var todaysDateLabel: UILabel!
    
    var CurrentLMSDUrlContent = ""
    var VariableLMSDUrlContent = ""
    var todaysLetterDay = ""
    var nextLetterDay = ""
    let regionNY = Region(calendar: Calendars.gregorian, zone: Zones.americaNewYork, locale: Locales.englishUnitedStates)
    
    
    
    // --------
    // Main runner function
    // --------
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = DateInRegion(region: regionNY)
        if(date.weekday == 7 || date.weekday == 1){
            todayLetterDayLabel.text = "No School Today"
            self.todaysDateLabel.text = "\(date.weekdayName(.`default`))\n\(date.month)/\(date.day)/\(date.year)"
        }
        else{
            todayLetterDayLabel.text = getTodaysLetterDay()
        }
        nextLetterDayLabel.text = getNextLetterDay()
        
        
        // --------
        // OLD IMPLEMENTATION OF OFFLINE FEATURES
        // --------
        
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
    // Gets todays letter day
    // --------
    func getTodaysLetterDay() -> String {
        let date = DateInRegion(region: regionNY)
        if(todaysLetterDay != ""){
            return todaysLetterDay
        }
        
        if(CurrentLMSDUrlContent == ""){
            let downloadQueue = DispatchGroup()
            
            downloadQueue.enter()
            DispatchQueue(label: "download-content", qos: .utility).async {
                let date = DateInRegion(region: self.regionNY)
                self.CurrentLMSDUrlContent = self.downloadLMSDData(Year: date.year, Month: date.month, Day: date.day)
                downloadQueue.leave()
            }
            downloadQueue.wait()
        }
        
        let parseQueue = DispatchGroup()
        
        parseQueue.enter()
        
        DispatchQueue(label: "parse-html-content", qos: .utility).async {
            self.todaysLetterDay = self.parseData(dataToParse: self.CurrentLMSDUrlContent, Day: DateInRegion(region: self.regionNY).day, Month: (DateInRegion(region: self.regionNY).month - 1))
            parseQueue.leave()
        }
        parseQueue.wait()
        
        self.todaysDateLabel.text = "\(date.weekdayName(.`default`))\n\(date.month)/\(date.day)/\(date.year)"
        
        return todaysLetterDay
    }
    
    
    
    // --------
    // Gets the next letter day (continues to find next day until it has a letter day value)
    // --------
    func getNextLetterDay() -> String {
        if(nextLetterDay != ""){
            return nextLetterDay
        }
        
        if(VariableLMSDUrlContent == ""){
            if(CurrentLMSDUrlContent != ""){
                VariableLMSDUrlContent = CurrentLMSDUrlContent
            }
            else{
                let downloadQueue = DispatchGroup()
                
                downloadQueue.enter()
                DispatchQueue(label: "download-content", qos: .utility).async {
                    let date = DateInRegion(region: self.regionNY)
                    self.VariableLMSDUrlContent = self.downloadLMSDData(Year: date.year, Month: date.month, Day: date.day)
                    downloadQueue.leave()
                }
                downloadQueue.wait()
            }
        }
        
        var newDate = DateInRegion(region: regionNY)
        
        while(nextLetterDay == "" || nextLetterDay == "No School Today"){
            newDate = newDate + 1.days
            if(newDate >= getLastDateOnCalendar(dataToParse: VariableLMSDUrlContent)){
                VariableLMSDUrlContent = downloadLMSDData(Year: newDate.year, Month: newDate.month, Day: newDate.day)
            }
            self.nextLetterDay = self.parseData(dataToParse: self.VariableLMSDUrlContent, Day: newDate.day, Month: (newDate.month - 1))
        }
        
        self.nextSchoolDateLabel.text = "\(newDate.weekdayName(.`default`))\n\(newDate.month)/\(newDate.day)/\(newDate.year)"
        return nextLetterDay
    }
    
    
    
    // --------
    // Connects to harriton website, and saves its HTML to LMSDUrlContent
    // --------
    func downloadLMSDData(Year:Int, Month:Int, Day:Int) -> String {
        let myURLString = "https://www.lmsd.org/harritonhs/campus-life/letter-day?cal_date=\(Year)-\(Month)-\(Day)"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) is not a valid URL")
            return ""
        }
        do {
            return try String(contentsOf: myURL, encoding: .ascii)
        } catch {
            print("oh boi")
            return ""
        }
    }


    // --------
    // Takes data input, selected day and month, and returns the letter day from that day
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

    
    func getLastDateOnCalendar(dataToParse:String) -> DateInRegion {
        do{
            let doc = try SwiftSoup.parse(dataToParse)
            do{
                let div = try doc.select("div.fsCalendarDate").last()
                do{
                    let Day:Int = Int((try div?.attr("data-day"))!)!
                    let Month:Int = Int((try div?.attr("data-month"))!)! + 1
                    let Year:Int = Int((try div?.attr("data-year"))!)!
                    return DateInRegion(components: {
                        $0.year = Year
                        $0.month = Month
                        $0.day = Day
                    })!
                }
            }
        }
        catch{
            print("Shite")
        }
        return DateInRegion(region: regionNY)
    }
}
