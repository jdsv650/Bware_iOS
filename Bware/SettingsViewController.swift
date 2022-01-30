//
//  SettingsViewController.swift
//  Bware
//
//  Created by James on 7/5/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import GoogleMaps
import BFPaperButton
import Alamofire

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var signOutButton: BFPaperButton!
    @IBOutlet weak var saveButton: BFPaperButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var distanceFromLabel: UILabel!
    @IBOutlet weak var distanceFromSlider: UISlider!

   // @IBOutlet weak var bridgeHeightSwitch: UISwitch!
   // @IBOutlet weak var bridgeWeightSwitch: UISwitch!
    @IBOutlet weak var trafficLayerSwitch: UISwitch!
    @IBOutlet weak var destinationSwitch: UISwitch!
    @IBOutlet weak var partsSwitch: UISwitch!
    @IBOutlet weak var homeCircleSwitch: UISwitch!
    
    var theToken = Helper.getTokenLocal()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.styleButton(theButton: signOutButton)
        Helper.styleButton(theButton: saveButton)

        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let user_name :String? = defaults.object(forKey: "userName") as? String
        let distance :Int? = defaults.object(forKey: "distance") as? Int
        
        /***
        let isShowHeight = defaults.object(forKey: "displayHeight") as? Bool
        let isShowWeight = defaults.object(forKey: "displayWeight") as? Bool  ***/
        let isShowTrafficLayer = defaults.object(forKey: "trafficLayer") as? Bool
        let isShowDestination = defaults.object(forKey: "displayDestination") as? Bool
        let isShowParts = defaults.object(forKey: "displayParts") as? Bool
        let isShowHomeCircle = defaults.object(forKey: "displayHomeCircle") as? Bool

        defaults.synchronize()
        
        if let uname = user_name
        {
            userName.text = uname
        }
        
        if let theDistance = distance
        {
            distanceFromLabel.text = "Find bridges within \(theDistance) miles"
            distanceFromSlider.value = Float(theDistance)
        }
        
        if let showTraffic = isShowTrafficLayer
        {
            trafficLayerSwitch.setOn(showTraffic, animated: true)
        }
        else { destinationSwitch.setOn(false, animated: true) }   // default off
        
        if let showDest = isShowDestination
        {
            destinationSwitch.setOn(showDest, animated: true)
        }
        else { destinationSwitch.setOn(true, animated: true) }   // default on
        
        if let showParts = isShowParts
        {
            partsSwitch.setOn(showParts, animated: true)
        }
        else { partsSwitch.setOn(true, animated: true) }   // default on
        
        if let showCircle = isShowHomeCircle
        {
            homeCircleSwitch.setOn(showCircle, animated: true)
        }
        else { homeCircleSwitch.setOn(true, animated: true) }   // default on
        
    }
    
   
    @IBAction func logoutPressed(sender: UIButton) {
        
       logoutUser()
    }
    
    func logoutUser()
    {
        // clear saved info
        UserDefaults.standard.removeObject(forKey: ".expires")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.synchronize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
    }
    
    
    @IBAction func distanceChanged(sender: UISlider) {
        
        distanceFromLabel.text = "Find bridges within \(Int(sender.value)) miles"
    }
    

    @IBAction func saveDistancePressed(sender: UIButton) {
        let defaults = UserDefaults.standard
        let theDistance = Int(distanceFromSlider.value)
        defaults.set(theDistance, forKey: "distance")
        
        /***
        defaults.set(bridgeHeightSwitch.isOn, forKey: "displayHeight")
        defaults.set(bridgeWeightSwitch.isOn, forKey: "displayWeight")  ***/
        defaults.set(trafficLayerSwitch.isOn, forKey: "trafficLayer")
        defaults.set(destinationSwitch.isOn, forKey: "displayDestination")
        defaults.set(partsSwitch.isOn, forKey: "displayParts")
        defaults.set(homeCircleSwitch.isOn, forKey: "displayHomeCircle")
        
        defaults.synchronize()
        
        Helper.showUserMessage(title: "Settings Saved", theMessage: "Please tap refresh button if you wish to reload data", theViewController: self)
    }
    
    @IBAction func backupLocalPressed(_ sender: BFPaperButton) { }

    
    @IBAction func deleteUserPressed(_ sender: UIBarButtonItem) {
        
        deleteUserAlert("Delete User", theMessage: "Remove User and Logout?")
    }
    
    func deleteUserAlert(_ title: String, theMessage: String)
       {
           let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
           
           
           let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in self.deleteUser() }
           )
           alert.addAction(action)
           
           let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
           alert.addAction(cancel)
           
           self.present(alert, animated: true, completion: nil)
       }
       
    
    func deleteUser()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)\(Constants.siteName)/api/Account/DeleteUser"
        
        if let token = theToken.access_token
        {
            var userName = ""
            
            if theToken.theUserName != nil
            {
                userName = theToken.theUserName!
            }
            else {  print("User unknown")  }
            
            let params = ["user" : userName]
            
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest :URLRequest
            
            if URL != nil
            {
                 mutableURLRequest = URLRequest(url: URL! as URL)
            }
            else
            {
                print("URL Unknown")
                return
            }
            
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.httpMethod =  HTTPMethod.delete.rawValue
            mutableURLRequest.setValue("www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let encoding = URLEncoding.queryString

            do
            {
                try mutableURLRequest = encoding.encode(mutableURLRequest, with: params)
                
            } catch
            {
                print("Error encoding params")
            }
            
            let manager = Session.default
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
                        Helper.showUserMessage(title: "Error Deleting User", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Delete Account returned OK examine results for isSuccess and/or error message")
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true   // display error to user
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage(title: "Error Deleting User", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Error Deleting User", theMessage: "Please Try Again", theViewController: self)
                                }
                            }
                            else // account deleted - display message and logout
                            {
                                self.deletedUserSuccessAlert("Account Deleted Successfully", theMessage: "Deleted: " + userName)
                            }
                        }
                    }
                    else
                    {
                        print("Error deleting account")
                        Helper.showUserMessage(title: "Error Deleting User", theMessage: "Please try again", theViewController: self)
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
        
    }
    
    func deletedUserSuccessAlert(_ title: String, theMessage: String)
       {
           DispatchQueue.main.async
           {
               let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
           
               let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in self.logoutUser() }
               )
               alert.addAction(action)
           
               self.present(alert, animated: true, completion: nil)
           }
       }
       
    
}
