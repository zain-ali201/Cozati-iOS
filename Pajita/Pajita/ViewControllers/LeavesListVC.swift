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

class LeavesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblNormal:UILabel!
    @IBOutlet weak var lblExtra:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var total = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        let month = formatter.string(from: Date())
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: Date())
        lblDate.text = String(format: "%@ %@ %@", localizeString(text: "balance"), localizeString(text: month), year)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        getLeaveSummary()
        getAllLeaves()
    }
    
    func getLeaveSummary()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/leave/leave-summary/%d", userDetails?.resourceId ?? 0)
            print(URL)
            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[LeaveSummaryDTO]>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let leaveSummaryDTOArray = response.result.value

                if let leaveSummaryDTOArray = leaveSummaryDTOArray
                {
                    if leaveSummaryDTOArray.count > 0
                    {
                        self.lblNormal.text = String(format: "%d", leaveSummaryDTOArray[0].totalBalance ?? 0)
                        self.lblExtra.text = String(format: "%d", leaveSummaryDTOArray[1].totalBalance ?? 0)
                    }
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
    
    func getAllLeaves()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/leave/resource/%d", userDetails?.resourceId ?? 0)

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[LeaveDTO]>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let leaveDTOArray = response.result.value

                if let leaveDTOArray = leaveDTOArray
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    leaveList = []
                    self.total = 0.0
                    for leaveDTO in leaveDTOArray
                    {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let startDate = formatter.date(from: leaveDTO.startDate!)
                        let endDate = formatter.date(from: leaveDTO.endDate!)
                        formatter.dateFormat = "MM"
                        let startMonthStr = formatter.string(from: startDate!)
                        let endMonthStr = formatter.string(from: endDate!)
                        let currentMonthStr = formatter.string(from: Date())
                        
                        let startMonth = Int(startMonthStr) ?? 0
                        let endMonth = Int(endMonthStr) ?? 0
                        let currentMonth = Int(currentMonthStr) ?? 0
                        
                        if startMonth > 0 && endMonth > 0
                        {
                            if startMonth == currentMonth && endMonth == currentMonth
                            {
                                self.total += leaveDTO.total ?? 0.0
                            }
                        }
                        
                        leaveList.append(leaveDTO)
                        leaveList = leaveList.sorted(by: { $0.leaveId! > $1.leaveId! })
                    }
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
    
    func deleteLeaveAPIRequest(leaveId: Int) {

        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        switch Reachability.isConnectedToNetwork() {
        case true:
            let URL = backendURL + String(format: "/leave/cancel/%d", userDetails?.resourceId ?? 0)
            
            Alamofire.request(URL, method: .post, parameters: ["leaveId": leaveId], encoding: JSONEncoding.default,  headers: getHeaders())
                .responseJSON(completionHandler: { (response) in
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    
                    guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
                    
                    print("success")
                    self.getLeaveSummary()
                    self.getAllLeaves()
                })
            
        case false:
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
    
    @IBAction func addLeaveBtnAction(_ sender: Any)
    {
        let leavesVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LeavesCreationVC") as! LeavesCreationVC
        leavesVC.normalLeaves = lblNormal.text!
        leavesVC.extraLeaves = lblExtra.text!
        self.navigationController?.pushViewController(leavesVC, animated: true)
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
    
    
    @objc func deleteDraftLeave(sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: leaveList[sender.tag].startDate!)
        let endDate = formatter.date(from: leaveList[sender.tag].endDate!)
        formatter.dateFormat = "dd/MM/yyyy"
        let startDateStr = formatter.string(from: startDate!)
        let endDateStr = formatter.string(from: endDate!)
        
        let alert = UIAlertController(title: String(format: "%@ %@ %@ %@", localizeString(text: "from"), startDateStr, localizeString(text: "to"), endDateStr) , message: localizeString(text: "delete_confirmation"), preferredStyle: .alert)
                
        alert.addAction(UIAlertAction(title: localizeString(text: "yes") , style: .default, handler: { action in
            guard let leaveId = leaveList[sender.tag].leaveId else { return }
            print(leaveList[sender.tag].total)
            self.deleteLeaveAPIRequest(leaveId: leaveId)
        }))
        
        alert.addAction(UIAlertAction(title: localizeString(text: "no"), style: .cancel, handler: { action in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return leaveList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell") as? TimeSheetCell {
            
            cell.lblStatus.roundCorners(corners: [.topRight, .bottomLeft], radius: 5.0)
            
            let leaveDTO = leaveList[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startDate = formatter.date(from: leaveDTO.startDate!)
            let endDate = formatter.date(from: leaveDTO.endDate!)
            formatter.dateFormat = "dd/MM/yyyy"
            let startDateStr = formatter.string(from: startDate!)
            let endDateStr = formatter.string(from: endDate!)
            
            var status = ""
            var color:UIColor!
            cell.deleteBtn.isHidden = true
            if leaveDTO.statusCode == "leave-draft"
            {
                status = localizeString(text: "Draft")
                color = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 56.0/255.0, alpha: 1.0)
                cell.deleteBtn.isHidden = false
                cell.deleteBtn.tag = indexPath.row
                cell.deleteBtn.addTarget(self, action: #selector(self.deleteDraftLeave(sender:)), for: .touchUpInside)
            }
            else if leaveDTO.statusCode == "leave-approved"
            {
                status = localizeString(text: "Approved")
                color = UIColor(red: 4.0/255.0, green: 174.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            }
            else if leaveDTO.statusCode == "leave-refused"
            {
                status = localizeString(text: "Refused")
                color = UIColor(red: 232.0/255.0, green: 57.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            }
            else if leaveDTO.statusCode == "leave-canceled"
            {
                status = localizeString(text: "Cancelled")
                color = UIColor.black
            }
            
            cell.lblStatus.backgroundColor = color
            cell.lblStatus.text = status
            cell.lblYear.text = String(format: "%@ %@ %@ %@", localizeString(text: "from"), startDateStr, localizeString(text: "to"), endDateStr)
            cell.lblMission.text = String(format: "%@: %.1f", localizeString(text: "total"),leaveDTO.total ?? 0)
            cell.lblWorkDays.text = localizeString(text: leaveDTO.typeCode ?? "")
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //let timesheetVC = UIStoryboard.main.instantiateViewController(withIdentifier: "EditTimeSheetVC") as! EditTimeSheetVC
        //self.navigationController?.pushViewController(timesheetVC, animated: true)
    }
        
}

