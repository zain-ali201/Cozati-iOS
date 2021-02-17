//
//  EditTimeSheetVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireObjectMapper

class EditTimeSheetVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // MARK: - Properties
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var calendarView: UIView!
    
    @IBOutlet weak var lblMission: UILabel!
    @IBOutlet weak var lblWorkedHours: UILabel!
    @IBOutlet weak var lblExtraHoursDay: UILabel!
    @IBOutlet weak var lblExtraHoursNight: UILabel!
    @IBOutlet weak var lblLeaveSickness: UILabel!
    
    @IBOutlet weak var btnSubmit:UIButton!
    
    var timesheetListDTO: TimesheetListDTO!
    var timesheetDTO: TimesheetDTO!
    
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if languageCode == "fr"
        {
            btnSubmit.setImage(UIImage(named: "submit_fr"), for: .normal)
        }
        
        if timesheetListDTO.statusCode == "timesheet-draft" || timesheetListDTO.statusCode == "timesheet-generated"
        {
            btnSubmit.alpha = 1
        }
        else
        {
            btnSubmit.alpha = 0
        }

        lblMission.text = String(format: "%@", timesheetListDTO.missionName ?? "")
        
        var presence = 0.0
        
        if timesheetListDTO.totalPresence != nil
        {
            presence = (timesheetListDTO.totalPresence ?? 0)/8
        }
        
        lblWorkedHours.text = String(format: "%.1f", presence)
        lblExtraHoursDay.text = String(format: "%.1f", timesheetListDTO.totalExtraHours ?? 0)
        lblExtraHoursNight.text = String(format: "%.1f", timesheetListDTO.totalExtraHourNight ?? 0)
        lblLeaveSickness.text = "0"
        createMonthView()
        getTimeSheets()
    }
    
