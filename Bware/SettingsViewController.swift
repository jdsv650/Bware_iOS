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
        
        /***
        if let showHeight = isShowHeight
        {
            bridgeHeightSwitch.setOn(showHeight, animated: true)
        }
        else { bridgeHeightSwitch.setOn(true, animated: true) }   // default on
        
        if let showWeight = isShowWeight
        {
            bridgeWeightSwitch.setOn(showWeight, animated: true)
        }
        else { bridgeWeightSwitch.setOn(true, animated: true) }   // default on
        ***/
        
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
    
    @IBAction func backupLocalPressed(_ sender: BFPaperButton) {
        
        
    }
    
    

}
