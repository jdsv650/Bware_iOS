//
//  CreateTableViewController.swift
//  Bware
//
//  Created by James on 1/3/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class CreateTableViewController: UITableViewController {

    // passed from mapVC
    var lat :Double?
    var lon :Double?
    
    var errorLabel :UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel = setupErrorLabelUI(view: view)
    }
    
    @IBAction func createBridgeOnlinePressed(_ sender: UIButton) {
        
        displayErrorMessage("Create a new bridge (online) for all users to see", duration: 3, onLabel: errorLabel)
       // Helper.showUserMessage(title: "Save to online database", theMessage: "Create a new bridge for all users to see", theViewController: self)
    }
    
    
    @IBAction func createDestinationLocalPressed(_ sender: UIButton) {
        displayErrorMessage("Create a new destination (on device) for private use", duration: 3, onLabel: errorLabel)

       // Helper.showUserMessage(title: "Save to local database", theMessage: "Create a new destination on device for private use", theViewController: self)
    }
    
    @IBAction func createPartsLocalPressed(_ sender: UIButton) {
        displayErrorMessage("Create a new parts / service area (on device) for private use", duration: 3, onLabel: errorLabel)
        
       // Helper.showUserMessage(title: "Save to local database", theMessage: "Create a new parts / service area on device for private use", theViewController: self)

    }
    
    @IBAction func createHomeLocalPressed(_ sender: UIButton) {
        
        confirmCreateLocal()
    }
    
    @IBAction func createHomelocalinfoPressed(_ sender: UIButton) {
        
        displayErrorMessage("Create a new home area (on device) for private use", duration: 3, onLabel: errorLabel)
        
        // Helper.showUserMessage(title: "Save to local database", theMessage: "Create a new home area on device for private use", theViewController: self)
    }
    
    
    func confirmCreateLocal()
    {
        let alert = UIAlertController(title: "Create Home Marker", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { (action) -> () in
         
            let home = Home()
            
            if self.lat == nil || self.lon == nil
            {
                Helper.showUserMessage(title: "Error: Saving Destination", theMessage: "Missing geocoordinates", theViewController: self)
                return
            }
            home.latitude = self.lat!
            home.longitude = self.lon!
            
            let defaults = UserDefaults.standard
            let user_name :String? = defaults.object(forKey: "userName") as? String
            defaults.synchronize()
            
            home.userName = user_name ?? ""
            
            // persist the destination
            do
            {
                // get the default Realm
                let realm = try Realm()
                
                try realm.write {
                    realm.add(home)
                }
                
                self.performSegue(withIdentifier: "unwindToMapFromCreateHome", sender: self)
            }
            catch { // error writing to realm db
                
                Helper.showUserMessage(title: "Error saving home", theMessage: "Try Again", theViewController: self)
            }
            
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createDestinationSegue"
        {
            let nextVC = segue.destination as! CreateDestinationTableViewController
            nextVC.lat = lat
            nextVC.lon = lon
        }
        else if segue.identifier == "createBridgeSegue"
        {
            let nextVC = segue.destination as! CreateBridgeViewController
            nextVC.lat = lat
            nextVC.lon = lon
        }
        else if segue.identifier == "createPartLocationSegue"
        {
            let nextVC = segue.destination as! CreatePartLocationTableViewController
            nextVC.lat = lat
            nextVC.lon = lon
        }
    }
    
    func setupErrorLabelUI(view :UIView) -> UILabel
    {
        let errorLabel = UILabel()
        
        errorLabel.isHidden = true
        errorLabel.text = ""
        errorLabel.textAlignment = .center
        errorLabel.backgroundColor = UIColor.lightGray
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(errorLabel)
        
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -100))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0))
        
        return errorLabel
    }
    
    // MARK: - display error message
    func displayErrorMessage(_ theMessage: String, duration: Double, onLabel: UILabel)
    {
        onLabel.isHidden = false
        onLabel.text = theMessage
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration)
        {
            onLabel.isHidden = true
        }
    }

}
