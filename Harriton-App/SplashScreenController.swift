//
//  SplashScreenController.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 10/24/18.
//  Copyright © 2018 Nolan Gelinas. All rights reserved.
//

import UIKit
import Hero

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var Logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let screenFrame = UIScreen.main.bounds
        
        let vc1 = SplashScreenViewController()
        let vc2 = tabBarController
        
        vc1.hero.isEnabled = true
        vc2?.hero.isEnabled = true
        
        vc1.hero.modalAnimationType = .autoReverse(presenting: .pull(direction: .right))
        
        present(vc2!, animated: true, completion: nil)
        
        
        
        /*anim{(settings) -> animClosure in
            settings.duration = 0.01
            settings.ease = .easeInOutQuart
            return {
                //self.Logo.frame.origin.x = screenFrame.minX - self.Logo.bounds.maxX - 5
            }
        }
        
        .then{(settings) -> animClosure in
            settings.duration = 0.9
            settings.ease = .easeInOutQuart
            return {
                self.Logo.frame.origin.x = screenFrame.minX - self.Logo.bounds.maxX - 5
            }
        }
        .callback {
            self.switchView()
        }
        .then{(settings) -> animClosure in
            settings.duration = 0.8
            settings.ease = .easeOutBack
            return {
                self.Logo.frame.origin.x = (screenFrame.maxX + 500)
            }
        }
        
        self.Logo.frame.origin.x = screenFrame.midX - (self.Logo.frame.width / 2)
        
        
        UIView.animate(withDuration: 1, animations: {
            self.Logo.frame.origin.x = screenFrame.minX - self.Logo.bounds.maxX
        }){(true) in
            self.switchView()
            UIView.animate(withDuration: 1, animations: {
                self.Logo.frame.origin.x = (screenFrame.maxX + 500)
            })
        }*/
    }
    
    func switchView() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.performSegue(withIdentifier: "splashScreen", sender: self )
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
