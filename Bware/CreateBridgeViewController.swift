//
//  CreateBridgeViewController.swift
//  Bware
//
//  Created by James on 7/17/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Alamofire

class CreateBridgeViewController: UITableViewController, UITextFieldDelegate {

    // passed from mapVC
    var lat :Double?
    var lon :Double?
    
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
    
    var newBridge = Bridge()
    @objc var weightStraight: String?
    @objc var weightCombo: String?
    @objc var weightDouble: String?
    @objc var height: String?
    @objc var locationDescription: String?
    @objc var city: String?
    @objc var state: String?
    @objc var zip: String?
    @objc var country: String?
    // user stuff
    var theToken = Helper.getTokenLocal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // to dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
        reverseLookup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        weightStraightTF.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        weightStraightTF.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("didbeginediting")
        
        if textField == countyTF // Set state to NY for display 62 counties on next VC
        {
            if stateTF.text!.uppercased() == "NY" || stateTF.text!.uppercased() == "NEW YORK" || stateTF.text!.uppercased() == "NYS" || stateTF.text == "N.Y."
            {
                state = "NY"
                self.view.endEditing(true)
                performSegue(withIdentifier: "createToCountySegue", sender: self)
            }
        }
    }
    
    @IBAction func unwindToCreateForCounty(_ segue: UIStoryboardSegue) {
        print("unwindToCreate")
        
        let countyVC = segue.source as! CountyTableViewController
        countyTF.text = countyVC.selectedCounty
        descriptionTF.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToCountySegue"
        {
            let countyVC = segue.destination as! CountyTableViewController
            countyVC.state = state
            countyVC.fromVC = "Create"
        }
    }
   
    
    @objc func userMessage(title: String, theMessage: String, theViewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: theMessage, preferredStyle: UIAlertController.Style.actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { Void in self.performSegue(withIdentifier: "unwindFromCreate", sender:self) })
   
        alert.addAction(action)
        theViewController.present(alert, animated: true, completion: nil)
    }
    
    func addBridge(bridge :Bridge)
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)\(Constants.siteName)/Api/Bridge/Create"
        
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
            
            var params = ["BridgeId" : 100, "Latitude": bridge.latitude, "Longitude": bridge.longitude,
                "DateCreated": utcTimeZoneStr,
                "DateModified": utcTimeZoneStr,
                "UserCreated" : "\(theToken.theUserName!)",
                "UserModified" : "\(theToken.theUserName!)",
                "NumberOfVotes" : 0,
                "isLocked" : true] as [String: Any]
            
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
            if let triAxle = bridge.weightStraight_TriAxle
            {
                params["WeightStraight_TriAxle"] = "\(triAxle)"
            }
            if let double = bridge.weightDouble
            {
                params["WeightDouble"] = "\(double)"
            }
            if let combination = bridge.weightCombo
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
            mutableURLRequest.httpMethod =  HTTPMethod.post.rawValue
            
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
                        print("Create returned OK examine results for isSuccess and/or error message")
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage(title: "Create Bridge Failed", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Create Bridge Failed", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {    // ok display message
                                print("BRIDGE ADDED")
                                self.userMessage(title: "Bridge Saved", theMessage: "Create successful", theViewController: self)
                            }
                        }
                            
                    }
                    else
                    {
                        print("Error creating bridge")
                        Helper.showUserMessage(title: "Error creating bridge", theMessage: "Please try again", theViewController: self)
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
        if lat != nil { newBridge.latitude = lat! }
        else
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please try again", theViewController: self)
            return
        }
        if lon != nil { newBridge.longitude = lon! }
        else
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please try again", theViewController: self)
            return
        }
        
        if weightStraightTF.text == "" && weightTriAxle.text == "" && weightDoubleTF.text == "" && weightComboTF.text == "" &&
           heightTF.text == "" && otherPostingTF.text == "" && isRSwitch.isOn == false
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply weight, height, other posting or set R posted switch", theViewController: self)
            return
        }
        
        let weightS = (weightStraightTF.text! as NSString)
        newBridge.weightStraight = weightS.doubleValue // returns 0.0 if invalid
        let weightT = (weightTriAxle.text! as NSString)
        newBridge.weightStraight_TriAxle = weightT.doubleValue
        let weightC = (weightComboTF.text! as NSString)
        newBridge.weightCombo = weightC.doubleValue
        let weightD = (weightDoubleTF.text! as NSString)
        newBridge.weightDouble = weightD.doubleValue
        let height = (heightTF.text! as NSString)
        newBridge.height = height.doubleValue
        
        newBridge.isRPosted = isRSwitch.isOn
        newBridge.otherPosting = otherPostingTF.text
        
        if (newBridge.weightStraight == 0.0) { newBridge.weightStraight = nil }
        if (newBridge.weightStraight_TriAxle == 0.0) { newBridge.weightStraight_TriAxle = nil }
        if (newBridge.weightDouble == 0.0) { newBridge.weightDouble = nil }
        if (newBridge.weightCombo == 0.0) { newBridge.weightCombo = nil }
        if (newBridge.height == 0.0) { newBridge.height = nil }

     
        if otherPostingTF.text == "" && isRSwitch.isOn == false && newBridge.weightStraight == nil && newBridge.weightStraight_TriAxle == nil && newBridge.weightDouble == nil && newBridge.weightCombo == nil && newBridge.height == nil
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please verify valid values were supplied for weight or height", theViewController: self)
            return
        }
        
        print("isR == \(isRSwitch.isOn)")
        
        if newBridge.weightStraight == nil || newBridge.weightStraight_TriAxle == nil
            || newBridge.weightDouble == nil || newBridge.weightCombo == nil
            || newBridge.height == nil
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please verify valid values were supplied for weight or height", theViewController: self)
            return
        }
        
        if otherPostingTF.text! == "" && isRSwitch.isOn == false &&
           (newBridge.weightStraight! < 0 || newBridge.weightStraight! > 100 ||
            newBridge.weightStraight_TriAxle! < 0 || newBridge.weightStraight_TriAxle! > 100 ||
            newBridge.weightDouble! < 0 || newBridge.weightDouble! > 100    ||
            newBridge.weightCombo! < 0 || newBridge.weightCombo! > 100 ||
            newBridge.height! < 0 || newBridge.height! > 22)
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply reasonable values for weight or height", theViewController: self)
            return
        }
        
        if CountryTF.text == "" || stateTF.text == "" || countyTF.text == ""
        {
            Helper.showUserMessage(title: "Error Creating Bridge", theMessage: "Please supply country, state and county", theViewController: self)
            return
        }
        
        // location info 8 fields
        newBridge.country = CountryTF.text
        newBridge.city = cityTF.text
        newBridge.state = stateTF.text
        newBridge.county = countyTF.text
        newBridge.locationDescription = descriptionTF.text
        newBridge.featureCarried = carriedTF.text
        newBridge.featureCrossed = crossedTF.text
        newBridge.zip = zipTF.text
        
        // save "" as null in db
        if newBridge.country == "" { newBridge.country = nil }
        if newBridge.city == "" { newBridge.city = nil }
        if newBridge.state == "" { newBridge.state = nil }
        if newBridge.county == "" { newBridge.county = nil }
        if newBridge.locationDescription == "" { newBridge.locationDescription = nil }
        if newBridge.featureCarried == "" { newBridge.featureCarried = nil }
        if newBridge.featureCrossed == "" { newBridge.featureCrossed = nil }
        if newBridge.zip == "" { newBridge.zip = nil }
      
        newBridge.isLocked = false
        newBridge.numVotes = 0
        
        addBridge(bridge: newBridge)
    }
    
    
    @objc func getStateByName(name :String) -> String
    {
    switch (name.uppercased())
    {
    case "ALABAMA":
        return "AL"
    case "ALASKA":
        return "AK"
    case "ARIZONA":
        return "AZ"
    case "ARKANSAS":
        return "AR"
    case "CALIFORNIA":
        return "CA"
    case "COLORADO":
        return "CO"
    case "CONNECTICUT":
        return "CT"
    case "DELAWARE":
        return "DE"
    case "DISTRICT OF COLUMBIA":
        return "DC"
    case "FLORIDA":
        return "FL"
    case "GEORGIA":
        return "GA"
    case "HAWAII":
        return "HI"
    case "IDAHO":
        return "ID"
    case "ILLINOIS":
        return "IL"
    case "INDIANA":
        return "IN"
    case "IOWA":
        return "IA"
    case "KANSAS":
        return "KS"
    case "KENTUCKY":
        return "KY"
    case "LOUISIANA":
        return "LA"
    case "MAINE":
        return "ME"
    case "MARYLAND":
        return "MD"
    case "MASSACHUSETTS":
        return "MA"
    case "MICHIGAN":
        return "MI"
    case "MINNESOTA":
        return "MN"
    case "MISSISSIPPI":
        return "MS"
    case "MISSOURI":
        return "MO"
    case "MONTANA":
        return "MT"
    case "NEBRASKA":
        return "NE"
    case "NEVADA":
        return "NV"
    case "NEW HAMPSHIRE":
        return "NH"
    case "NEW JERSEY":
        return "NJ"
    case "NEW MEXICO":
        return "NM"
    case "NEW YORK":
        return "NY"
    case "NORTH CAROLINA":
        return "NC"
    case "NORTH DAKOTA":
        return "ND"
    case "OHIO":
        return "OH"
    case "OKLAHOMA":
        return "OK"
    case "OREGON":
        return "OR"
    case "PENNSYLVANIA":
        return "PA"
    case "RHODE ISLAND":
        return "RI"
    case "SOUTH CAROLINA":
        return "SC"
    case "SOUTH DAKOTA":
        return "SD"
    case "TENNESSEE":
        return "TN"
    case "TEXAS":
        return "TX"
    case "UTAH":
        return "UT"
    case "VERMONT":
        return "VT"
    case "VIRGINIA":
        return "VA"
    case "WASHINGTON":
        return "WA"
    case "WEST VIRGINIA":
        return "WV"
    case "WISCONSIN":
        return "WI"
    case "WYOMING":
        return "WY"
    default:
        return ""
    }
    }
    
    
    @objc func getCountryByName(name :String) -> String
    {
        switch (name.uppercased())
        {
        case "UNITED STATES":
            return "US"
        case "CANADA":
            return "CA"
        case "MEXICO":
            return "MX"
        default:
            return ""
        }
        
    }
    
    @objc func reverseLookup()
    {
        var coordinate : CLLocationCoordinate2D
        
        if lat != nil && lon != nil
        {
            coordinate = CLLocationCoordinate2DMake(lat!, lon!)
            
            let geoCoder = GMSGeocoder()
            geoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (response, error) -> Void in
                if error == nil{
            
                    // if response == nil call to response.firstResult() blows up so exit
                    if response == nil || response?.results()!.count == 0
                    {
                        return
                    }

                    if let address = response?.firstResult()
                    {
                        print(address)
                        if let locality = address.locality
                        {
                            self.city = locality         // North Tonawanda
                            self.cityTF.text = locality
                        }
                        
                        if let state = address.administrativeArea as String?
                        {
                            self.state = self.getStateByName(name: state)   // New York -> NY
                            self.stateTF.text = self.state
                        }
                        
                        if let desc = address.thoroughfare
                        {
                            self.locationDescription = desc
                            self.descriptionTF.text = desc
                        }
                        
                        if let zip = address.postalCode
                        {
                            self.zip = zip
                            self.zipTF.text = zip
                        }
                        
                        if let country = address.country
                        {
                          //  self.country = self.country?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
                            self.country = self.getCountryByName(name: country)   // United States -> US
                            self.CountryTF.text = self.country
                        }
                        
                    }
                    
                }
                
            })
        }
        
    }
    
    @objc func handleTap(tap: UIGestureRecognizer) { view.endEditing(true) }

}
