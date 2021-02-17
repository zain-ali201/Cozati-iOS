//
//  UIStoryboard+Helper.swift
//  Qoyod
//
//  Created by Sharjeel Ahmad on 29/11/2017.
//  Copyright © 2017 Qoyod. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    static var user: UIStoryboard {
        return UIStoryboard(name: "User", bundle: Bundle.main)
    }
}
