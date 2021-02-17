//
//  ExpensesListVC.swift
//  Pajita
//
//  Created by Zain Ali on 08/10/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var txtName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var txtPhone:UITextField!
    
    @IBOutlet weak var avatar:UIImageView!
    
    @IBOutlet weak var topConstraint:NSLayoutConstraint!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        imagePicker.delegate = self
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       NotificationCenter.default.addObserver(
           self,
           selector: #selector(keyboardWillShow),
           name: UIResponder.keyboardWillShowNotification,
           object: nil
       )
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            topConstraint.constant = -keyboardHeight + 50
            UIView.animate(withDuration: 0.3) { [weak self] in
              self?.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
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
            avatar.image = pickedImage.resizedImageWithinRect(rectSize: CGSize(width: 168, height: 168))
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == txtPhone
        {
            addToolBar(textField: textField)
        }
    }
    
    func addToolBar(textField: UITextField)
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: localizeString(text:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneBtnAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneBtnAction()
    {
        hideKeypad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeypad()
    }
    
    func hideKeypad()
    {
        topConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        txtName.resignFirstResponder()
        txtPhone.resignFirstResponder()
    }

    func isValidEmail(emailStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let email = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return email.evaluate(with: emailStr)
    }
}

