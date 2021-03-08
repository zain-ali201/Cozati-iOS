//
//  ExpenseCreationVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireObjectMapper
import iOSDropDown

class LeavesCreationVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var lblNormal:UILabel!
    @IBOutlet var lblExtra:UILabel!
    @IBOutlet var txtYear:DropDown!
    @IBOutlet var txtLeaveType:DropDown!
    @IBOutlet var txtStartDate:UITextField!
    @IBOutlet var txtEndDate:UITextField!
    @IBOutlet var titleTextView:UITextView!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet weak var tblView:UITableView!
    
    @IBOutlet weak var imgView:UIImageView!
    
    @IBOutlet var datePicker:UIDatePicker!
    @IBOutlet var topConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var tableImgView:UIImageView!
    
    var selectedTxtField:UITextField!
    
    var daysList:[LeaveDayDTO] = []
    
    var pickerDate:Date!
    
    var dateBtnTag = 0
    
    var imagePicker = UIImagePickerController()
    
    var startDateStr = ""
    var endDateStr = ""
    
    var startDate:Date!
    var endDate:Date!
    
    var years:[String] = []
    var leaveTypes:[String] = []
    
    var leaveTypeID = 0
    var year = ""
    
    var normalLeaves = ""
    var extraLeaves = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if languageCode == "fr"
        {
            tableImgView.image = UIImage(named: "table-heading_fr")
        }
        
        lblNormal.text = normalLeaves
        lblExtra.text = extraLeaves
        
        imagePicker.delegate = self
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let currentYear = Int(formatter.string(from: Date())) ?? 0
        
        for i in currentYear...(currentYear+10)
        {
            years.append(String(format: "%d", i))
        }
        
        var count = 0
        
        for selectDTO in leaveTypeArray
        {
            leaveTypes.append(localizeString(text: selectDTO.code!))
            count += 1
        }
        
        txtYear.arrowColor = .lightGray
        txtLeaveType.arrowColor = .lightGray
        
        txtYear.selectedRowColor = UIColor(red: 235/255, green: 242/255, blue: 249/255, alpha: 1)
        txtLeaveType.selectedRowColor = UIColor(red: 235/255, green: 242/255, blue: 249/255, alpha: 1)
      //  txtLeaveType.frame.size.width = 300
        txtYear.optionArray = years
        txtYear.didSelect{(selectedText , index ,id) in
            self.txtYear.text = selectedText
            self.year = selectedText
        }
        
        
        self.txtLeaveType.font = UIFont.init(name: "Arial", size: 13)
        txtLeaveType.optionArray = leaveTypes
        txtLeaveType.didSelect{(selectedText , index ,id) in
            self.txtLeaveType.text = selectedText
            let selectDTO = leaveTypeArray[index]
            self.leaveTypeID = selectDTO.id!
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: 0, height: scrollView.frame.size.height + 340)
    }
    
    func getLeaveDays()
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + String(format: "/leave/dayline?startDate=%@&endDate=%@", startDateStr,endDateStr)

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[LeaveDayDTO]>) in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                let leaveDayDTOArray = response.result.value

                if let leaveDayDTOArray = leaveDayDTOArray
                {
                    self.daysList = []
                    for leaveDayDTO in leaveDayDTOArray
                    {
                        self.daysList.append(leaveDayDTO)
                        self.daysList = self.daysList.sorted(by: { $0.day! < $1.day! })
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
    
    @IBAction func photoBtnAction()
    {
        let alert = UIAlertController(title: nil , message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localizeString(text: "Camera") , style: .default, handler: { action in
            alert.dismiss(animated: false, completion: nil)
            
            self.camera()
        }))
        
        alert.addAction(UIAlertAction(title: localizeString(text: "Gallery") , style: .default, handler: { action in
            alert.dismiss(animated: false, completion: nil)
            self.photoGallery()
        }))
        

        alert.addAction(UIAlertAction(title: localizeString(text: "Cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func photoGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgView.image = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dateBtnAction(_ button: UIButton)
    {
        if button.tag == 1002 && txtStartDate.text!.isEmpty
        {
            self.view.makeToast(localizeString(text: "start_first"))
        }
        else
        {
            dateBtnTag = button.tag
            self.topConstraint.constant = -206
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
              }, completion: { finished in
                
              })
        }
    }
    
    @IBAction func dateCancelBtnAction(_ sender: Any)
    {
        self.topConstraint.constant = 40
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
          }, completion: { finished in
            
          })
    }
    
    @IBAction func saveBtnAction(_ sender: Any)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        pickerDate = datePicker.date
        
        if dateBtnTag == 1001
        {
            startDate = pickerDate
            txtStartDate.text = formatter.string(from: pickerDate)
            formatter.dateFormat = "yyyy-MM-dd"
            startDateStr = formatter.string(from: pickerDate)
        }
        else if dateBtnTag == 1002
        {
            endDate = pickerDate
            txtEndDate.text = formatter.string(from: pickerDate)
            formatter.dateFormat = "yyyy-MM-dd"
            endDateStr = formatter.string(from: pickerDate)
            daysList = []
            getLeaveDays()
        }
        
        self.topConstraint.constant = 40
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
          }, completion: { finished in
            
          })
    }
    
    @IBAction func cancelBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnAction(_ sender: Any)
    {
        if (txtYear.text?.isEmpty)!
        {
            self.view.makeToast(localizeString(text: "select_year."))
        }
        else if (txtLeaveType.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "leave_type."))
        }
        else if (txtStartDate.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "start"))
        }
        else if (txtEndDate.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "end"))
        }
