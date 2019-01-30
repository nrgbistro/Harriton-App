//
//  SlideSegue.swift
//  Harriton-App
//
//  Created by Nolan Gelinas (student HH) on 1/29/19.
//  Copyright © 2019 Nolan Gelinas. All rights reserved.
//

import UIKit

class SlideSegue: UIStoryboardSegue {
    override func perform() {
        slide()
    }
    
    func slide() {
        let srcVc = self.source
        let destVc = self.destination
        
        destVc.view.frame = srcVc.view.frame
        destVc.view.frame.origin.x = -srcVc.view.frame.width
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(destVc.view, aboveSubview: srcVc.view)
        
        UIView.animate(withDuration: 0.4, animations: {
            destVc.view.frame.origin.x = 0
        }){(true) in
            srcVc.present(destVc, animated: false, completion: nil)
        }
        /*
        anim{(settings) -> animClosure in
            settings.duration = 0.3
            settings.ease = .easeInOutCubic
            return {
                destVc.view.frame.origin.x = 0
            }
        }
        .callback {
            srcVc.present(destVc, animated: false, completion: nil)
        }*/
    }
}
