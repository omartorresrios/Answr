//
//  SegueFromBottom.swift
//  QuizApp
//
//  Created by Omar Torres on 10/15/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SegueFromBottom: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.35
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}
