//
//  Bridge.swift
//  Bware
//
//  Created by James on 7/17/15.
//  Copyright (c) 2015 James. All rights reserved.

import Foundation

class Bridge
{
    var weightStraight: Double?
    var weightStraight_TriAxle: Double?
    var weightCombo: Double?
    var weightDouble: Double?
    var height: Double?
    var locationDescription: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?
    var isRPosted: Bool?
    
    var latitude: Double
    var longitude: Double
    
    var featureCarried: String?
    var featureCrossed: String?
    var county: String?
    var otherPosting: String?
    var numVotes: Int
    var isLocked: Bool
    
    init()
    {
        weightStraight = nil
        weightStraight_TriAxle = nil
        weightCombo = nil
        weightDouble = nil
        height = nil
        isRPosted = false
        latitude = 0.0
        longitude = 0.0
        numVotes = 0
        isLocked = false
    }

    
}
