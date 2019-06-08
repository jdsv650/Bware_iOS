//
//  DetailDestinationTableViewController.swift
//  Bware
//
//  Created by James on 1/3/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class DetailDestinationTableViewController: UITableViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phone1TF: UITextField!
    @IBOutlet weak var phone2TF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    
    
    var theDestination :Destination?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        disableEditOnTextfields()
        loadTextFields()
    }
    
    func loadTextFields()
    {
        if let destination = theDestination
        {
            nameTF.text = destination.name
            phone1TF.text = destination.phone1
            phone2TF.text = destination.phone2
            descTF.text = destination.desc
            urlTF.text = destination.urlAsString
        }
    }


    @IBAction func phone1Pressed(_ sender: UIButton) {
    
        if let dest = theDestination
        {
            if let url = URL(string: "tel://\(dest.phone1)") {
                UIApplication.shared.openURL(url)
            }
            else
            {
                Helper.showUserMessage(title: "Error Making Call", theMessage: "Check valid phone #", theViewController: self)
            }
        }
        else
        {
            Helper.showUserMessage(title: "Error Calling #", theMessage: "Try Again", theViewController: self)
        }
    }
    
    
    @IBAction func phone2Pressed(_ sender: UIButton) {
        
        if let dest = theDestination
        {
            if let url = URL(string: "tel://\(dest.phone2)") {
                UIApplication.shared.openURL(url)
            }
            else
            {
                Helper.showUserMessage(title: "Error Making Call", theMessage: "Check valid phone #", theViewController: self)
            }
        }
        else
        {
            Helper.showUserMessage(title: "Error Calling #", theMessage: "Try Again", theViewController: self)
        }
    }
    
    
    @IBAction func showWebsitePressed(_ sender: UIButton) {
        
        if let dest = theDestination
        {
            var urlString = dest.urlAsString
            
            if !urlString.lowercased().hasPrefix("https://") ||
                !urlString.lowercased().hasPrefix("http://")
            {
                urlString = "http://" + urlString
            }
            
            if let u = URL(string: urlString)
            {
                let svc = SFSafariViewController(url: u)
                
                if #available(iOS 10.0, *) {  // match color on 10 or above
                    svc.preferredControlTintColor = UIColor.black
                    svc.preferredBarTintColor = UIColor.orange
                }
                
                self.present(svc, animated: true, completion: nil)
            }
            else
            {
                Helper.showUserMessage(title: "Error loading website", theMessage: "URL info not available", theViewController: self)
            }
        }
        else
        {
            Helper.showUserMessage(title: "Error loading website", theMessage: "Destination info not available", theViewController: self)
        }
    }
    
    
    @IBAction func removeDestinationPressed(_ sender: UIBarButtonItem) {
        
        confirmDeleteDestination()
    }
    
    func confirmDeleteDestination()
    {
        let alert = UIAlertController(title: "Delete Destination", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { (action) -> () in
            if let dest = self.theDestination
            {
                do
                {
                    // get the default Realm
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(dest)
                    }
                    
                    self.performSegue(withIdentifier: "unwindToMapFromDeleteDestination", sender: self)
                }
                catch { // error writing to realm db
                    
                    Helper.showUserMessage(title: "Error removing destination", theMessage: "Try Again", theViewController: self)
                }
            }
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        
        present(alert, animated: true, completion: nil)
    }
    
    func disableEditOnTextfields()
    {
        nameTF.isEnabled = false
        phone1TF.isEnabled = false
        phone2TF.isEnabled = false
        urlTF.isEnabled = false
        descTF.isEditable = false
    }
}
