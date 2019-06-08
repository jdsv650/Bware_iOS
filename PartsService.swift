//
//  PartsService.swift
//  Bware
//
//  Created by James on 1/6/18.
//  Copyright © 2018 James. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class PartsService: Object
{
    
    @objc dynamic var latitude: Double = -99
    @objc dynamic var longitude: Double = -99
    @objc dynamic var name = ""
    @objc dynamic var phone = ""
    @objc dynamic var branch = ""
    @objc dynamic var urlAsString = ""
    @objc dynamic var notes = ""
    @objc dynamic var userName = ""
}
