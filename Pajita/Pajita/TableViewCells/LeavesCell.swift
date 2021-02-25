//
//  TimeSheetCell.swift
//  Pajita
//
//  Created by Zain Ali on 14/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit

class LeavesCell: UITableViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnMorning: UIButton!
    @IBOutlet weak var btnAfternoon: UIButton!
    
    var morningCheckboxAction: (()->())?
    var afternoonCheckboxAction: (()->())?
    
    @IBAction func morningCheckboxAction(_ sender: Any) {
        self.morningCheckboxAction?()
    }
    
    @IBAction func afternoongCheckboxAction(_ sender: Any) {
        self.afternoonCheckboxAction?()
    }
}
