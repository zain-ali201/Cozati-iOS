//
//  ExpensesListVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MessageUI

class ProfileViewController: UIViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnPhone: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblName.text = String(format: "%@ %@", userDetails?.firstName ?? "", userDetails?.lastName ?? "")
        
        var role = userDetails?.roleNamestring ?? ""
        
        if languageCode == "fr"
        {
            if userDetails?.roleNamestring == "employee" || userDetails?.roleNamestring == "Employee" || userDetails?.roleNamestring == "EMPLOYEE"
            {
                role = "Collaborateur"
            }
        }
        
        if !role.isEmpty
        {
            lblDesignation.text = role
        }
        
        btnMail.setTitle(userDetails?.email, for: .normal)
//        btnPhone.setTitle(userDetails?.email, for: .normal)
    }
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editBtnAction(_ sender: Any)
    {
        let editProfileVC = UIStoryboard.main.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func phoneBtnAction(_ sender: Any)
    {
        let phoneNumber = btnPhone.titleLabel?.text
        
        if let phoneURL = URL(string: ("tel://" + phoneNumber!))
        {
            let alert = UIAlertController(title: ("Call " + phoneNumber! + "?"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                UIApplication.shared.openURL(phoneURL)
            }))
      
            alert.addAction(UIAlertAction(title: localizeString(text: "Cancel"), style: .cancel, handler: nil))
                    
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func mailBtnAction(_ sender: Any)
    {
        let email = btnMail.titleLabel?.text ?? ""
        
        if !email.isEmpty
        {
            if MFMailComposeViewController.canSendMail()
            {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([(btnMail.titleLabel?.text ?? "")])

                present(mail, animated: true)
            }
            else
            {
                // show failure alert
            }
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true)
    }
}

