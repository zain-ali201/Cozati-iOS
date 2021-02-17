//
//  MenuViewController.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit

var menuVC: MenuViewController!

class MenuViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        menuVC = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutBtnAction(_ sender: Any)
    {
        let loginVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func timesheetBtnAction(_ sender: Any)
    {
        let timesheetVC = UIStoryboard.main.instantiateViewController(withIdentifier: "TimesheetViewController") as! TimesheetViewController
        self.navigationController?.pushViewController(timesheetVC, animated: true)
    }
    
    @IBAction func expensesBtnAction(_ sender: Any)
    {
        let expensesListVC = UIStoryboard.main.instantiateViewController(withIdentifier: "ExpensesListVC") as! ExpensesListVC
        self.navigationController?.pushViewController(expensesListVC, animated: true)
    }
    
    @IBAction func leavesBtnAction(_ sender: Any)
    {
        let leavesListVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LeavesListVC") as! LeavesListVC
        self.navigationController?.pushViewController(leavesListVC, animated: true)
    }
    
    @IBAction func profileBtnAction(_ sender: Any)
    {
        let profileVC = UIStoryboard.main.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

