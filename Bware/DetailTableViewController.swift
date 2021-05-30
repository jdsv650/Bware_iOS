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

        Helper.styleButton(theButton: noBridgeButton)
        Helper.styleButton(theButton: wrongInfoButton)
        Helper.styleButton(theButton: editButton)
        Helper.styleButton(theButton: removeButton)

        if lat != nil
        {
            print(lat!)
        }
        
        if lon != nil
        {
            print(lon!)
        }
        
        lockTextFields()
        clearBridgeValues()
        clearVotes()
        getBridgeData()
       
    }
    
    @objc func clearBridgeValues()
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
    
    @objc func clearVotes()
    {
        thumb1.isHidden = true
        thumb2.isHidden = true
        thumb3.isHidden = true
        thumb1Edit.isHidden = true
        thumb2Edit.isHidden = true
        thumb3Edit.isHidden = true
    }
    
    @objc func getBridgeData()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/GetByLocation"
        
        if let token = theToken.access_token
        {
            let URL = NSURL(string: urlAsString)
            
            var mutableURLRequest = URLRequest(url: URL! as URL)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            // specified below with Parameter.encoding
            // mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.httpMethod =  HTTPMethod.get.rawValue
            
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
            
            let encoding = URLEncoding.queryString
            
            do
            {
                try mutableURLRequest = encoding.encode(mutableURLRequest, with: parameters)
                
            } catch
            {
                print("Error")
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
                    print("")
                    
                    var data: NSDictionary
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(theViewController: self)
                    }
                    
                    switch Response.result
                    {
                    case .success(let theData):
                        data = theData as! NSDictionary
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        Helper.showUserMessage(title: "Retrieve bridge failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
            
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                      DispatchQueue.main.async {  // slow and occasional crash without
                        
                        if let reason1 = data["User1Reason"] as? Bool
                        {
                            if !reason1 { self.thumb1.isHidden = false }
                            else { self.thumb1Edit.isHidden = false }
                        }
                        
                        if let reason2 = data["User2Reason"] as? Bool
                        {
                            if !reason2 { self.thumb2.isHidden = false }
                            else { self.thumb2Edit.isHidden = false }
                        }
                        
                        if let reason3 = data["User3Reason"] as? Bool
                        {
                            if !reason3 { self.thumb3.isHidden = false }
                            else { self.thumb3Edit.isHidden = false }
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
                            self.isRSwitch.isOn = isR
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
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
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
            var mutableURLRequest = URLRequest(url: URL! as URL)
            
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.httpMethod = HTTPMethod.post.rawValue
            
           // let encoding = URLEncoding.queryString
            
            let manager = Session.default
            let myRequest = manager.request(mutableURLRequest)

            
            myRequest.responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers)
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
                        Helper.showUserMessage(title: "Down vote failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
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
                                    Helper.showUserMessage(title: "Down Vote Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Down Vote Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                               return
                            }
                            else // success
                            {    // ok display another thumbs up
                                self.addThumbsUp(isEdit: sender.tag == 0 ? false : true)
                            }
                        }
                        else
                        {
                            if let message = resultAsJSON["message"] as? String
                            {
                                Helper.showUserMessage(title: "Down Vote Failed", theMessage: message, theViewController: self)
                            }
                            else
                            {
                                Helper.showUserMessage(title: "Down Vote Failed", theMessage: "Please Try Again", theViewController: self)
                            }
                            return

                        }
                        
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }

    }
    
    
    @objc func addThumbsUp(isEdit: Bool)
    {
      if isEdit == false
      {
        if thumb1.isHidden == true && thumb2.isHidden == true && thumb3.isHidden == true
        {
            thumb1.isHidden = false
        }
        else  if thumb1.isHidden == false && thumb2.isHidden == true && thumb3.isHidden == true
        {
            thumb2.isHidden = false
        }
        else  if thumb1.isHidden == false && thumb2.isHidden == false && thumb3.isHidden == true
        {
            thumb3.isHidden = false
        }
      }
      else
      {
        if thumb1Edit.isHidden == true && thumb2Edit.isHidden == true && thumb3Edit.isHidden == true
        {
            thumb1Edit.isHidden = false
        }
        else  if thumb1Edit.isHidden == false && thumb2Edit.isHidden == true && thumb3Edit.isHidden == true
        {
            thumb2Edit.isHidden = false
        }
        else  if thumb1Edit.isHidden == false && thumb2Edit.isHidden == false && thumb3Edit.isHidden == true
        {
            thumb3Edit.isHidden = false
        }
      }
    }
    
    
    @objc func lockTextFields()
    {
        weightStraightTF.isEnabled = false
        weightTriAxle.isEnabled = false
        weightComboTF.isEnabled = false
        weightDoubleTF.isEnabled = false
        heightTF.isEnabled = false
        otherPostingTF.isEnabled = false
        isRSwitch.isUserInteractionEnabled = false
        CountryTF.isEnabled = false
        stateTF.isEnabled = false
        cityTF.isEnabled = false
        zipTF.isEnabled = false
        countyTF.isEnabled = false
        descriptionTF.isEnabled = false
        carriedTF.isEnabled = false
        crossedTF.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue"
        {
            let editVC = segue.destination as! EditTableViewController
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
        
        if thumb1.isHidden == false { count += 1 }
        if thumb2.isHidden == false { count += 1 }
        if thumb3.isHidden == false { count += 1 }
        if thumb1Edit.isHidden == false { count += 1 }
        if thumb2Edit.isHidden == false { count += 1 }
        if thumb3Edit.isHidden == false { count += 1 }
        
        if count >= 3
        {
            performSegue(withIdentifier: "editSegue", sender: self)
        }
        else
        {
            Helper.showUserMessage(title: "Edit Bridge Failed", theMessage: "Bridge must have at least 3 down votes to be edited", theViewController: self)

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
            var mutableURLRequest = URLRequest(url: URL! as URL)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.httpMethod = HTTPMethod.post.rawValue
            
            let manager = Session.default
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers)
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
                        Helper.showUserMessage(title: "Remove failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
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
                                    Helper.showUserMessage(title: "Remove Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Remove Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {
                                self.deleteUserMessage(title: "Remove Successful", theMessage: "Bridge marked as inactive - refresh bridge data to see changes", theViewController: self)
                                 //Helper.showUserMessage(title: , theMessage: "Bridge marked as inactive - refresh bridge data to see changes", theViewController: self)
                            }
                        }
                        else
                        {
                            if let message = resultAsJSON["message"] as? String
                            {
                                Helper.showUserMessage(title: "Remove Failed", theMessage: message, theViewController: self)
                            }
                            else
                            {
                                Helper.showUserMessage(title: "Remove Failed", theMessage: "Please Try Again", theViewController: self)
                            }
                            return
                            
                        }
                        
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
        
    }
    
    
     @objc func deleteUserMessage(title: String, theMessage: String, theViewController: UIViewController)
     {
         let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
         
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { Void in
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        })
    
         alert.addAction(action)
         theViewController.present(alert, animated: true, completion: nil)
     }
    
    
 
}
