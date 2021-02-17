//
//  ExpensesListVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import SwiftSignatureView
import MBProgressHUD
import Alamofire

class SignatureVC: UIViewController
{
    @IBOutlet weak var signatureView: SwiftSignatureView!
    
    var timesheetID = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearBtnAction(_ sender: Any)
    {
        signatureView.clear()
    }
    
    @IBAction func saveBtnAction(_ sender: Any)
    {
        let signature = signatureView.signature
        
        if signature != nil
        {
            validateTimeSheet(signature: signature!)
        }
        else
        {
            self.view.makeToast(localizeString(text: "signature"))
        }
    }
    
    func validateTimeSheet(signature: UIImage)
    {
        DispatchQueue.main.async {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        if Reachability.isConnectedToNetwork()
        {
            let image = signature.resizedImageWithinRect(rectSize: CGSize(width: 300, height: 150))
            let imageData:Data = image.jpegData(compressionQuality: 0.5)!
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)

            var request = URLRequest(url: URL(string: String(format: "%@/timesheet/%d/%d/validate-employee", backendURL, self.timesheetID, userDetails!.resourceId!))!)
            print(request)
            request.httpMethod = "POST"
            //parameters

            let parameters = [
                "timesheetId": String(format: "%d", self.timesheetID),
                "image": "data:image/jpg;base64," + strBase64
            ]

            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            request.allHTTPHeaderFields = getHeaders()

            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print(responseString)

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(localizeString(text: "wrong"))
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        let windowCount = UIApplication.shared.windows.count
                        UIApplication.shared.windows[windowCount-1].makeToast(localizeString(text: "Timesheetv"))
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

