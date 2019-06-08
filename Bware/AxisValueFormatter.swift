//
//  AxisValueFormatter.swift
//  Bware
//
//  Created by James on 6/8/19.
//  Copyright © 2019 James. All rights reserved.
//

import Foundation
import Charts

class AxisValueFormatter: IAxisValueFormatter {
    
    var mValues = [String]()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // "value" represents the position of the label on the axis (x or y)
        // 1-5 passed in for 0...4
        
        let posAsInt = Int(value)
        if posAsInt > mValues.count
        {
            return ""
        }
        
        return mValues[posAsInt-1]
        
    }
    
    init(values :[String])
    {
        mValues = values
    }
    
    
}


