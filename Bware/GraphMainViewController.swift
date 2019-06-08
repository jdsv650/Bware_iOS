//
//  GraphMainViewController.swift
//  Bware
//
//  Created by James on 11/10/15.
//  Copyright © 2015 James. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class GraphMainViewController: UIViewController {

    var theToken = Helper.getTokenLocal()
    
    @IBOutlet weak var chart: BarChartView!
    
    @objc var states = ["AL" : 0, "AK" : 0, "AZ" : 0, "AR" : 0, "CA" : 0, "CO" : 0, "CT" : 0, "DE" : 0, "FL" : 0, "GA" : 0, "HI" : 0, "ID" : 0, "IL" : 0,
        "IN" : 0, "IA" : 0, "KS" : 0, "KY" : 0, "LA" : 0, "ME" : 0, "MD" : 0, "MA" : 0, "MI" : 0, "MN" : 0, "MS" : 0, "MO" : 0, "MT" : 0, "NE" : 0,
        "NV" : 0, "NH" : 0, "NJ" : 0, "NM" : 0, "NY" : 0, "NC" : 0, "ND" : 0, "OH" : 0, "OK" : 0, "OR" : 0, "PA" : 0, "RI" : 0, "SC" : 0,
        "SD" : 0, "TN" : 0, "TX" : 0, "UT" : 0, "VT" : 0, "VA" : 0, "WA" : 0, "WV" : 0, "WI" : 0, "WY" : 0 ]

    var state1 = ("",0.0)
    var state2 = ("",0.0)
    var state3 = ("",0.0)
    var state4 = ("",0.0)
    var state5 = ("",0.0)
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        zeroStates()
        getBridgeData()
    }
    
    
    @objc func zeroStates()
    {
        for key in states.keys
        {
            states[key] = 0
        }
    }


    @objc func getBridgeData()
    {
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/GetCountForStates"
        
        if let token = theToken.access_token
        {
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest = URLRequest(url: URL! as URL)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.httpMethod = HTTPMethod.get.rawValue
            
          //  let encoding = URLEncoding.queryString
            
            let manager = SessionManager.default
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers)
                { (Response) in
                    
                    print(Response.request as Any)
                    print("")
                    print(Response.response as Any)
                    print("")
                    print(Response.result)
                    
                    var resultAsJSON: AnyObject
                    
                    if Response.response?.statusCode == 401  // unauthorized
                    {
                        print("Unauthorized -- Go To Login")
                        Helper.sendToLogin(theViewController: self)
                    }
                    
                    switch Response.result
                    {
                    case .success(let theData):
                        resultAsJSON = theData as AnyObject
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                         Helper.showUserMessage(title: "Retrieve data failed", theMessage: ErrorMessages.generic_network.rawValue, theViewController: self)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                       print("OK...")
                        
                        let resultAsArray = resultAsJSON as! NSArray
                        
                        var currentPlace = 1
                        
                        for data in resultAsArray
                        {
                            var theState = ""
                            
                            let theData = data as! [String: AnyObject]
                            
                            if let state = theData["State"] as? String
                            {
                                print("State = \(state)")
                                theState = state
                            }
                            
                            if let count = theData["NumberOfBridges"] as? Int
                            {
                                print("Num of bridges = \(count)")
                                // Does key (state) exist and is a match?
                                if self.states[theState] != nil
                                {
                                    self.states[theState] = count
                                    switch currentPlace {
                                        case 1: self.state1.0 = theState
                                                self.state1.1 = Double(count)
                                        case 2: self.state2.0 = theState
                                                self.state2.1 = Double(count)
                                        case 3: self.state3.0 = theState
                                                self.state3.1 = Double(count)
                                        case 4: self.state4.0 = theState
                                                self.state4.1 = Double(count)
                                        case 5: self.state5.0 = theState
                                                self.state5.1 = Double(count)
                                    default:
                                        break
                                        
                                   }
                                    
                                    currentPlace += 1
                                }
                            }
                        }
                        self.graphTop5()
                    }
            }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
    }
    
    
     func graphTop5()
     {
        if chart == nil { return }
        
        var dataEntry = [BarChartDataEntry]()
        var xAxisLabels = [String]()
     
        // grab label and value for each bar
        dataEntry.append(BarChartDataEntry(x: 1, y: state1.1))
        dataEntry.append(BarChartDataEntry(x: 2, y: state2.1))
        dataEntry.append(BarChartDataEntry(x: 3, y: state3.1))
        dataEntry.append(BarChartDataEntry(x: 4, y: state4.1))
        dataEntry.append(BarChartDataEntry(x: 5, y: state5.1))
        xAxisLabels.append(state1.0)
        xAxisLabels.append(state2.0)
        xAxisLabels.append(state3.0)
        xAxisLabels.append(state4.0)
        xAxisLabels.append(state5.0)
     
        // load chart with data
        let dataSet = BarChartDataSet(entries: dataEntry, label: "")
     
         let posColor = UIColor(red: 0.98, green: 0.50, blue: 0.01, alpha: 1.0)
        dataSet.colors = [posColor]
        
        dataSet.valueFont = UIFont.systemFont(ofSize: 12)
        dataSet.valueColors = [UIColor.black]   // "hide" actual value displayed near top of bar by same color
     
        let data = BarChartData(dataSets: [dataSet])
        chart!.data = data
     
        // create and place chart descrioption
        chart!.chartDescription?.enabled = false
        chart!.chartDescription?.text = "Top 5"
        chart!.chartDescription?.textAlign = .center
        chart!.chartDescription?.textColor = UIColor.black
        chart!.chartDescription?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.semibold)
        let frame = self.view.frame
        let topLeft = CGPoint(x: (frame.minX+frame.maxX / 2), y: frame.minY)
        chart!.chartDescription?.position = topLeft
     
        // misc chart settings
        chart!.drawValueAboveBarEnabled = false
        chart!.legend.enabled = false
        chart!.backgroundColor = UIColor.white
        chart!.borderColor = UIColor.black
        //barChartView.legend.textColor = UIColor.orange
        //barChartView.drawGridBackgroundEnabled = true
     
        // show labels on x axis from our data set
        let xAxis = chart!.xAxis
     
        xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor.black
        xAxis.drawLabelsEnabled = true
        // xAxis.drawAxisLineEnabled = true
        // xAxis.drawGridLinesEnabled = true
        xAxis.granularity = 1
        xAxis.valueFormatter = AxisValueFormatter(values: xAxisLabels)
     
        // refresh chart
        chart!.notifyDataSetChanged()
      }
    
}
