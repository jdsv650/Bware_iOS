//
//  CreateDestinationTableViewController.swift
//  Bware
//
//  Created by James on 1/3/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import RealmSwift

class CreateDestinationTableViewController: UITableViewController {

    // passed from mapVC
    var lat :Double?
    var lon :Double?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phone1TF: UITextField!
    @IBOutlet weak var phone2TF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func saveDestinationPressed(_ sender: UIBarButtonItem) {
        
        let theDestination = Destination()
        
        if lat == nil || lon == nil
        {
            Helper.showUserMessage(title: "Error: Saving Destination", theMessage: "Missing geocoordinates", theViewController: self)
            return
        }
        
        let defaults = UserDefaults.standard
        let user_name :String? = defaults.object(forKey: "userName") as? String
        defaults.synchronize()
        
        theDestination.latitude = lat!
        theDestination.longitude = lon!
        theDestination.userName = user_name ?? ""
        theDestination.name = nameTF.text ?? ""
        theDestination.phone1 = phone1TF.text ?? ""
        theDestination.phone2 = phone2TF.text ?? ""
        theDestination.urlAsString = urlTF.text ?? ""
        theDestination.desc = descriptionTV.text ?? ""
    
        // persist the destination
        do
        {
              // get the default Realm
            let realm = try Realm()
            
            try realm.write {
                 realm.add(theDestination)
            }
            
            self.performSegue(withIdentifier: "unwindToMapFromCreateDestination", sender: self)
        }
        catch { // error writing to realm db
            
            Helper.showUserMessage(title: "Error saving destination", theMessage: "Try Again", theViewController: self)
        }
        
       // print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    

}
