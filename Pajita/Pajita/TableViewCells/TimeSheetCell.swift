//
//  TimeSheetCell.swift
//  Pajita
//
//  Created by Zain Ali on 14/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit

class TimeSheetCell: UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMission: UILabel!
    @IBOutlet weak var lblValided: UILabel!
    @IBOutlet weak var lblWorkDays: UILabel!
    @IBOutlet weak var lblLeaves: UILabel!
    @IBOutlet weak var lblSickness: UILabel!
    @IBOutlet weak var lblTotalExpense: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
        
}

extension UILabel {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIView {
   func roundViewCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
