//
//  DetailPartsLocationTableViewController.swift
//  Bware
//
//  Created by James on 1/6/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import SafariServices

class DetailPartsLocationTableViewController: UITableViewController
{
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var branchTF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var notesTV: UITextView!
    
    
    var thePartsLoc :PartsService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableEditOnTextfields()
        loadTextFields()
    }
    
    func loadTextFields()
    {
        if let partsLoc = thePartsLoc
        {
            nameTF.text = partsLoc.name
            phoneTF.text = partsLoc.phone
            branchTF.text = partsLoc.branch
            notesTV.text = partsLoc.notes
            urlTF.text = partsLoc.urlAsString
        }
    }
    
    
    @IBAction func phone1Pressed(_ sender: UIButton) {
        
     
        if let dest = thePartsLoc
        {
            if let url = URL(string: "tel://\(dest.phone)") {
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
        
        if let dest = thePartsLoc
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
    
    
    @IBAction func removePartsLocationPressed(_ sender: UIBarButtonItem) {
        
        confirmDeleteDestination()
    }
    
    func confirmDeleteDestination()
    {
        let alert = UIAlertController(title: "Delete Parts/Service Area", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { (action) -> () in
            if let dest = self.thePartsLoc
            {
                do
                {
                    // get the default Realm
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(dest)
                    }
                    
                    self.performSegue(withIdentifier: "unwindToMapFromDeletePartsLoc", sender: self)
                }
                catch { // error writing to realm db
                    
                    Helper.showUserMessage(title: "Error removing parts/service area", theMessage: "Try Again", theViewController: self)
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
        phoneTF.isEnabled = false
        branchTF.isEnabled = false
        urlTF.isEnabled = false
        notesTV.isEditable = false
    }
}
