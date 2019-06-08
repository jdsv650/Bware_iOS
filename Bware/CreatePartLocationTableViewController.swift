//
//  CreatePartLocationTableViewController.swift
//  Bware
//
//  Created by James on 1/6/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class CreatePartLocationTableViewController: UITableViewController {

    // passed from mapVC
    var lat :Double?
    var lon :Double?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phone1TF: UITextField!
    @IBOutlet weak var branch: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var notesTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func saveDestinationPressed(_ sender: UIBarButtonItem) {
        
        let thePartsLocation = PartsService()
        
        if lat == nil || lon == nil
        {
            Helper.showUserMessage(title: "Error: Saving Parts/Service Location", theMessage: "Missing geocoordinates", theViewController: self)
            return
        }
        
        let defaults = UserDefaults.standard
        let user_name :String? = defaults.object(forKey: "userName") as? String
        defaults.synchronize()

        thePartsLocation.latitude = lat!
        thePartsLocation.longitude = lon!
        thePartsLocation.userName = user_name ?? ""
        thePartsLocation.name = nameTF.text ?? ""
        thePartsLocation.phone = phone1TF.text ?? ""
        thePartsLocation.branch = branch.text ?? ""
        thePartsLocation.urlAsString = urlTF.text ?? ""
        thePartsLocation.notes = notesTV.text ?? ""
        
        // persist the destination
        do
        {
            // get the default Realm
            let realm = try Realm()
            
            try realm.write {
                realm.add(thePartsLocation)
            }
            
            self.performSegue(withIdentifier: "unwindToMapFromCreatePart", sender: self)
        }
        catch { // error writing to realm db
            
            Helper.showUserMessage(title: "Error saving destination", theMessage: "Try Again", theViewController: self)
        }
        
    }
    
}
