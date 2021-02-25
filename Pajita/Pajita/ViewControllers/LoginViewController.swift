//
//  LoginViewController.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast_Swift
import Alamofire
import AlamofireObjectMapper

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtPassword:UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        #if DEBUG
//        txtEmail.text = "patrick.diagne@nianteo.com"
//        txtPassword.text = "Kiekie123!"
        
//        txtEmail.text = "baptise.fresnay@cozati.com"
//        txtPassword.text = "demo123@"
        
        //Production server
//        txtEmail.text = "online@demo.com"
//        txtPassword.text = "demo123@"
        
        txtEmail.text = "patrick.diagne@nianteo.com"
        txtPassword.text = "demo123@"
        
        #endif
    }
    
    @IBAction func loginBtnAction(_ sender: Any)
    {
        hideKeypad()
        loginUser()
    }
    
    func loginUser()
    {
        if (txtEmail.text?.isEmpty)!
        {
            self.view.makeToast(localizeString(text: "enter_email"))
        }
        else if !isValidEmail(emailStr: txtEmail.text!)
        {
          self.view.makeToast(localizeString(text: "valid_email"))
        }
        else if (txtPassword.text?.isEmpty)!
        {
          self.view.makeToast(localizeString(text: "enter_password"))
        }
        else
        {
            DispatchQueue.main.async {
              MBProgressHUD.showAdded(to: self.view, animated: true)
            }

            if Reachability.isConnectedToNetwork()
            {
                let email = txtEmail.text!  as String
                let password = txtPassword.text!  as String
                var request = URLRequest(url: URL(string: authURL + "/oauth/token")!)
                print(request)
                request.httpMethod = "POST"
                //parameters
                let postParameters = String(format:"grant_type=password&client_id=%@&client_secret=%@&username=%@&password=%@", clientID, clientSecret,email, password)
                request.httpBody = postParameters.data(using: .utf8)
                print(postParameters)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    guard let data = data, error == nil else {
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                    {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        let responseString = String(data: data, encoding: .utf8)
                        print(responseString)
                        DispatchQueue.main.async {
                            self.view.makeToast(localizeString(text: "invalid_email"))
                        }
                    }
                    else
                    {
                        let responseString = String(data: data, encoding: .utf8)
                        let jsonResult:[String:Any] = convertToDictionary(text: responseString!)!
                        print(jsonResult)
                        
                        accessToken = jsonResult["access_token"] as! String
                        
                        self.getUserDetails()
                        self.getAllCountries()
                        self.getAllCategories()
                        self.getLeaveTypes()
                        self.getAllMissions()
                        
                        DispatchQueue.main.async {
                            let menuVC = UIStoryboard.main.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                            self.navigationController?.pushViewController(menuVC, animated: true)
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
    }
    
    func getUserDetails()
    {
        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + "/user"

            Alamofire.request(URL, headers: getHeaders()).responseObject { (response: DataResponse<UserDTO>) in
                
                let userDTO = response.result.value
                print(URL)
                print(response)
                if let userDTO = userDTO {
                    userDetails = userDTO
                }
            }
        }
    }
    
    func getAllCountries()
    {
        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + "/country/short?mobile=true"

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[SelectDTO]>) in
                
                let selectDTOArray = response.result.value
                if let selectDTOArray = selectDTOArray {
                    for selectDTO in selectDTOArray {
                        countriesArray.append(selectDTO)
                    }
                }
            }
        }
    }
    
    func getAllCategories()
    {
        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + "/expense-type/all"

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[SelectDTO]>) in

                let selectDTOArray = response.result.value

                if let selectDTOArray = selectDTOArray {
                    for selectDTO in selectDTOArray {
                        categoriesArray.append(selectDTO)
                    }
                }
            }
        }
    }
    
    func getLeaveTypes()
    {
        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + "/leave-type/all"

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[SelectDTO]>) in
                
                let selectDTOArray = response.result.value
                if let selectDTOArray = selectDTOArray {
                    for selectDTO in selectDTOArray {
                        leaveTypeArray.append(selectDTO)
                    }
                }
            }
        }
    }
    
    func getAllMissions()
    {
        if Reachability.isConnectedToNetwork()
        {
            let URL = backendURL + "/mission/all"

            Alamofire.request(URL, headers: getHeaders()).responseArray { (response: DataResponse<[MissionDTO]>) in

                let missionDTOArray = response.result.value

                if let missionDTOArray = missionDTOArray
                {
                    for missionDTO in missionDTOArray
                    {
                        if missionDTO.missionName != nil
                        {
                            missionArray.append(missionDTO)
                        }
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == txtEmail
        {
            txtPassword.becomeFirstResponder()
        }
        
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeypad()
    }
    
    func hideKeypad()
    {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
    }

    func isValidEmail(emailStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let email = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return email.evaluate(with: emailStr)
    }
}
