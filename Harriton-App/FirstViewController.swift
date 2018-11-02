//
//  firstViewController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/25/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var letterDay: UILabel!
    
    var formattedDate = ""
    
    var day = 0
    var month = 0
    var year = 1999
    
    var urlContent = ""
    
    var letterDayImport:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        day = Calendar.current.component(.day, from: Date())
        month = Calendar.current.component(.month, from: Date())
        year = Calendar.current.component(.year, from: Date())
        
        formattedDate = "\(year)-\(month)-\(day)"
        
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            self.getLetterDayData()
            print(self.urlContent)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLetterDayData() {
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
        }
        //print(urlContent)
    }
}

    extension StringProtocol where Index == String.Index {
        func index(of string: Self, options: String.CompareOptions = []) -> Index? {
            return range(of: string, options: options)?.lowerBound
        }
        func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
            return range(of: string, options: options)?.upperBound
        }
        func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
            var result: [Index] = []
            var start = startIndex
            while start < endIndex,
                let range = self[start..<endIndex].range(of: string, options: options) {
                    result.append(range.lowerBound)
                    start = range.lowerBound < range.upperBound ? range.upperBound :
                        index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
            }
            return result
        }
        func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
            var result: [Range<Index>] = []
            var start = startIndex
            while start < endIndex,
                let range = self[start..<endIndex].range(of: string, options: options) {
                    result.append(range)
                    start = range.lowerBound < range.upperBound ? range.upperBound :
                        index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
            }
            return result
        }
    }
