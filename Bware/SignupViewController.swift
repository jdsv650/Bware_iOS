//
//  SignupViewController.swift
//  Bware
//
//  Created by James on 7/3/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import Alamofire
import BFPaperButton

class SignupViewController: UIViewController {

    
    @IBOutlet weak var signUpButton: BFPaperButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.styleButton(theButton: signUpButton)
        activityIndicator.hidesWhenStopped = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" { }
    }
    
    @IBAction func signupPressed(sender: UIButton) {
        
        if password.text != confirmPassword.text
        {
            showErrorSignupMessage(theMessage: ErrorMessages.password_confirm_mismatch.rawValue)
            return
        }
        
        if !Helper.isValidEmail(emailAsString: emailTF.text!)
        {
            showErrorSignupMessage(theMessage: ErrorMessages.invalid_email.rawValue)
            return
        }
        
        registerUser()
    }
    
    
    @objc func registerUser()
    {
        let email = emailTF.text!
        let urlAsString = "\(Constants.baseUrlAsString)/api/Account/Register"
        let params = ["email":  "\(email)", "username": "\(email)",
            "password": "\(password.text!)", "confirmpassword": "\(confirmPassword.text!)"]
        
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
            return
        }
        
        mutableURLRequest.httpMethod = HTTPMethod.post.rawValue
        
        let encoding = URLEncoding.httpBody
        
        do
        {
            try mutableURLRequest = encoding.encode(mutableURLRequest, with: params)
            
        } catch
        {
            print("Error")
        }
        
        let manager = SessionManager.default
        let myRequest = manager.request(mutableURLRequest)
        
        activityIndicator.startAnimating()
        
        myRequest.responseJSON(queue: DispatchQueue.global(qos: .default), options: JSONSerialization.ReadingOptions.mutableContainers)
         { (Response) in
         
            print(Response.request as Any)
            print("")
            print(Response.response as Any)
            print("")
            print(Response.result)
         
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
         
            var resultAsJSON: NSDictionary
         
            switch Response.result
            {
                case .success(let theData):
                    resultAsJSON = theData as! NSDictionary
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    Helper.showUserMessage(title: "Error Registering User", theMessage: (error as NSError).localizedDescription, theViewController: self)
                return
            }
         
            if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
            {
                print("Register user returned OK examine results for isSuccess and/or error message")
                if let success = resultAsJSON["isSuccess"] as? Bool
                {
                    if success != true
                    {
                        if let message = resultAsJSON["message"] as? String
                        {
                            Helper.showUserMessage(title: "Register User Failed", theMessage: message, theViewController: self)
                        }
                        else
                        {
                            Helper.showUserMessage(title: "Register User Failed", theMessage: "Please Try Again", theViewController: self)
                        }
                        return
                    }
                    else // success
                    {    // ok display message
                        print("USER ADDED")
                        DispatchQueue.main.async {
                            self.showSignUpSuccessMessage(theMessage: "User: \(self.emailTF.text!) added")
                        }
                        return
                    }
                }
         }
         else
         {
            print("Error registering user")
            Helper.showUserMessage(title: "Register User Failed", theMessage: "Please try again", theViewController: self)
         }
      }
 
    }
    
    @objc func getToken()
    {
        let urlAsString = "\(Constants.baseUrlAsString)/token"
        let params = ["username":  "\(emailTF.text!)",
            "password": "\(password.text!)",
            "grant_type": "password"]
        
        
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
        
        let encoding = URLEncoding.httpBody
        
        do
        {
            try mutableURLRequest = encoding.encode(mutableURLRequest, with: params)
            
        } catch
        {
            print("Error")
        }
        
        let manager = SessionManager.default
        let myRequest = manager.request(mutableURLRequest)
        
        myRequest.responseJSON(queue: DispatchQueue.global(qos: .default), options: JSONSerialization.ReadingOptions.mutableContainers)
            { (Response) in
                
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
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                if Response.response?.statusCode != 200
                {
                    self.dismiss(animated: true, completion: nil)
                }
                
                if let err = resultAsJSON["error"] as? String
                {
                    if err == "invalid_grant"
                    {
                      //  self.showErrorLoginMessage(ErrorMessages.user_not_found.rawValue)
                        print("USER doesn't exist or password invalid")
                        self.dismiss(animated: true, completion: nil)
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
                    // old - perform segue - new flow - no segue between login / main flow
                    
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
    
    
    @objc func showErrorSignupMessage(theMessage: String)
    {
        let alert = UIAlertController(title: "Unable to complete signup", message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func showSignUpSuccessMessage(theMessage: String)
    {
        let alert = UIAlertController(title: "Signup Successful", message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
    
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in self.getToken() }
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true) { }
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when tapping screen
        self.view.endEditing(true)
    }
    

}
