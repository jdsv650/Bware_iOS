//
//  SearchTableViewController.swift
//  Bware
//
//  Created by James on 8/25/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController, UITextFieldDelegate {

    @objc var country = "United States"
    @objc var state = "NY"
    @objc var listOfBridges :NSMutableArray = []
    var theToken = Helper.getTokenLocal()
    
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var countyTF: UITextField!
    @IBOutlet weak var townTF: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        countryTF.text = "US"
        // to dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listOfBridges.removeAllObjects()
        countryTF.becomeFirstResponder()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        countryTF.becomeFirstResponder()
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("didbeginediting")
    
        if textField == stateTF
        {
            // US then show table view of states and select one
            if countryTF.text!.uppercased() == "US" || countryTF.text!.uppercased() == "UNITED STATES" || countryTF.text!.uppercased() == "USA" || countryTF.text == "U.S."
            {
                country = "US"
                performSegue(withIdentifier: "stateSegue", sender: self)
            }
            // Canada then show table view of provinces and select one
            if countryTF.text!.uppercased() == "CA" || countryTF.text!.uppercased() == "CANADA" || countryTF.text!.uppercased() == "CAN"
            {
                country = "CA"
                performSegue(withIdentifier: "stateSegue", sender: self)
            }
        }
        
        if textField == countyTF
        {
            // US then show table view of states and select one
            if stateTF.text!.uppercased() == "NY" || stateTF.text!.uppercased() == "NEW YORK" || stateTF.text!.uppercased() == "NYS" || stateTF.text == "N.Y."
            {
                state = "NY"
                performSegue(withIdentifier: "countySegue", sender: self)
            }
        }

    }
    
    // #MARK: - Unwind actions
    @IBAction func unwindToSearchForState(segue: UIStoryboardSegue) {
         print("unwindToSearch")
        
        let stateVC = segue.source as! StateTableViewController
        stateTF.text = stateVC.selectedState
        
    }
    
    
    @IBAction func unwindToSearchForCounty(segue: UIStoryboardSegue) {
        print("unwindToSearch")
        
        let countyVC = segue.source as! CountyTableViewController
        countyTF.text = countyVC.selectedCounty
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stateSegue"
        {
            let stateVC = segue.destination as! StateTableViewController
            stateVC.country = country
        }
        
        if segue.identifier == "countySegue"
        {
            let countyVC = segue.destination as! CountyTableViewController
            countyVC.state = state
            countyVC.fromVC = "Search"
        }
        
        // going back
        if segue.identifier == "unwindSearchSegue"
        {
            let mapVC = segue.destination as! MapViewController
            mapVC.listOfBridges = listOfBridges
        }
    }
    
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        theToken = Helper.getTokenLocal()
        
        var urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/GetByInfo"
        
        // check for country, state, county (required) fields
        if countryTF.text == "" || stateTF.text == "" || countyTF.text == ""
        {
            Helper.showUserMessage(title: "Search Unsuccessful", theMessage: "Required fields must not be empty", theViewController: self)
            return
        }
        
        if let token = theToken.access_token
        {
            let parameters = "/?country=\(countryTF.text!.uppercased())&state=\(stateTF.text!.uppercased())&county=\(countyTF.text!.uppercased())&town=\(townTF.text!.uppercased())".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
            if parameters != nil
            {
                urlAsString += parameters!
            }
            else  // query string malformed show error and exit
            {
                Helper.showUserMessage(title: "Search Unsuccessful", theMessage: "Please Try Again With Different Parameters", theViewController: self)
                return
            }
            
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest = URLRequest(url: URL! as URL)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.httpMethod = HTTPMethod.get.rawValue
                
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
                        Helper.showUserMessage(title: "Search failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Search returned OK examine isSuccess and/or error message")
                        
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    Helper.showUserMessage(title: "Search Unsuccessful", theMessage: message, theViewController: self)
                                }
                                else
                                {
                                    Helper.showUserMessage(title: "Search Unsuccessful", theMessage: "Please Try Again", theViewController: self)
                                }
                                return
                            }
                            else // success
                            {    // ok do something with the results
                               
                                  if let bridges = resultAsJSON["multipleData"] as? NSArray
                                  {
                                     for bridge in bridges
                                     {
                                        print(bridge)
                                        self.listOfBridges.add(bridge)
                                     }
                                  }
                                
                                self.performSegue(withIdentifier: "unwindSearchSegue", sender: self)
                                
                            }
                        }
                        else
                        {
                            if let message = resultAsJSON["message"] as? String
                            {
                                Helper.showUserMessage(title: "Search Unsuccessful", theMessage: message, theViewController: self)
                            }
                            else
                            {
                                Helper.showUserMessage(title: "Search Unsuccessful", theMessage: "Please Try Again", theViewController: self)
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
    
   
  
    
    @objc func handleTap(tap: UIGestureRecognizer) { view.endEditing(true) }

}
