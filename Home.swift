//
//  Home.swift
//  Bware
//
//  Created by James on 1/5/18.
//  Copyright © 2018 James. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Home : Object {
    
    @objc dynamic var latitude: Double = -99
    @objc dynamic var longitude: Double = -99
    @objc dynamic var name = ""
    @objc dynamic var phone = ""
    @objc dynamic var userName = ""
}
