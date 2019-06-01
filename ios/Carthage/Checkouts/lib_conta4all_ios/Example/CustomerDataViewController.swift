//
//  CustomerDataViewController.swift
//  Example
//
//  Created by Cristiano Matte on 23/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class CustomerDataViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cpfTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = Lib4all.customerData() {
            if let phone = data["phoneNumber"] as? String {
                phoneTextField.text = phone
            }
            
            if let email = data["emailAddress"] as? String {
                emailTextField.text = email
            }
            
            if let name = data["fullName"] as? String {
                nameTextField.text = name
            }
            
            if let cpf = data["cpf"] as? String {
                cpfTextField.text = cpf
            }
            
            if let birthdate = data["birthdate"] as? String {
                birthdateTextField.text = birthdate
            }
        }
    }

    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        var data = [String: String]()
        
        if let phone = phoneTextField.text, phone != "" {
            data["phoneNumber"] = phone
        } else {
            data["phoneNumber"] = nil
        }
        
        if let email = emailTextField.text, email != "" {
            data["emailAddress"] = email
        } else {
            data["emailAddress"] = nil
        }
        
        if let name = nameTextField.text, name != "" {
            data["fullName"] = name
        } else {
            data["fullName"] = nil
        }
        
        if let cpf = cpfTextField.text, cpf != "" {
            data["cpf"] = cpf
        } else {
            data["cpf"] = nil
        }
        
        if let birthdate = birthdateTextField.text, birthdate != "" {
            data["birthdate"] = birthdate
        } else {
            data["birthdate"] = nil
        }
        
        Lib4all.setCustomerData(data)
        self.dismiss(animated: true, completion: nil)
    }
    
}
