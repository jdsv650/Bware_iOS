//
//  LoginViewController.swift
//  Bware
//
//  Created by James on 7/3/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import BFPaperButton
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: BFPaperButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @objc var resetTF :UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.styleButton(theButton: loginButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func loginPressed(sender: UIButton)
    {
        //emai and password can't be empty
        if emailTF.text == "" || passwordTF.text == ""
        {
            showErrorLoginMessage(theMessage: ErrorMessages.email_password_required.rawValue)
            return
        }
    
        //check for valid email
        if !Helper.isValidEmail(emailAsString: emailTF.text!)
        {
            showErrorLoginMessage(theMessage: ErrorMessages.invalid_email.rawValue)
            return
        }
    
        getToken()  // try to get bearer token
    }
    
    
    @IBAction func forgotPasswordPressed(sender: UIButton) {
        
        showMessage(title: "Reset Password", theMessage: "Please enter the email associated with your B*ware account.")
        
    }
    
    @objc func showMessage(title :String, theMessage :String)
    {
        let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        let action = UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { (action) in self.resetPressed() })
    
        alert.addAction(cancel)
        alert.addAction(action)
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Email"
            self.resetTF = textField
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func resetPressed()
    {
        print("Reset - Email = \(String(describing: resetTF.text))")
        resetPassword()
    }
    
    
    @objc func resetPassword()
    {
        let email = resetTF.text!
        
        if(email == "")
        {
            Helper.showUserMessage(title: "Error Resetting Password", theMessage: "Please supply email", theViewController: self)
            return
        }
        
        let urlAsString = "\(Constants.baseUrlAsString)/api/Account/ForgotPassword"
        
        var mutableURLRequest :URLRequest

        let URL = Foundation.URL(string: urlAsString)
        
        if URL != nil
        {
            mutableURLRequest = URLRequest(url: URL!)
        }
        else
        {
            print("Error URL")
            return
        }
        
        mutableURLRequest.httpMethod = HTTPMethod.post.rawValue

        let params = ["email":  "\(email)"]
        print("params = \(params)")
        
        let encoding = URLEncoding.httpBody
        
        do
        {
            try mutableURLRequest = encoding.encode(mutableURLRequest, with: params)
            
        } catch
        {
            print("Error")
        }
        
        let manager = Session.default
        let myRequest = manager.request(mutableURLRequest)
        
        myRequest.responseJSON(queue: DispatchQueue.global(qos: .default), options: JSONSerialization.ReadingOptions.mutableContainers)
        {  (Response) in
            
            print(Response.request as Any)
            print("")
            print(Response.response as Any)
            print("")
            print(Response.result)
            
            var resultAsJSON: NSDictionary
        
            switch Response.result
            {
            case .success(let theData):
                resultAsJSON = theData as! NSDictionary
            case .failure(let error):
                print("Request failed with error: \(error)")
                Helper.showUserMessage(title: "Error Resetting Password", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                return
            }
            
            if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
            {
                print("Reset password OK examine results for isSuccess and/or error message")
                if let success = resultAsJSON["isSuccess"] as? Bool
                {
                    if success != true
                    {
                        if let message = resultAsJSON["message"] as? String
                        {
                            Helper.showUserMessage(title: "Reset Password Error", theMessage: message, theViewController: self)
                        }
                        else
                        {
                            Helper.showUserMessage(title: "Reset Password Error", theMessage: "Please Try Again", theViewController: self)
                        }
                        return
                    }
                    else // success
                    {    // ok display message
                        print("Password Reset OK")
                        if let message = resultAsJSON["message"] as? String
                        {
                            print(message)
                            // message should contain code
                        }
                        
                        Helper.showUserMessage(title: "Almost There!", theMessage: "Check your email and follow the link to reset your B*ware password", theViewController: self)
                        return
                    }
                }
                
            }
            else
            {
                print("Error resetting password")
                Helper.showUserMessage(title: "Reset Password Failed", theMessage: "Please try again", theViewController: self)
            }

        }
        
    }

    
    @objc func getToken()
    {
        let urlAsString = "\(Constants.baseUrlAsString)/token"
        let params = ["username":  "\(emailTF.text!)", "password": "\(passwordTF.text!)", "grant_type": "password"]
        print("params = \(params)")
    
        var mutableURLRequest :URLRequest
        
        let URL = Foundation.URL(string: urlAsString)
        
        if URL != nil
        {
            mutableURLRequest = URLRequest(url: URL!)
        }
        else
        {
            print("Error URL")
            self.showErrorLoginMessage(theMessage: "Malformed URL")
            return
        }
        
        mutableURLRequest.httpMethod = HTTPMethod.post.rawValue
    
        do
        {
            try mutableURLRequest = URLEncoding.httpBody.encode(mutableURLRequest, with: params)
            
        } catch
        {
            print("Malformed URL request unable to encode parameters")
            self.showErrorLoginMessage(theMessage: "Malformed URL request")
            return
        }
        
        let manager = Session.default
        let myRequest = manager.request(mutableURLRequest)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        myRequest.responseJSON(queue: DispatchQueue.global(qos: .default), options: JSONSerialization.ReadingOptions.mutableContainers)
        { (Response) in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            print(Response.request as Any)
            print("")
            print(Response.response as Any)
            print("")
            print(Response.result)
            print("")
        
            var resultAsJSON: NSDictionary
            
            switch Response.result
            {
            case .success(let data):
                    resultAsJSON = data as! NSDictionary
            
            case .failure(let error):
            
                if Response.response?.statusCode == 400  // received a response from server
                {
                    print("400 error from /token")
                    self.showErrorLoginMessage(theMessage: "Please verify username and password")
                    return
                }

                // otherwise display generic message
                print("Request failed with error: \(error)")
                self.showErrorLoginMessage(theMessage: ErrorMessages.generic_network.rawValue)
                return
            }
        
            if let err = resultAsJSON["error"] as? String
            {
                if err == "invalid_grant"
                {
                    self.showErrorLoginMessage(theMessage: ErrorMessages.user_not_found.rawValue)
                    print("USER doesn't exist or password invalid")
                    return // don't try to get token info it failed so just exit
                }
            }
        
            let defaults = UserDefaults.standard
        
            if let token = resultAsJSON["access_token"] as? String
            {
                print(token)
                defaults.set(token, forKey: "access_token")
            }
        
            if let expires = resultAsJSON[".expires"] as? String
            {
                print("Token expires on = \(expires)")
                defaults.set(expires, forKey: ".expires")
            }
        
            if let username = resultAsJSON["userName"] as? String
            {
                print("Username = \(username)")
                defaults.set(username, forKey: "userName")
            }
        
            defaults.synchronize()
        
            DispatchQueue.main.async
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainController") as! UINavigationController
            }
        
        }
    }
    
   
    @objc func showErrorLoginMessage(theMessage: String)
    {
        let alert = UIAlertController(title: "Unable to Login", message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }

    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when tapping screen
        self.view.endEditing(true)
    }

}
