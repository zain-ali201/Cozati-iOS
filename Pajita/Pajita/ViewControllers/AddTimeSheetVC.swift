//
//  AddTimeSheetVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD

class AddTimeSheetVC: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var txtPresence:UITextField!
    @IBOutlet weak var txtExtraDays:UITextField!
    @IBOutlet weak var txtExtraNight:UITextField!
    @IBOutlet weak var txtStandtime:UITextField!
    
    var lineDTO: LineDTO!
    
    var day = 0
    var month = 0
    var year = 0
    
    weak var editTimesheetVC: EditTimeSheetVC!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateStr = String(format: "%d/%d/%d", day, month, year)
        let date = formatter.date(from: dateStr)
        formatter.dateFormat = "EEEE dd MMMM"
        lblDate.text = formatter.string(from: date!)
        
        txtPresence.text = String(format: "%.1f", lineDTO.presence ?? 0.0)
              txtExtraDays.text = String(format: "%.1f", lineDTO.extraWorkDay ?? 0.0)
              txtExtraNight.text = String(format: "%.1f", lineDTO.extraWorkNight ?? 0.0)
              txtStandtime.text = String(format: "%.1f", lineDTO.nightShift ?? 0.0)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnAction(_ sender: Any)
    {
        editTimeSheetLine()
    }
    
    func editTimeSheetLine()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        if Reachability.isConnectedToNetwork()
        {
            if !txtPresence.text!.isEmpty
            {
                var amount = txtPresence.text!
                
                if languageCode == "fr"
                {
                    amount = amount.replacingOccurrences(of: ",", with: ".")
                }
                
                lineDTO.presence = Double(amount)
            }
            
            if !txtExtraDays.text!.isEmpty
            {
                var amount = txtExtraDays.text!
                
                if languageCode == "fr"
                {
                    amount = amount.replacingOccurrences(of: ",", with: ".")
                }
                
                lineDTO.extraWorkDay = Double(amount)
            }
            
            if !txtExtraNight.text!.isEmpty
            {
                var amount = txtExtraNight.text!
                
                if languageCode == "fr"
                {
                    amount = amount.replacingOccurrences(of: ",", with: ".")
                }
                
                lineDTO.extraWorkNight = Double(amount)
            }
            
            if !txtStandtime.text!.isEmpty
            {
                var amount = txtStandtime.text!
                
                if languageCode == "fr"
                {
                    amount = amount.replacingOccurrences(of: ",", with: ".")
                }
                
                lineDTO.nightShift = Double(amount)
            }
            
            var request = URLRequest(url: URL(string: String(format: "%@/timesheet/line/%d", backendURL, userDetails!.resourceId!))!)
            print(request)
            request.httpMethod = "PATCH"
            //parameters

            let parameters: [String: Any] = [
                "day": lineDTO.day ?? 0,
                "dayCode": lineDTO.dayCode ?? "",
                "description": lineDTO.descp ?? "",
                "disabled": lineDTO.disabled ?? false,
                "extraWorkDay": lineDTO.extraWorkDay ?? 0.0,
                "extraWorkNight": lineDTO.extraWorkNight ?? 0.0,
                "holiday": lineDTO.holiday ?? false,
                "id": lineDTO.id ?? 0,
                "leave": true,
                "nightShift": lineDTO.nightShift ?? 0.0,
                "presence": lineDTO.presence ?? 0.0,
                "timeSheetId": lineDTO.timesheetId ?? 0,
                "weekend": lineDTO.weekend ?? false
            ]
            
            print(parameters)

            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            request.allHTTPHeaderFields = getHeaders()

            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.view.makeToast(localizeString(text: ""))
                    }
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print(responseString)

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(localizeString(text: "addsheet_error"))
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        self.editTimesheetVC.getTimeSheets()
                        let windowCount = UIApplication.shared.windows.count
                        UIApplication.shared.windows[windowCount-1].makeToast(localizeString(text: "Timesheetu"))
                    }
                }
            }

            task.resume()
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.view.makeToast(localizeString(text: "internet"))
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeypad()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        addToolBar(textField: textField)
    }
    
    func addToolBar(textField: UITextField)
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: localizeString(text:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneBtnAction(button:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @IBAction func doneBtnAction(button: UIButton)
    {
        hideKeypad()
    }
    
    func hideKeypad()
    {
        txtPresence.resignFirstResponder()
        txtExtraDays.resignFirstResponder()
        txtExtraNight.resignFirstResponder()
        txtStandtime.resignFirstResponder()
    }
}

