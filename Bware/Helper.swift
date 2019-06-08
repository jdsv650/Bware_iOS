//
//  Helper.swift
//  Bware
//
//  Created by James on 7/14/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import Alamofire
import BFPaperButton

public class Helper
{
    
    class func isValidEmail(emailAsString :String) -> Bool {
        
        // Should test this regex a bit!!!
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailAsString)
    }
    
    class func sendToLogin(theViewController: UIViewController)
    {
        // clear saved info
        UserDefaults.standard.removeObject(forKey: ".expires")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.synchronize()
        
        // workaround for unwind segue broken
        theViewController.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeStoryboardId")
    }
    
    class func getTokenLocal() -> UserToken
    {
        let theToken = UserToken()
        
        let defaults = UserDefaults.standard
        theToken.access_token = defaults.object(forKey: "access_token") as? String
        theToken.expires = defaults.object(forKey: ".expires") as? String
        theToken.theUserName = defaults.object(forKey: "userName") as? String
        defaults.synchronize()
        
        print(theToken.access_token as Any)
        print(theToken.theUserName as Any)
        
        return (theToken)
    }
    
    
    class func showUserMessage(title: String, theMessage: String, theViewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            theViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    class func styleButton(theButton :BFPaperButton)
    {
        theButton.rippleFromTapLocation = true
        theButton.isRaised = true
    }

}




// enable calling toString on a double
extension Double {
    func toString() -> String {
        return String(format: "%.2f",self)
    }
}