//  MARK: - Functions
    func getTimeSheets()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/timesheet/edit-data/%d/%d", timesheetListDTO.timesheetId!, userDetails!.resourceId ?? 0)

            Alamofire.request(URL, headers: getHeaders()).responseObject { (response: DataResponse<TimesheetDTO>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let timesheetDTO = response.result.value

                if let timesheetDTO = timesheetDTO
                {
                    self.timesheetDTO = timesheetDTO
                    
                    timesheetDTO.lineArray = timesheetDTO.lineArray.sorted(by: { $0.day! < $1.day! })
                    self.createMonthView()
                }
                
                if timesheetDTO != nil
                {
                    var presence = 0.0
                    var standtime = 0.0
                    var extraNight = 0.0
                    var extraDays = 0.0
                    
                    for lineDTO in timesheetDTO!.lineArray
                    {
                        presence += lineDTO.presence ?? 0.0
                        standtime += lineDTO.nightShift ?? 0.0
                        extraNight += lineDTO.extraWorkNight ?? 0.0
                        extraDays += lineDTO.extraWorkDay ?? 0.0
                    }
                    
                    var totalPresence = 0.0
                    
                    if presence > 0
                    {
                        totalPresence = presence/8
                    }
                    
                    self.lblWorkedHours.text = String(format: "%.1f", totalPresence)
                    self.lblExtraHoursNight.text = String(format: "%.1f", extraNight)
                    self.lblExtraHoursDay.text = String(format: "%.1f", extraDays)
                    self.lblLeaveSickness.text = String(format: "%.1f", standtime)
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
    
// MARK: - Calendar Functions
    func createMonthView()
    {
        for view in calendarView.subviews
        {
            view.removeFromSuperview()
        }
        
        let screenSize = UIScreen.main.bounds.size.width
        
        let cellWidth:Double = Double((screenSize-42)/7)
        
        let daysView = UIView()
        daysView.frame = CGRect(x: 0, y: 0, width: calendarView.frame.width, height: 30)
        daysView.backgroundColor = .clear
        
        let lblSun = UILabel()
        lblSun.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 30)
        lblSun.backgroundColor = .clear
        lblSun.text = localizeString(text: "SUN")
        lblSun.textColor = UIColor(red: 232.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        lblSun.tag = 1
        lblSun.textAlignment = .center
        lblSun.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblMon = UILabel()
        lblMon.frame = CGRect(x: cellWidth, y: 0, width: cellWidth, height: 30)
        lblMon.backgroundColor = .clear
        lblMon.text = localizeString(text: "MON")
        lblMon.tag = 2
        lblMon.textAlignment = .center
        lblMon.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblTue = UILabel()
        lblTue.frame = CGRect(x: cellWidth*2, y: 0, width: cellWidth, height: 30)
        lblTue.backgroundColor = .clear
        lblTue.text = localizeString(text: "TUE")
        lblTue.tag = 3
        lblTue.textAlignment = .center
        lblTue.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblWed = UILabel()
        lblWed.frame = CGRect(x: cellWidth*3, y: 0, width: cellWidth, height: 30)
        lblWed.backgroundColor = .clear
        lblWed.text = localizeString(text: "WED")
        lblWed.tag = 4
        lblWed.textAlignment = .center
        lblWed.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblThu = UILabel()
        lblThu.frame = CGRect(x: cellWidth*4, y: 0, width: cellWidth, height: 30)
        lblThu.backgroundColor = .clear
        lblThu.text = localizeString(text: "THU")
        lblThu.tag = 5
        lblThu.textAlignment = .center
        lblThu.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblFri = UILabel()
        lblFri.frame = CGRect(x: cellWidth*5, y: 0, width: cellWidth, height: 30)
        lblFri.backgroundColor = .clear
        lblFri.text = localizeString(text: "FRI")
        lblFri.tag = 6
        lblFri.textAlignment = .center
        lblFri.font = UIFont.systemFont(ofSize: 14.0)
        
        let lblSat = UILabel()
        lblSat.frame = CGRect(x: cellWidth*6, y: 0, width: cellWidth, height: 30)
        lblSat.backgroundColor = .clear
        lblSat.text = localizeString(text: "SAT")
        lblSat.tag = 7
        lblSat.textAlignment = .center
        lblSat.font = UIFont.systemFont(ofSize: 14.0)
        
        daysView.addSubview(lblSun)
        daysView.addSubview(lblMon)
        daysView.addSubview(lblTue)
        daysView.addSubview(lblWed)
        daysView.addSubview(lblThu)
        daysView.addSubview(lblFri)
        daysView.addSubview(lblSat)
        calendarView.addSubview(daysView)
        
//        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM yyyy"
        
        let dateStr = String(format: "%d %d", timesheetListDTO.month ?? 0, timesheetListDTO.year ?? 0)
//        let dateStr = "April 2019"
        print(dateStr)
        let date = formatter.date(from: dateStr)
        print(date)
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date!)!
        let numDays = range.count
//        print(numDays)
        
        let components = calendar.dateComponents([.year, .month], from: date!)
        let startOfMonth = calendar.date(from: components)
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth!)
        let currentWeekday = calendar.component(.weekday, from: startOfMonth!)
        
        let greyColor:UIColor = UIColor(red: 32.0/255.0, green: 45.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        let blueColor:UIColor = UIColor(red: 44.0/255.0, green: 68.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        
        for view in daysView.subviews
        {
            if view.tag > 1
            {
                let lbl = view as! UILabel
                if lbl.tag == currentWeekday
                {
                    lbl.textColor =  blueColor
                }
                else
                {
                    lbl.textColor =  greyColor
                }
            }
        }
        
        var xAxis = Double((firstWeekday-1)) * cellWidth
        var yAxis = 30.0
        
        for i in 1...numDays
        {
            let dayView = UIView()
            dayView.frame = CGRect(x: xAxis, y: yAxis, width: cellWidth, height: 66)
            dayView.addBorder(side: .bottom, thickness: 0.5, color: UIColor.lightGray)
            
            let dayBtn = UIButton()
            dayBtn.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 66)
            dayBtn.tag = 1000 + i
            
            let lblDay = UILabel()
            lblDay.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 26)
            lblDay.backgroundColor = .white
            lblDay.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            lblDay.text = String(format: "%d", i)
            lblDay.textAlignment = .center
            lblDay.font = UIFont.systemFont(ofSize: 13.0)
            
            dayView.addSubview(lblDay)
            
            let lblLeaves = UILabel()
            lblLeaves.frame = CGRect(x: 0, y: lblDay.frame.height, width: dayView.frame.width, height: 10)
            lblLeaves.backgroundColor = UIColor(red: 247.0/255.0, green: 100.0/255.0, blue: 27.0/255.0, alpha: 1.0)
//            lblLeaves.text = "2"
            lblLeaves.textColor = .white
            lblLeaves.textAlignment = .center
            lblLeaves.font = UIFont.systemFont(ofSize: 10.0)
            
            let lblHours = UILabel()
            lblHours.frame = CGRect(x: 0, y: lblLeaves.frame.origin.y + lblLeaves.frame.height, width: dayView.frame.width, height: 10)
            lblHours.backgroundColor = UIColor(red: 4.0/255.0, green: 174.0/255.0, blue: 121.0/255.0, alpha: 1.0)
//            lblHours.text = "4"
            lblHours.textColor = .white
            lblHours.textAlignment = .center
            lblHours.font = UIFont.systemFont(ofSize: 10.0)
            
            let lblDays = UILabel()
            lblDays.frame = CGRect(x: 0, y: lblHours.frame.origin.y + lblHours.frame.height, width: dayView.frame.width, height: 10)
            lblDays.backgroundColor = UIColor(red: 47.0/255.0, green: 71.0/255.0, blue: 194.0/255.0, alpha: 1.0)
//            lblDays.text = "6"
            lblDays.textColor = .white
            lblDays.textAlignment = .center
            lblDays.font = UIFont.systemFont(ofSize: 10.0)
            
            let lblNights = UILabel()
            lblNights.frame = CGRect(x: 0, y: lblDays.frame.origin.y + lblHours.frame.height, width: dayView.frame.width, height: 10)
            lblNights.backgroundColor = UIColor(red: 223.0/255.0, green: 73.0/255.0, blue: 87.0/255.0, alpha: 1.0)
//            lblNights.text = "8"
            lblNights.textColor = .white
            lblNights.textAlignment = .center
            lblNights.font = UIFont.systemFont(ofSize: 10.0)
            
            if timesheetDTO != nil && timesheetDTO.lineArray.count >= i
            {
                dayBtn.addTarget(self, action: #selector(dayBtnAction(_:)), for: .touchUpInside)
                let lineDTO: LineDTO = timesheetDTO.lineArray[i-1]
                
                if lineDTO.extraWorkNight != nil && lineDTO.extraWorkNight! > 0.0
                {
                    lblNights.text = String(format: "%.1f", lineDTO.extraWorkNight ?? 0)
                    dayView.addSubview(lblNights)
                }
                
                if lineDTO.presence != nil && lineDTO.presence! > 0.0
                {
                    lblDays.text = String(format: "%.1f", lineDTO.presence ?? 0)
                    dayView.addSubview(lblDays)
                }
                
                if lineDTO.extraWorkDay != nil && lineDTO.extraWorkDay! > 0.0
                {
                    lblHours.text = String(format: "%.1f", lineDTO.extraWorkDay ?? 0)
                    dayView.addSubview(lblHours)
                }
                
                if lineDTO.nightShift != nil && lineDTO.nightShift! > 0.0
               {
                    lblLeaves.text = String(format: "%.1f", lineDTO.nightShift ?? 0)
                    dayView.addSubview(lblLeaves)
                }
            }
            
            xAxis += cellWidth
            
            var cells = 6.0
            
            if screenSize > 375
            {
                cells = 7.0
            }

            if xAxis >= (cellWidth*cells)
            {
                xAxis = 0.0
                yAxis += 66
            }
            
            dayView.addSubview(dayBtn)
            calendarView.addSubview(dayView)
        }
    }

    // MARK: - Actions
    
    @IBAction func submitBtnAction(_ sender: Any)
    {
        let signatureVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SignatureVC") as! SignatureVC
        signatureVC.timesheetID = self.timesheetDTO.timesheetId!
        self.navigationController?.pushViewController(signatureVC, animated: true)
    }
    
    @IBAction func dayBtnAction(_ button: UIButton)
    {
        if timesheetListDTO.statusCode == "timesheet-draft" || timesheetListDTO.statusCode == "timesheet-generated"
        {
            let lineDTO = timesheetDTO.lineArray[button.tag - 1001]
                    
            let holiday = lineDTO.holiday ?? false
            let weekend = lineDTO.weekend ?? false
            
    //        if weekend || holiday
    //        {
    //            self.view.makeToast(localizeString(text:"holiday"))
    //        }
    //        else
    //        {
                let addVC = UIStoryboard.main.instantiateViewController(withIdentifier: "AddTimeSheetVC") as! AddTimeSheetVC
                addVC.lineDTO = lineDTO
                addVC.day = button.tag - 1000
                addVC.month = timesheetDTO.month ?? 0
                addVC.year = timesheetDTO.year ?? 0
                addVC.editTimesheetVC = self
                self.present(addVC, animated: true, completion: nil)
    //        }
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") as? FileCell {
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

    }
}
