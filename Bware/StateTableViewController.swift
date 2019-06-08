//
//  StateTableViewController.swift
//  Bware
//
//  Created by James on 8/25/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit

class StateTableViewController: UITableViewController {
    
    @objc var country :String!
    @objc var selectedState = ""

    @objc var states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL",
    "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE",
    "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    @objc var provinces = ["AB", "BC", "MB", "NB", "NF", "NT", "NS", "ON", "PE", "QC", "SK", "YT"]
    /***
    AB Alberta
    BC British Columbia
    MB Manitoba
    NB New Brunswick
    NF Newfoundland
    NT Northwest Territories
    NS Nova Scotia
    ON Ontario
    PE Prince Edward Island
    QC Quebec
    SK Saskatchewan
    YT Yukon
    ***/
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if country == "CA"
        {
            return provinces.count
        }
        
        return states.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 20
        
        // Configure the cell...
        if country == "CA"
        {
            cell.textLabel?.text = provinces[indexPath.row]
            
        }
        else
        {
            cell.textLabel?.text = states[indexPath.row]
        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if country == "CA"
        {
            selectedState = provinces[indexPath.row]
            
        }
        else
        {
            selectedState = states[indexPath.row]
        }
        
        //self.navigationController?.popViewController(animated: true)
        
        self.performSegue(withIdentifier: "unwindToSearchSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToSearchSegue"
        {
            print("prepare to unwind to Search")
        }
    }

}
