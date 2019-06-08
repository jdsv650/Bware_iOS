//
//  CountyTableViewController.swift
//  Bware
//
//  Created by James on 8/26/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit

class CountyTableViewController: UITableViewController {

    @objc var state :String!
    @objc var selectedCounty = ""
    @objc var fromVC = ""
    
    @objc var counties =
    ["Albany", "Allegany", "Bronx", "Broome", "Cattaraugus", "Cayuga", "Chautauqua",
     "Chemung", "Chenango", "Clinton", "Columbia", "Cortland", "Delaware", "Dutchess", "Erie", "Essex", "Franklin", "Fulton",
     "Genesee", "Greene", "Hamilton", "Herkimer", "Jefferson", "Kings", "Lewis", "Livingston", "Madison", "Monroe",
     "Montgomery", "Nassau",  "New York", "Niagara", "Oneida", "Onondaga", "Ontario", "Orange", "Orleans", "Oswego", "Otsego",  "Putnam",
     "Queens", "Rensselaer", "Richmond", "Rockland", "Saratoga", "Schenectady", "Schoharie",  "Schuyler",  "Seneca", "St Lawrence",
     "Steuben", "Suffolk", "Sullivan", "Tioga", "Tompkins", "Ulster",  "Warren", "Washington", "Wayne", "Westchester",
     "Wyoming", "Yates"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return counties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountyCell", for: indexPath)
        
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 20
        
        // Configure the cell...
        if state == "NY"
        {
            cell.textLabel?.text = counties[indexPath.row]
            
        }
        else
        {
            cell.textLabel?.text = counties[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if state == "NY"
        {
            selectedCounty = counties[indexPath.row]
        }
        else
        {
            selectedCounty = counties[indexPath.row]
        }
        
        // self.navigationController?.popViewControllerAnimated(true)
        
        
        if fromVC == "Create"
        {
            self.performSegue(withIdentifier: "unwindToCreateForCounty", sender: self)
        }
        else
        {
            self.performSegue(withIdentifier: "unwindFromCountySegue", sender: self)
        }
    }
  

  }
