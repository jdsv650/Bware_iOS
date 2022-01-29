//
//  BridgeRealm.swift
//  Bware
//
//  Created by James on 1/7/18.
//  Copyright © 2018 James. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class BridgeRealm : Object
{
    /***********
        "BridgeId"
        "DateCreated"
        "DateModified"
        "UserCreated"
        "UserModified"
    ************/
    
    @objc dynamic var latitude: Double = -99
    @objc dynamic var longitude: Double = -99
    
   // var weightStraight: Double?
    var weightStraight = RealmProperty<Double?>()
    var weightStraight_TriAxle = RealmProperty<Double?>()
    var weightCombo = RealmProperty<Double?>()
    var weightDouble = RealmProperty<Double?>()
    var height = RealmProperty<Double?>()
    
    @objc dynamic var locationDescription: String?
   
    @objc dynamic var city: String?
    @objc dynamic var state: String?
    @objc dynamic var zip: String?
    @objc dynamic var country: String?
    @objc dynamic var featureCarried: String?
    @objc dynamic var featureCrossed: String?
    @objc dynamic var county: String?
    @objc dynamic var otherPosting: String?
    
    var numVotes = RealmProperty<Int?>()    // 0
    var isLocked = RealmProperty<Bool?>()  // = true
    var isRPosted = RealmProperty<Bool?>() // = false
    

}
