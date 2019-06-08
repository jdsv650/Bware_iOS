//
//  CreateMessageViewController.swift
//  Bware
//
//  Created by James on 11/7/15.
//  Copyright © 2015 James. All rights reserved.
//

import UIKit
import Alamofire

class CreateMessageViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var messageText: UITextView!
    
    var lat :Double?
    var lon :Double?
    @objc let maxMessageLength = 150 // max characters
    var theToken = Helper.getTokenLocal()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageText.delegate = self
        messageText.becomeFirstResponder()
        
        // to dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        
        if text.count == 0
        {
            if textView.text.count != 0 { return true  }
            else { return false }
        }
        else if textView.text.count > maxMessageLength
        {
            return false
        }
        
        return true
    }


    @IBAction func savePressed(sender: UIBarButtonItem)
    {
        print("save mesage \(String(describing: messageText.text))")
        
        if lat == nil
        {
            Helper.showUserMessage(title: "Error Creating Message", theMessage: "Unable to determine location", theViewController: self)
            return
        }
        if lon == nil
        {
            Helper.showUserMessage(title: "Error Creating Message", theMessage: "Unable to determine location", theViewController: self)
            return
        }

        
        addMessage()
        
    }
    
    
    @objc func addMessage()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)\(Constants.siteName)/Api/Message/Create"
        
        if let token = theToken.access_token
        {
            if theToken.theUserName == nil
            {
                theToken.theUserName = "unknown"
            }
            
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let utcTimeZoneStr = formatter.string(from: date as Date)
            // "2014-07-23 18:01:41 +0000" in UTC
            
            print("creating at \(utcTimeZoneStr)")
            
            var params = ["Latitude": lat!, "Longitude": lon!,
                "DateCreated": utcTimeZoneStr,
                "UserCreated" : "\(theToken.theUserName!)"] as [String: Any]
            
            if let message = messageText.text
            {
                params["MessageText"] = message
            }
            
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest :URLRequest
        

            if URL != nil
            {
                mutableURLRequest = URLRequest(url: URL! as URL)
            }
            else
            {
                print("Error URL")
                return
            }
            
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.httpMethod = HTTPMethod.post.rawValue
            
            let encoding = URLEncoding.queryString
            
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
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(theViewController: self)
                    }
                    
                    switch Response.result
                    {
                    case .success(let theData):
                        resultAsJSON = theData as! NSDictionary
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        Helper.showUserMessage(title: "Error Saving Message", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Create returned OK examine results for isSuccess and/or error message")
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage(title: "Create Message Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Create Message Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {    // ok display message
                                print("Message ADDED")
                                self.userMessage(title: "Message Saved", theMessage: "Create successful", theViewController: self)
                            }
                        }
                        
                    }
                    else
                    {
                        print("Error creating message")
                        Helper.showUserMessage(title: "Error creating message", theMessage: "Please try again", theViewController: self)
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
        
    }

    
    
    @objc func userMessage(title: String, theMessage: String, theViewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            if let controller = self.navigationController
            {
                controller.popViewController(animated: true)
            }
        })
        
        alert.addAction(action)
        theViewController.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleTap(tap: UIGestureRecognizer) { view.endEditing(true) }


}
