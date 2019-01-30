//
//  AlarmViewController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/25/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}


func firstLaunch() -> Bool{
    let defaults = UserDefaults.standard
    if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
        return false
    }else{
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        return true
    }
}
