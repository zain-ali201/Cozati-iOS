//
//  Reachability.swift
//  FashionConnect
//
//  Created by Schnell on 22/11/2017.
//  Copyright © 2017 Sprint Solutions. All rights reserved.
//

import Foundation
import UIKit

var countriesArray:[SelectDTO] = []
var categoriesArray:[SelectDTO] = []
var leaveTypeArray:[SelectDTO] = []
var missionArray:[MissionDTO] = []
var expenseList:[ExpenseDTO] = []
var leaveList:[LeaveDTO] = []
var userDetails: UserDTO?
var accessToken = ""

var languageCode:String!

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func getHeaders() -> [String: String]? {
    return [
        "Content-Type": "application/json",
        "Authorization":  String(format: "Bearer %@",accessToken)
    ]
}

func localizeString(text: String) -> String
{
    return NSLocalizedString(String(format: "%@_%@", text, languageCode), comment: "")
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0,width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}
