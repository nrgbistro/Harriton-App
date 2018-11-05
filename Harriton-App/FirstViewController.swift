//
//  firstViewController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/25/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit
import SwiftSoup

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
        
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            self.getLetterDayData()
            
            do{
                let doc = try SwiftSoup.parse(self.urlContent)
                do{
                    let element = try doc.select("div.fsCalendarToday").first()
                    do{
                        if(try element?.select("a.fsCalendarEventTitle") == nil){
                            self.letterDay.font = self.letterDay.font.withSize(35)
                            self.letterDay.text = "No School!"
                        }
                        else{
                            let link = try element?.select("a.fsCalendarEventTitle")
                            do{
                                self.letterDayImport = (try link?.text())!
                                DispatchQueue.main.async {
                                    self.letterDay.font = self.letterDay.font.withSize(35)
                                    self.letterDay.text = self.letterDayImport
                                }
                            }
                        }
                    }
                }
            }catch{
                print(error)
            }
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
    }
}
