//
//  ExpensesListVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireObjectMapper

extension NumberFormatter {
    convenience init(style: Style) {
        self.init()
        self.numberStyle = style
    }
}
extension Formatter {
    static let currency = NumberFormatter(style: .currency)
}
extension FloatingPoint {
    var currency: String {
        return Formatter.currency.string(for: self) ?? ""
    }
}

class ExpensesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblRequested:UILabel!
    @IBOutlet weak var lblValided:UILabel!
    @IBOutlet weak var lblNBExpense:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var totalExpense = 0.0
    var allowedExpense = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        lblDate.text = formatter.string(from: Date())
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        if expenseList.count == 0
//        {
            getAllExpenses()
//        }
//        else
//        {
//            self.tblView.reloadData()
//        }
    }
    
    func getAllExpenses()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/expense-summary/resource/%d", userDetails?.resourceId ?? 0)

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[ExpenseDTO]>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let expenseDTOArray = response.result.value

                if var expenseDTOArray = expenseDTOArray
                {
                    expenseDTOArray = expenseDTOArray.sorted(by: { $0.month! > $1.month! && ($0.year! > $1.year! || $0.year! == $1.year!)})
                    
                    expenseList = []
                    var index = 0
                    for expenseDTO in expenseDTOArray
                    {
                        if index > 0
                        {
                            expenseList.append(expenseDTO)
                        }
                        index += 1
                    }
                    
                    let formatter = NumberFormatter()
                    formatter.locale = Locale.init(identifier: "fr_BE")
                    formatter.numberStyle = .currency
                    
                    if expenseDTOArray.count > 0
                    {
                        let expenseDTO = expenseDTOArray[0]
                        if let amount = formatter.string(from: (expenseDTO.totalAmount ?? 0) as NSNumber) {
                            self.lblRequested.text = amount
                        }
                        
                        if let amount = formatter.string(from: (expenseDTO.validedAmount ?? 0) as NSNumber) {
                            self.lblValided.text = amount
                        }
                        
//                        if let expense = formatter.string(from: (expenseDTO.totalExpense ?? 0) as NSNumber) {
                        self.lblNBExpense.text = String(format: "%.2f", expenseDTO.totalExpense ?? 0)
//                        }
                    }
                    
                    expenseList = expenseList.sorted(by:  {
                        return ($0.month! > $1.month! || $0.month! == $1.month!) && ($0.year! > $1.year!)
                    })
                    
                    expenseList = expenseList.sorted(by:  {
                        return ($0.year! > $1.year!)
                    })

                    self.tblView.reloadData()
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.view.makeToast(localizeString(text: "internet"))
            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addExpenseBtnAction(_ sender: Any)
    {
        let expenseVC = UIStoryboard.main.instantiateViewController(withIdentifier: "ExpenseCreationVC") as! ExpenseCreationVC
        self.navigationController?.pushViewController(expenseVC, animated: true)
    }
    
    @IBAction func addBtnAction(_ sender: Any)
    {
        let alert = UIAlertController(title: nil , message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localizeString(text: "leaves") , style: .default, handler: { action in
            alert.dismiss(animated: false, completion: nil)
            
            let leavesVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LeavesCreationVC") as! LeavesCreationVC
            self.navigationController?.pushViewController(leavesVC, animated: true)
            
        }))
        
//        alert.addAction(UIAlertAction(title: localizeString(text: "training") , style: .default, handler: { action in
//            alert.dismiss(animated: false, completion: nil)
//            
//        }))
        
        alert.addAction(UIAlertAction(title: localizeString(text: "expense") , style: .default, handler: { action in
            let expenseVC = UIStoryboard.main.instantiateViewController(withIdentifier: "ExpenseCreationVC") as! ExpenseCreationVC
            self.navigationController?.pushViewController(expenseVC, animated: true)
            
        }))

        alert.addAction(UIAlertAction(title: localizeString(text: "Cancel"), style: .cancel, handler: { action in
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func menuBtnAction(_ sender: Any)
    {
        self.navigationController?.popToViewController(menuVC, animated: true)
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return expenseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell") as? TimeSheetCell {
            
            let expenseDTO = expenseList[indexPath.row]
            
            cell.lblStatus.roundCorners(corners: [.topRight, .bottomLeft], radius: 5.0)
            
            var status = ""
            var color:UIColor!
            
            let expenseStatus = expenseDTO.status?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if expenseStatus == "expense-submitted"
            {
                status = localizeString(text: "Submitted")
                color = UIColor(red: 4.0/255.0, green: 174.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            }
            else if expenseStatus == "expense-approved"
            {
                status = localizeString(text: "Approved")
                color = UIColor.brown
            }
            else if expenseStatus == "expense-refused"
            {
                status = localizeString(text: "Refused")
                color = UIColor(red: 232.0/255.0, green: 57.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            }
            else if expenseStatus == "expense-draft"
            {
                status = localizeString(text: "Draft")
                color = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 56.0/255.0, alpha: 1.0)
            }
            
            cell.lblStatus.backgroundColor = color
            cell.lblStatus.text = status
            cell.lblYear.text = String(format: "%@ %d", localizeString(text: String(format: "%d",expenseDTO.month!)), expenseDTO.year ?? "")
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.init(identifier: "fr_BE")
            formatter.numberStyle = .currency
            
            if let amount = formatter.string(from: (expenseDTO.totalAmount ?? 0) as NSNumber) {
                cell.lblLeaves.text = localizeString(text: "Requested") + ": " + amount
            }
            
            if let amount = formatter.string(from: (expenseDTO.validedAmount ?? 0) as NSNumber) {
                cell.lblValided.text = localizeString(text: "Valided") + ": " + amount
            }
            
//            if let expense = formatter.string(from: (expenseDTO.totalExpense ?? 0) as NSNumber) {
                cell.lblTotalExpense.text = localizeString(text: "total_expense") + ": " + String(format: "%.2f", expenseDTO.totalExpense ?? 0)
//            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}

