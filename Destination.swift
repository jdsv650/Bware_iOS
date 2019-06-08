//
//  Destination.swift
//  Bware
//
//  Created by James on 1/3/18.
//  Copyright © 2018 James. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Destination : Object {
   
    @objc dynamic var latitude: Double = -99
    @objc dynamic var longitude: Double = -99
    @objc dynamic var name = ""
    @objc dynamic var phone1 = ""
    @objc dynamic var phone2 = ""
    @objc dynamic var urlAsString = ""
    @objc dynamic var desc = ""
    @objc dynamic var userName = ""
    
}
