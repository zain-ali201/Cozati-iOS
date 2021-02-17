//
//  ExpenseCreationVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import iOSDropDown
import MBProgressHUD
import Alamofire

class ExpenseCreationVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var txtCountry:DropDown!
    @IBOutlet weak var txtCategories:DropDown!
    @IBOutlet weak var txtMission:DropDown!
    @IBOutlet weak var txtDate:UITextField!
    @IBOutlet weak var txtAmount:UITextField!
    @IBOutlet weak var txtDescp:UITextField!
    
    @IBOutlet weak var imgView:UIImageView!
    
    @IBOutlet var datePicker:UIDatePicker!
    @IBOutlet var topConstraint:NSLayoutConstraint!
    
    var countriesName:[String] = []
    var categories:[String] = []
    var missions:[String] = []
    
    var pickerDate:Date!
    
    var countryID = 0
    var categoryID = 0
    var missionID = 0
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE dd MMMM"
//        lblDate.text = formatter.string(from: Date())
        
        imagePicker.delegate = self
        
        for selectDTO in countriesArray
        {
            countriesName.append(selectDTO.description!)
        }
        
        for selectDTO in categoriesArray
        {
            categories.append(selectDTO.description!)
        }
        
        for missionDTO in missionArray
        {
            missions.append(missionDTO.missionName!)
        }
        
        txtCountry.arrowColor = .lightGray
        txtCategories.arrowColor = .lightGray
        txtMission.arrowColor = .lightGray
        
        txtCategories.selectedRowColor = UIColor(red: 235/255, green: 242/255, blue: 249/255, alpha: 1)
        txtCountry.selectedRowColor = UIColor(red: 235/255, green: 242/255, blue: 249/255, alpha: 1)
        txtMission.selectedRowColor = UIColor(red: 235/255, green: 242/255, blue: 249/255, alpha: 1)
        
        txtCountry.optionArray = countriesName
        txtCountry.didSelect{(selectedText , index ,id) in
            self.txtCountry.text = selectedText
            let selectDTO = countriesArray[index]
            self.countryID = selectDTO.id!
        }
        
        txtCategories.optionArray = categories
        txtCategories.didSelect{(selectedText , index ,id) in
            self.txtCategories.text = selectedText
            let selectDTO = categoriesArray[index]
            self.categoryID = selectDTO.id!
        }
        
        txtMission.optionArray = missions
        txtMission.didSelect{(selectedText , index ,id) in
            self.txtMission.text = selectedText
            let missionDTO = missionArray[index]
            self.missionID = missionDTO.missionId!
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
    
    func photoGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePicker.sourceType = .camera
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
    
    @IBAction func cancelBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dateBtnAction(_ sender: Any)
    {
        self.topConstraint.constant = -206
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
          }, completion: { finished in
            
          })
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
        
        txtDate.text = formatter.string(from: pickerDate)
        
        self.topConstraint.constant = 40
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
          }, completion: { finished in
            
          })
    }
    
    @IBAction func submitBtnAction(_ sender: Any)
    {
        if (txtCountry.text?.isEmpty)!
        {
            self.view.makeToast(localizeString(text: "select country"))
        }
        else if (txtCountry.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "select category"))
        }
//        else if (txtMission.text?.isEmpty)!
//        {
//          self.view.makeToast(localizeString(text: "select_mission"))
//        }
        else if (txtDate.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "select_date"))
        }
        else if (txtAmount.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "enter_amount"))
        }
//        else if (txtDescp.text?.isEmpty)!
//        {
//          self.view.makeToast(localizeString(text: "enter_expense"))
//        }
        else if imgView.image == nil
        {
          self.view.makeToast(localizeString(text: "attach_file"))
        }
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
                
                var parameters = [String: Any]()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let expenseDate = formatter.string(from: pickerDate)
                
                formatter.dateFormat = "yyyy"
                let year = formatter.string(from: pickerDate)
                
                formatter.dateFormat = "MM"
                let month = formatter.string(from: pickerDate)
                
                var amount = txtAmount.text!
                
                if languageCode == "fr"
                {
                    amount = amount.replacingOccurrences(of: ",", with: ".")
                }
                
                parameters = ["amount": amount,
                "countryId": countryID,
                "description": txtDescp.text ?? "",
                "expenseDate": expenseDate,
                "expenseStatusId": 0,
                "expenseTypeId": categoryID,
//                "missionId": missionID,
                "missionId": 0,
                "month": month,
                "resourceId": userDetails?.resourceId ?? 0,
                "file": strBase64,
                "year": year]
                
                print(parameters)
                
                var request = URLRequest(url: URL(string: String(format: "%@/expense/resource/%d", backendURL, userDetails?.resourceId ?? 0))!)
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
                            self.view.makeToast(localizeString(text: "Unable to create the expense. Please try again or contact administrator."))
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
                            UIApplication.shared.windows[windowCount-1].makeToast(localizeString(text: "expense_added"))
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
        txtAmount.resignFirstResponder()
        txtCategories.resignFirstResponder()
        txtCountry.resignFirstResponder()
        txtDescp.resignFirstResponder()
        txtMission.resignFirstResponder()
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
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