//        else if (titleTextView.text?.isEmpty)!
//        {
//          self.view.makeToast(localizeString(text: "title"))
//        }
//        else if imgView.image == nil
//        {
//          self.view.makeToast("Please attach file with leave.")
//        }
        else
        {
            DispatchQueue.main.async {
              MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            if Reachability.isConnectedToNetwork()
            {
                var strBase64 = ""
                
                if imgView.image != nil
                {
                    let image = imgView.image!.resizedImageWithinRect(rectSize: CGSize(width: 300, height: 150))
                    let imageData:Data = image.jpegData(compressionQuality: 0.5)!
                    strBase64 = "data:image/jpg;base64," + imageData.base64EncodedString(options: .lineLength64Characters)
                }
                
                let totalLeaves = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
                print(totalLeaves+1)
                
                var dayDictList: [[String: Any]] = []
                
                for leaveDayDTO in daysList
                {
                    let leaveDay:[String: Any]  = [
                        "afternoonValue": leaveDayDTO.afternoonValue ?? 0,
                        "date": leaveDayDTO.date ?? "",
                        "day": leaveDayDTO.day ?? 0,
                        "dayCode": leaveDayDTO.dayCode ?? "",
                        "holyday": leaveDayDTO.holyday ?? false,
                        "id": leaveDayDTO.id ?? 0,
                        "month": leaveDayDTO.month ?? 0,
                        "morningValue": leaveDayDTO.morningValue ?? 0,
                        "weekend": leaveDayDTO.weekend ?? 0,
                        "year": leaveDayDTO.year ?? 0
                    ]
                    dayDictList.append(leaveDay)
                }
                
                let parameters:[String: Any] = [
                    "dayList": dayDictList,
                    "endDate": endDateStr,
                    "resourceId": userDetails?.resourceId ?? 0,
                    "startDate": startDateStr,
                    "statusId": 0,
                    "title": titleTextView.text ?? "",
                    "total": totalLeaves+1,
                    "typeId": leaveTypeID,
                    "year": year,
                    "fileData": strBase64.isEmpty ? "" : strBase64]
                
                print(parameters)
                
                var request = URLRequest(url: URL(string: String(format: "%@/leave/resource/%d", backendURL, userDetails?.resourceId ?? 0))!)
                print(request)
                request.httpMethod = "POST"
                
                request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
                request.allHTTPHeaderFields = getHeaders()


                let task = URLSession.shared.dataTask(with: request) { data, response, error in

                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            self.view.makeToast(localizeString(text: "Unable to add the leave. Please try again or contact administrator."))
                        }
                        return
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print(responseString)

//                    if let httpStatus = response as? HTTPURLResponse, (httpStatus.statusCode != 200 || httpStatus.statusCode != 201)
//                    {
//                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
//
//                        DispatchQueue.main.async {
//                            self.view.makeToast(localizeString(text: "wrong"))
//                        }
//                    }
//                    else
//                    {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            let windowCount = UIApplication.shared.windows.count
                            UIApplication.shared.windows[windowCount-1].makeToast("Leave added successfully.")
                        }
//                    }
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
    }
    
    @IBAction func addBtnAction(_ sender: Any)
    {
        let alert = UIAlertController(title: nil , message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localizeString(text: "leaves") , style: .default, handler: { action in
            alert.dismiss(animated: false, completion: nil)
            
        }))
        
//        alert.addAction(UIAlertAction(title: localizeString(text: "training") , style: .default, handler: { action in
//            alert.dismiss(animated: false, completion: nil)
//            
//        }))
        
        alert.addAction(UIAlertAction(title: localizeString(text: "expense") , style: .default, handler: { action in
            alert.dismiss(animated: false, completion: nil)
            
        }))

        alert.addAction(UIAlertAction(title: localizeString(text: "Cancel"), style: .cancel, handler: { action in
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func menuBtnAction(_ sender: Any)
    {
        self.navigationController?.popToViewController(menuVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeypad()
    }
    
    @IBAction func doneBtnAction(button: UIButton)
    {
        hideKeypad()
    }
    
    func hideKeypad()
    {
        txtYear.resignFirstResponder()
        txtLeaveType.resignFirstResponder()
        titleTextView.resignFirstResponder()
        
        if selectedTxtField != nil
        {
            selectedTxtField.resignFirstResponder()
        }
    }
    
    func addToolBartextView(textField: UITextView)
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
    
    // MARK: - TextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        selectedTxtField = textField
        addToolBar(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.tag >= 2000
        {
            let dayLeaveDTO = daysList[textField.tag - 2000]
            
            if !textField.text!.isEmpty
            {
                dayLeaveDTO.afternoonValue = Int(textField.text!)
            }
        }
        else
        {
            let dayLeaveDTO = daysList[textField.tag - 1000]
            
            if !textField.text!.isEmpty
            {
                dayLeaveDTO.morningValue = Int(textField.text!)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Title"
        {
            textView.text = ""
        }
        
        addToolBartextView(textField: textView)
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text.isEmpty
        {
            textView.text = "Title"
        }
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return daysList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LeavesCell") as? LeavesCell
        {
            let leaveDayDTO = daysList[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: leaveDayDTO.date ?? "")
            formatter.dateFormat = "dd MMMM"
            let dateStr = formatter.string(from: date!)
            cell.lblDate.text = dateStr
            
            if (leaveDayDTO.morningValue ?? 0) > 0
            {
                cell.btnMorning.setImage(UIImage(named: "check"), for: .normal)
            }
            else
            {
                cell.btnMorning.setImage(UIImage(named: "uncheck"), for: .normal)
            }
            
            if (leaveDayDTO.afternoonValue ?? 0) > 0
            {
                cell.btnAfternoon.setImage(UIImage(named: "check"), for: .normal)
            }
            else
            {
                cell.btnAfternoon.setImage(UIImage(named: "uncheck"), for: .normal)
            }
            
            cell.morningCheckboxAction = { () in
                
                if (leaveDayDTO.morningValue ?? 0) > 0
                {
                    cell.btnMorning.setImage(UIImage(named: "uncheck"), for: .normal)
                    leaveDayDTO.morningValue = 0
                }
                else
                {
                    cell.btnMorning.setImage(UIImage(named: "check"), for: .normal)
                    leaveDayDTO.morningValue = 1
                }
            }
            
            cell.afternoonCheckboxAction = { () in
                
                if (leaveDayDTO.afternoonValue ?? 0) > 0
                {
                    cell.btnAfternoon.setImage(UIImage(named: "uncheck"), for: .normal)
                    leaveDayDTO.afternoonValue = 0
                }
                else
                {
                    cell.btnAfternoon.setImage(UIImage(named: "check"), for: .normal)
                    leaveDayDTO.afternoonValue = 1
                }
            }
            
            cell.btnMorning.tag = 1000 + indexPath.row
            cell.btnAfternoon.tag = 2000 + indexPath.row
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

    }
}
