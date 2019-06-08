//
//  EditTableViewController.swift
//  Bware
//
//  Created by James on 9/29/15.
//  Copyright © 2015 James. All rights reserved.
//

import UIKit
import Alamofire

class EditTableViewController: UITableViewController {

    @IBOutlet weak var weightStraightTF: UITextField!
    @IBOutlet weak var weightTriAxle: UITextField!
    @IBOutlet weak var weightComboTF: UITextField!
    @IBOutlet weak var weightDoubleTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var otherPostingTF: UITextField!
    @IBOutlet weak var isRSwitch: UISwitch!
    @IBOutlet weak var CountryTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var countyTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var carriedTF: UITextField!
    @IBOutlet weak var crossedTF: UITextField!
    
    var bridge :Bridge!
    var lat :Double!
    var lon :Double!
    var theToken = Helper.getTokenLocal()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // to dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
       populateTextFields()
    }

 
    @objc func populateTextFields()
    {
        if bridge == nil { return }
        
        weightStraightTF.text = bridge.weightStraight?.toString()
        weightTriAxle.text = bridge.weightStraight_TriAxle?.toString()
        weightComboTF.text = bridge.weightCombo?.toString()
        weightDoubleTF.text = bridge.weightDouble?.toString()
        heightTF.text = bridge.height?.toString()
        otherPostingTF.text = bridge.otherPosting
        if let isR = bridge.isRPosted
        {
            isRSwitch.isOn = isR
        }
        CountryTF.text = bridge.country
        stateTF.text = bridge.state
        cityTF.text = bridge.city
        zipTF.text = bridge.zip
        countyTF.text = bridge.county
        descriptionTF.text = bridge.locationDescription
        carriedTF.text = bridge.featureCarried
        crossedTF.text = bridge.featureCrossed
    }
    
    @objc func rewriteBridgeFromTextFields() -> Bool
    {
        if weightStraightTF.text == "" && weightTriAxle.text == "" && weightDoubleTF.text == "" && weightComboTF.text == "" &&
            heightTF.text == "" && otherPostingTF.text == "" && isRSwitch.isOn == false
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply weight, height, other posting or set R posted switch", theViewController: self)
            return false
        }
        
        let weightS = (weightStraightTF.text! as NSString)
        bridge.weightStraight = weightS.doubleValue // returns 0.0 if invalid
        let weightT = (weightTriAxle.text! as NSString)
        bridge.weightStraight = weightT.doubleValue
        let weightC = (weightComboTF.text! as NSString)
        bridge.weightCombo = weightC.doubleValue
        let weightD = (weightDoubleTF.text! as NSString)
        bridge.weightDouble = weightD.doubleValue
        let height = (heightTF.text! as NSString)
        bridge.height = height.doubleValue
        
        bridge.isRPosted = isRSwitch.isOn
        bridge.otherPosting = otherPostingTF.text
        
        if (bridge.weightStraight == 0) { bridge.weightStraight = nil }
        if (bridge.weightStraight_TriAxle == 0) { bridge.weightStraight_TriAxle = nil }
        if (bridge.weightDouble == 0) { bridge.weightDouble = nil }
        if (bridge.weightCombo == 0) { bridge.weightCombo = nil }
        if (bridge.height == 0.0) { bridge.height = nil }
        
        
        if otherPostingTF.text == "" && isRSwitch.isOn == false && bridge.weightStraight == nil && bridge.weightStraight_TriAxle == nil && bridge.weightDouble == nil && bridge.weightCombo == nil && bridge.height == nil
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please verify valid values were supplied for weight or height", theViewController: self)
            return false
        }
        
        print("isR == \(isRSwitch.isOn)")
        
        if bridge.weightStraight == nil || bridge.weightStraight_TriAxle == nil || bridge.weightDouble == nil
            || bridge.weightCombo == nil || bridge.height == nil
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply reasonable values for weight or height", theViewController: self)
            return false
        }
        
        if otherPostingTF.text! == "" && isRSwitch.isOn == false &&
            (bridge.weightStraight! < 0 || bridge.weightStraight! > 120 ||
             bridge.weightStraight_TriAxle! < 0 || bridge.weightStraight_TriAxle! > 120 ||
                bridge.weightDouble! < 0 || bridge.weightDouble! > 120    ||
                bridge.weightCombo! < 0 || bridge.weightCombo! > 120 ||
                bridge.height! < 0 || bridge.height! > 22)
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply reasonable values for weight or height", theViewController: self)
            return false
        }
        
        if CountryTF.text == "" || stateTF.text == "" || countyTF.text == ""
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply country, state and county", theViewController: self)
            return false
        }
        
        // location info 8 fields
        bridge.country = CountryTF.text
        bridge.city = cityTF.text
        bridge.state = stateTF.text
        bridge.county = countyTF.text
        bridge.locationDescription = descriptionTF.text
        bridge.featureCarried = carriedTF.text
        bridge.featureCrossed = crossedTF.text
        bridge.zip = zipTF.text
        
        // save "" as null in db
        if bridge.country == "" { bridge.country = nil }
        if bridge.city == "" { bridge.city = nil }
        if bridge.state == "" { bridge.state = nil }
        if bridge.county == "" { bridge.county = nil }
        if bridge.locationDescription == "" { bridge.locationDescription = nil }
        if bridge.featureCarried == "" { bridge.featureCarried = nil }
        if bridge.featureCrossed == "" { bridge.featureCrossed = nil }
        if bridge.zip == "" { bridge.zip = nil }
        
        bridge.isLocked = false
        bridge.numVotes = 0
        
        return true
    }
    
    @objc func userMessage(title: String, theMessage: String, theViewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { Void in
                self.performSegue(withIdentifier: "unwindFromEdit", sender:self)
        })
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            theViewController.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func editBridge()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)\(Constants.siteName)/Api/Bridge/Update"
        
        if let token = theToken.access_token
        {
            if theToken.theUserName == nil
            {
                theToken.theUserName = "unknown"
            }
            
            if bridge.latitude == 0.0 || bridge.longitude == 0.0 { return }
            
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let utcTimeZoneStr = formatter.string(from: date as Date)
            // "2014-07-23 18:01:41 +0000" in UTC
            
            var params = ["BridgeId" : 100, "Latitude": bridge.latitude, "Longitude": bridge.longitude,
                "DateModified": utcTimeZoneStr,
                "UserModified" : "\(theToken.theUserName!)"] as [String: Any]
            
            if let carried = bridge.featureCarried
            {
                params["FeatureCarried"] = "\(carried)"
            }
            if let crossed = bridge.featureCrossed
            {
                params["FeatureCrossed"] = "\(crossed)"
            }
            if let description = bridge.locationDescription
            {
                params["LocationDescription"] = "\(description)"
            }
            if let state = bridge.state
            {
                params["State"] = "\(state)"
            }
            if let county = bridge.county
            {
                params["County"] = "\(county)"
            }
            if let town = bridge.city
            {
                params["Township"] = "\(town)"
            }
            if let zip = bridge.zip
            {
                params["Zip"] = "\(zip)"
            }
            if let country = bridge.country
            {
                params["Country"] = "\(country)"
            }
            if let straight = bridge.weightStraight
            {
                params["WeightStraight"] = "\(straight)"
            }
            if let straightTri = bridge.weightStraight_TriAxle
            {
                params["WeightStraight_TriAxle"] = "\(straightTri)"
            }
            if let double = bridge.weightDouble
            {
                params["WeightDouble"] = "\(double)"
            }
            if let combination = bridge.weightDouble
            {
                params["WeightCombination"] = "\(combination)"
            }
            if let height = bridge.height
            {
                params["Height"] = "\(height)"
            }
            if let other = bridge.otherPosting
            {
                params["OtherPosting"] = "\(other)"
            }
            if let rPosted = bridge.isRPosted
            {
                params["isRposted"] = "\(rPosted)"
            }
            
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest = URLRequest(url: URL! as URL)
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
            manager.request(mutableURLRequest).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers)
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
                        Helper.showUserMessage(title: "Error Saving Bridge", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Edit returned OK examine results for isSuccess and/or error message")
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage(title: "Edit Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Edit Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {    // ok display message
                                print("BRIDGE UPDATED")
                                self.userMessage(title: "Bridge Saved", theMessage: "Update successful", theViewController: self)
                            }
                        }
                        
                    }
                    else
                    {
                        print("Error editing bridge")
                        Helper.showUserMessage(title: "Edit Failed", theMessage: "Please try again", theViewController: self)
                    }
                    
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
        
    }

    
    @IBAction func savePressed(sender: UIBarButtonItem)
    {
        if rewriteBridgeFromTextFields()
        {
            editBridge()
        }
    }
    
    @objc func handleTap(tap: UIGestureRecognizer) { view.endEditing(true) }

}
