//
//  TimesheetViewController.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireObjectMapper

class TimesheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblWorkdays:UILabel!
    @IBOutlet weak var lblLeaves:UILabel!
    @IBOutlet weak var lblSickness:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var timesheetList:[TimesheetListDTO] = []
    
    var currentMonth = 0
    var currentYear = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        currentYear = formatter.string(from: Date())
        formatter.dateFormat = "M"
        currentMonth = Int(formatter.string(from: Date())) ?? 0
        
        lblDate.text = String(format: "%@ %@", localizeString(text: formatter.string(from: Date())), currentYear)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if timesheetList.count == 0
        {
            getHeaderData()
            getTimeSheets()
        }
        else
        {
            self.tblView.reloadData()
        }
    }
    
    func getHeaderData()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/timesheet/summary/%d?month=%d&resourceId=%d&year=%@", userDetails?.resourceId ?? 0, currentMonth, userDetails?.resourceId ?? 0,currentYear)
            print(URL)
            Alamofire.request(URL, headers: getHeaders()).responseObject { (response: DataResponse<TimesheetSummary>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let timesheetSummary = response.result.value
                
                if timesheetSummary?.totalLeaves != nil
                {
                    self.lblLeaves.text = String(format: "%.01f", timesheetSummary?.totalLeaves ?? "0")
                }
                
                if timesheetSummary?.totalSickness != nil
                {
                    self.lblSickness.text = String(format: "%.01f", timesheetSummary?.totalSickness ?? "0")
                }
                
                if timesheetSummary?.totalWorked != nil
                {
                      self.lblWorkdays.textColor=UIColor.blue;
                    self.lblWorkdays.text = String(format: "%.01f", timesheetSummary?.totalWorked ?? "0")
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
    
    func getTimeSheets()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/timesheet/resource/%d", userDetails?.resourceId ?? 0)

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[TimesheetListDTO]>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let timesheetListDTOArray = response.result.value

                if let timesheetListDTOArray = timesheetListDTOArray
                {
                    for timesheetListDTO in timesheetListDTOArray
                    {
                        self.timesheetList.append(timesheetListDTO)
                    }
                    self.timesheetList = self.timesheetList.sorted(by:  {
                        $0.month! > $1.month! && ($0.year! > $1.year! || $0.year! == $1.year!)
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
        
        return timesheetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell") as? TimeSheetCell {
            
            cell.lblStatus.roundCorners(corners: [.topRight, .bottomLeft], radius: 5.0)
            
            let timesheetDTO: TimesheetListDTO = timesheetList[indexPath.row]
            
            var status = ""
            var color:UIColor!
            
            if timesheetDTO.statusCode == "timesheet-waiting_validation"
            {
                status = localizeString(text: "Pending")
                color = UIColor(red: 47.0/255.0, green: 71.0/255.0, blue: 194.0/255.0, alpha: 1.0)
            }
            else if timesheetDTO.statusCode == "timesheet-draft" || timesheetDTO.statusCode == "timesheet-generated"
            {
              status = localizeString(text: "Draft")
              color = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 56.0/255.0, alpha: 1.0)
            }
            else if timesheetDTO.statusCode == "timesheet-employee-approved"
            {
              status = localizeString(text: "employee_approved")
                color = UIColor.lightGray
            }
            else if timesheetDTO.statusCode == "timesheet-manager-approved"
            {
                status = localizeString(text: "manager_approved")
                color = UIColor(red: 4.0/255.0, green: 174.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            }
            else if timesheetDTO.statusCode == "timesheet-client-approved"
            {
                status = localizeString(text: "client_approved")
                color = UIColor.brown
            }
            else if timesheetDTO.statusCode == "timesheet-client-refused"
            {
                status = localizeString(text: "client_refused")
                color = UIColor.red
            }
            else if timesheetDTO.statusCode == "timesheet-refused"
            {
                status = localizeString(text: "Canceled")
                color = UIColor(red: 232.0/255.0, green: 57.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            }
            
            cell.lblStatus.backgroundColor = color
            cell.lblStatus.text = status
            cell.lblYear.text = String(format: "Timesheet %@ %d", localizeString(text: String(format: "%d",timesheetDTO.month!)), timesheetDTO.year ?? "")
            cell.lblMission.text = String(format: "Mission: %@",timesheetDTO.missionName ?? "")
            
            var presence = 0.0
            
            if timesheetDTO.totalPresence != nil
            {
                presence = (timesheetDTO.totalPresence ?? 0)/8
            }
            
            cell.lblWorkDays.text = String(format: "%.1f", presence)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let timesheetVC = UIStoryboard.main.instantiateViewController(withIdentifier: "EditTimeSheetVC") as! EditTimeSheetVC
        let timesheetListDTO: TimesheetListDTO = timesheetList[indexPath.row]
        timesheetVC.timesheetListDTO = timesheetListDTO
        self.navigationController?.pushViewController(timesheetVC, animated: true)
    }
}

