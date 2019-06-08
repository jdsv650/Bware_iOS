//
//  Constant.swift
//  Bware
//
//  Created by James on 7/12/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

struct  Constants {
    
    //static let baseUrlAsString = "http://192.168.1.36/"
    //static let baseUrlAsString = "http://www.myopenroad.info"
    
    static let baseUrlAsString = "https://www.bwaremap.com"  
    static let siteName = ""  //"/Bware"

    
  
}


enum ErrorMessages :String
{
    case invalid_email = "Invalid email"
    case email_password_required = "Email and password required"
    case generic_network = "Network related error. Please try again"
    case user_not_found = "Please verify your email and password"
    case password_confirm_mismatch = "The password and confirm password don't match"
    case invalid_password = "Invalid pasword"
    case generic_signup_error = "Error signing up. Please try again"
}
