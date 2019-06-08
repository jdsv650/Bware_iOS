//
//  DetailTableViewController.swift
//  Bware
//
//  Created by James on 8/4/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import Alamofire
import BFPaperButton

class DetailTableViewController: UITableViewController {

    
    @IBOutlet weak var noBridgeButton: BFPaperButton!
    @IBOutlet weak var wrongInfoButton: BFPaperButton!
    @IBOutlet weak var editButton: BFPaperButton!
    @IBOutlet weak var removeButton: BFPaperButton!
    
    
    @IBOutlet weak var thumb1: UIImageView!
    @IBOutlet weak var thumb2: UIImageView!
    @IBOutlet weak var thumb3: UIImageView!
    @IBOutlet weak var thumb1Edit: UIImageView!
    @IBOutlet weak var thumb2Edit: UIImageView!
    @IBOutlet weak var thumb3Edit: UIImageView!
    
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
    
    var lat :Double?
    var lon :Double?
    var theBridge = Bridge()
    var theToken = Helper.getTokenLocal()
    var bridgeId :Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Helper.styleButton(noBridgeButton)
        Helper.styleButton(wrongInfoButton)
        Helper.styleButton(editButton)
        Helper.styleButton(removeButton)

        print(lat)
        print(lon)
        
        lockTextFields()
        clearBridgeValues()
        clearVotes()
        getBridgeData()
       
    }
    
    func clearBridgeValues()
    {
        theBridge.country = ""
        theBridge.county = ""
        theBridge.featureCarried = ""
        theBridge.featureCrossed = ""
        theBridge.locationDescription = ""
        theBridge.city = ""
        theBridge.state = ""
        theBridge.zip = ""
        theBridge.otherPosting = ""
    }
    
    func clearVotes()
    {
        thumb1.hidden = true
        thumb2.hidden = true
        thumb3.hidden = true
        thumb1Edit.hidden = true
        thumb2Edit.hidden = true
        thumb3Edit.hidden = true
    }
    
    func getBridgeData()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/GetByLocation"
        
        if let token = theToken.access_token
        {
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            // specified below with Parameter.encoding
            // mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPMethod =  Method.GET.rawValue
            
            var parameters = [String: String]()
            if lat != nil && lon != nil
            {
                 parameters["lat"] = "\(lat!)"
                 parameters["lon"] = "\(lon!)"
                self.theBridge.latitude = lat!
                self.theBridge.longitude = lon!
                
            }
            else
            {
                // lat or lon not available return error
                return
            }
            
            let encoding = ParameterEncoding.URL
            (mutableURLRequest, _) = encoding.encode(mutableURLRequest, parameters: parameters)
            
            let manager = Manager.sharedInstance
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON(options: NSJSONReadingOptions.MutableContainers)
                { (Response) in
                    
                    print(Response.request)
                    print("")
                    print(Response.response)
                    print("")
                    print(Response.result)
                    print("")
                    
                    var data: NSDictionary
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(self)
                    }
                    
                    switch Response.result
                    {
                    case .Success(let theData):
                        data = theData as! NSDictionary
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        Helper.showUserMessage("Retrieve bridge failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
            
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        if let reason1 = data["User1Reason"] as? Bool
                        {
                            if !reason1 { self.thumb1.hidden = false }
                            else { self.thumb1Edit.hidden = false }
                        }
                        
                        if let reason2 = data["User2Reason"] as? Bool
                        {
                            if !reason2 { self.thumb2.hidden = false }
                            else { self.thumb2Edit.hidden = false }
                        }
                        
                        if let reason3 = data["User3Reason"] as? Bool
                        {
                            if !reason3 { self.thumb3.hidden = false }
                            else { self.thumb3Edit.hidden = false }
                        }
                        
                        if let bridgeId = data["BridgeId"] as? Int
                        {
                            self.bridgeId = bridgeId
                        }
                        
                        if let weightStraight = data["WeightStraight"] as? Double
                        {
                            self.weightStraightTF.text = weightStraight.toString()
                            self.theBridge.weightStraight = weightStraight
                        }
                        
                        if let weightTri = data["WeightStraight_TriAxle"] as? Double
                        {
                            self.weightTriAxle.text = weightTri.toString()
                            self.theBridge.weightStraight_TriAxle = weightTri
                        }
                        
                        if let weightCombo = data["WeightCombination"] as? Double
                        {
                            self.weightComboTF.text = weightCombo.toString()
                            self.theBridge.weightCombo = weightCombo
                        }
                        
                        if let weightDouble = data["WeightDouble"] as? Double
                        {
                            self.weightDoubleTF.text = weightDouble.toString()
                            self.theBridge.weightDouble = weightDouble
                        }
                        
                        if let height = data["Height"] as? Double
                        {
                            self.heightTF.text = height.toString()
                            self.theBridge.height = height
                        }
                        
                        if let isR = data["isRposted"] as? Bool
                        {
                            self.isRSwitch.on = isR
                            self.theBridge.isRPosted = isR
                        }
                        
                        if let desc = data["LocationDescription"] as? String
                        {
                            self.descriptionTF.text = desc
                            self.theBridge.locationDescription = desc
                        }
                        
                        if let city = data["Township"] as? String
                        {
                            self.cityTF.text = city
                            self.theBridge.city = city
                        }
                        
                        if let state = data["State"] as? String
                        {
                            self.stateTF.text = state
                            self.theBridge.state = state
                        }
                        
                        if let zip = data["Zip"] as? String
                        {
                            self.zipTF.text = zip
                            self.theBridge.zip = zip
                        }
                        
                        if let country = data["Country"] as? String
                        {
                            self.CountryTF.text = country
                            self.theBridge.country = country
                        }
                        
                        if let other = data["OtherPosting"] as? String
                        {
                            self.otherPostingTF.text = other
                            self.theBridge.otherPosting = other
                        }
                        
                        if let carried = data["FeatureCarried"] as? String
                        {
                            self.carriedTF.text = carried
                            self.theBridge.featureCarried = carried
                        }
                        
                        if let crossed = data["FeatureCrossed"] as? String
                        {
                            self.crossedTF.text = crossed
                            self.theBridge.featureCrossed = crossed
                        }
                        
                        if let county = data["County"] as? String
                        {
                            self.countyTF.text = county
                            self.theBridge.county = county
                        }
                        
                        print("OK Bridge found")
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(self)
        }
        
    }

    @IBAction func votePressed(sender: UIButton)
    {
        theToken = Helper.getTokenLocal()
        
        var urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/DownVoteBridge"
        
        if let token = theToken.access_token
        {
            if bridgeId == nil { return }
            if theToken.theUserName == nil { return }
    
            if sender.tag == 0 // remove
            {
              urlAsString += "/?bridgeId=\(bridgeId!)&userName=\(theToken.theUserName!)&isEdit=false"
            }
            else
            {
                urlAsString += "/?bridgeId=\(bridgeId!)&userName=\(theToken.theUserName!)&isEdit=true"
            }
            
            let URL = NSURL(string: urlAsString)
            let mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            let manager = Manager.sharedInstance
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON(options: NSJSONReadingOptions.MutableContainers)
                { (Response) in
                    
                    print(Response.request)
                    print("")
                    print(Response.response)
                    print("")
                    print(Response.result)
                    
                    var resultAsJSON: NSDictionary
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(self)
                    }
                    
                    switch Response.result
                    {
                    case .Success(let theData):
                        resultAsJSON = theData as! NSDictionary
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        Helper.showUserMessage("Down vote failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Down Vote Returned OK examine results for isSuccess and/or error message")
                        
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage("Down Vote Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage("Down Vote Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                               return
                            }
                            else // success
                            {    // ok display another thumbs up
                                self.addThumbsUp(sender.tag == 0 ? false : true)
                            }
                        }
                        else
                        {
                            if let message = resultAsJSON["message"] as? String
                            {
                                Helper.showUserMessage("Down Vote Failed", theMessage: message, theViewController: self)
                            }
                            else
                            {
                                Helper.showUserMessage("Down Vote Failed", theMessage: "Please Try Again", theViewController: self)
                            }
                            return

                        }
                        
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(self)
        }

    }
    
    
    func addThumbsUp(isEdit: Bool)
    {
      if isEdit == false
      {
        if thumb1.hidden == true && thumb2.hidden == true && thumb3.hidden == true
        {
            thumb1.hidden = false
        }
        else  if thumb1.hidden == false && thumb2.hidden == true && thumb3.hidden == true
        {
            thumb2.hidden = false
        }
        else  if thumb1.hidden == false && thumb2.hidden == false && thumb3.hidden == true
        {
            thumb3.hidden = false
        }
      }
      else
      {
        if thumb1Edit.hidden == true && thumb2Edit.hidden == true && thumb3Edit.hidden == true
        {
            thumb1Edit.hidden = false
        }
        else  if thumb1Edit.hidden == false && thumb2Edit.hidden == true && thumb3Edit.hidden == true
        {
            thumb2Edit.hidden = false
        }
        else  if thumb1Edit.hidden == false && thumb2Edit.hidden == false && thumb3Edit.hidden == true
        {
            thumb3Edit.hidden = false
        }
      }
    }
    
    
    func lockTextFields()
    {
        weightStraightTF.enabled = false
        weightTriAxle.enabled = false
        weightComboTF.enabled = false
        weightDoubleTF.enabled = false
        heightTF.enabled = false
        otherPostingTF.enabled = false
        isRSwitch.userInteractionEnabled = false
        CountryTF.enabled = false
        stateTF.enabled = false
        cityTF.enabled = false
        zipTF.enabled = false
        countyTF.enabled = false
        descriptionTF.enabled = false
        carriedTF.enabled = false
        crossedTF.enabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSegue"
        {
            let editVC = segue.destinationViewController as! EditTableViewController
            editVC.bridge = theBridge
            if lat != nil
            {
                editVC.lat = lat
            }
            if lon != nil
            {
                editVC.lon = lon
            }
            
        }
    }
    
    @IBAction func editPressed(sender: UIButton)
    {
        var count = 0
        
        if thumb1.hidden == false { count += 1 }
        if thumb2.hidden == false { count += 1 }
        if thumb3.hidden == false { count += 1 }
        if thumb1Edit.hidden == false { count += 1 }
        if thumb2Edit.hidden == false { count += 1 }
        if thumb3Edit.hidden == false { count += 1 }
        
        if count >= 3
        {
            performSegueWithIdentifier("editSegue", sender: self)
        }
        else
        {
            Helper.showUserMessage("Edit Bridge Failed", theMessage: "Bridge must have at least 3 down votes to be edited", theViewController: self)

        }
    
    }


    @IBAction func removePressed(sender: UIButton)
    {
        theToken = Helper.getTokenLocal()
        
        var urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/RemoveByLocation"
        
        if let token = theToken.access_token
        {
            if lat == nil || lon == nil { return }
         
            urlAsString += "?lat=\(lat!)&lon=\(lon!)"
            
            let URL = NSURL(string: urlAsString)
            let mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            let manager = Manager.sharedInstance
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON(options: NSJSONReadingOptions.MutableContainers)
                { (Response) in
                    
                    print(Response.request)
                    print("")
                    print(Response.response)
                    print("")
                    print(Response.result)
                    
                    var resultAsJSON: NSDictionary
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(self)
                    }
                    
                    switch Response.result
                    {
                    case .Success(let theData):
                        resultAsJSON = theData as! NSDictionary
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        Helper.showUserMessage("Remove failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Remove Returned OK examine results for isSuccess and/or error message")
                        
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage("Remove Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage("Remove Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {
                                 Helper.showUserMessage("Remove Successful", theMessage: "Bridge marked as inactive", theViewController: self)
                            }
                        }
                        else
                        {
                            if let message = resultAsJSON["message"] as? String
                            {
                                Helper.showUserMessage("Remove Failed", theMessage: message, theViewController: self)
                            }
                            else
                            {
                                Helper.showUserMessage("Remove Failed", theMessage: "Please Try Again", theViewController: self)
                            }
                            return
                            
                        }
                        
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(self)
        }
        
    }
    
    
 
}
