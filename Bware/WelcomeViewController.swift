//
//  WelcomeViewController.swift
//  Bware
//
//  Created by James on 7/4/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import BFPaperButton

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var loginButton: BFPaperButton!
    @IBOutlet weak var newUserButton: BFPaperButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // occassionally keyboard sticks when coming from login 
        Helper.styleButton(theButton: loginButton)
        Helper.styleButton(theButton: newUserButton)
        
        UIApplication.shared.keyWindow?.endEditing(true)

    }
    
    @IBAction func unwindToWelcomeViewController(segue :UIStoryboardSegue)  { }
}
