//
//  MapViewController.swift
//  Bware
//
//  Created by James on 7/4/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import RealmSwift
import Flurry_iOS_SDK

enum MarkerTypes {
    case bridgeHeight
    case bridgeWeight
    case destination
    case parts
    case home
}

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate
{
    var errorLabel: UILabel!
    @objc let locationManager = CLLocationManager()
    @objc var didFindMyLocation = false
    var theToken = Helper.getTokenLocal()
    
    @objc var mapView :GMSMapView!
    // start center of map at geograpich center of contiguous US Lebanon, Kansas
    @objc let geographicCenterUSLat = 39.833333
    @objc let geographicCenterUSLon = -98.583333
    var currentLat :Double!
    var currentLon :Double!
    var newLocation : CLLocationCoordinate2D!
    @objc var numMilesToSearch = 50  // can be changed by preference
    @objc var isOkToUseLocation = false
    @objc var isUnwindFromSearch = false
    @objc var listOfBridges :NSMutableArray = []
    @objc let distanceToUpdate = 8046.0   // 8046 meters - around 5 miles
    let errorMessageDuration = 3.0
    let oneHundredMilesInMeters = 160934.0
    //let bridgeCacheKey = "lastBridgeCacheTime"
    //let cacheExpiresInHours = 24
    
    var isShowHeight = true
    var isShowWeight = true
    var isShowDestination = true
    var isShowParts = true
    var isShowHomeCircle = true
    
    var bridgeHeightMarkers = [GMSMarker]()
    var bridgeWeightMarkers = [GMSMarker]()
    var destinationMarkers = [GMSMarker]()
    var homeMarkers = [GMSMarker]()
    var partsMarkers = [GMSMarker]()
    var homeCircles = [GMSCircle]()
    
    var parts :Results<PartsService>?
    var home :Results<Home>?
    var dest :Results<Destination>?
    //var bridges :Results<BridgeRealm>?
    var userName = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewDidLoad")
        // stop swiping - causes KVO problems/crash
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = distanceToUpdate
        
        currentLat = geographicCenterUSLat
        currentLon = geographicCenterUSLon
        let camera = GMSCameraPosition.camera(withLatitude: geographicCenterUSLat,
            longitude: geographicCenterUSLon, zoom: 6)
     
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        
        errorLabel = setupErrorLabelUI(view: self.view)
        setupRefreshUI(view: self.view)
        setupActivityIndicatorUI(view: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let distance :Int? = defaults.object(forKey: "distance") as? Int
        let isHeight = defaults.object(forKey: "displayHeight") as? Bool
        let isWeight = defaults.object(forKey: "displayWeight") as? Bool
        let isDestination = defaults.object(forKey: "displayDestination") as? Bool
        let isParts = defaults.object(forKey: "displayParts") as? Bool
        let isHomeCircle = defaults.object(forKey: "displayHomeCircle") as? Bool
        let uName = defaults.object(forKey: "userName") as? String
       // let lastCacheDateTime = defaults.object(forKey: bridgeCacheKey) as? Date
        defaults.synchronize()
        
        userName = uName ?? ""
        
        if let showHeight = isHeight
        {
            isShowHeight = showHeight
        }
        else { isShowHeight = true }   // default on
        
        if let showWeight = isWeight
        {
            isShowWeight = showWeight
        }
        else { isShowWeight = true }   // default on
        
        if let showDest = isDestination
        {
            isShowDestination = showDest
        }
        else { isShowDestination = true }   // default true
        
        if let showParts = isParts
        {
            isShowParts = showParts
        }
        else
        {
            isShowParts = true
        }   // default true
        
        let _ = checkLocationServicesEnabled()
        
        if distance != nil  // if user set a preference use that for num miles to search
        {
           self.numMilesToSearch = distance!
        }
        
        if isShowDestination == true
        {
            retrieveLocalDestinations()
        }
        else
        {
            removeDestinationsFromMap()
        }
        
        //removeHomeMarkersFromMap()
        //removeAllHomeCirclesFromMap()
        
        removeAllHomeMarkersAndCirclesFromMap()
        retrieveLocalHome()
        //rebuildHomeCircles()
        
        if isHomeCircle == nil || isHomeCircle == true
        {
            isShowHomeCircle = true
            rebuildHomeCircles()
        }
        else
        {
            isShowHomeCircle = false
        }
        
        if isShowParts == true
        {
            retrieveLocalParts()
        }
        else
        {
            removePartsFromMap()
        }
        
        if isUnwindFromSearch == true
        {
            mapView.clear()
            
            print("List of bridges count = \(listOfBridges.count)") // println(listOfBridges)
            
            if listOfBridges.count >= 1
            {
                let bridges = listOfBridges[0] as! [String: AnyObject]
                
                if let bridgeLat = bridges["Latitude"] as? Double
                {
                    if let bridgeLon = bridges["Longitude"] as? Double
                    {
                        let camera = GMSCameraPosition.camera(withLatitude: bridgeLat,
                            longitude: bridgeLon, zoom: 8)
                        mapView.camera = camera
                    }
                    
                }
                drawMap(result: listOfBridges)
    
             }
            else  // No results found alert user
            {
                Helper.showUserMessage(title: "Search found 0 results", theMessage: "No bridges found", theViewController: self)

            }
         isUnwindFromSearch = false
            
         return
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // clear these so that rewriting default.realm will allow reload without having to restart app
        parts = nil
        home = nil
        dest = nil
    }

    
    // Happens before viewDidAppear - set flag for coming from search
    @IBAction func unwindToMapFromSearch(segue: UIStoryboardSegue) {
        print("unwindToMapFromSearch")
        isUnwindFromSearch = true
    }
    
    // Happens before viewDidAppear - set flag for coming from search
    @IBAction func unwindToMapFromCreate(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromCreate")
        isUnwindFromSearch = false
    }
    
    @IBAction func unwindToMapFromEdit(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromEdit")
        isUnwindFromSearch = false
    }
    
    @IBAction func unwindToMapFromCreateDestination(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromCreateDestination")
        isUnwindFromSearch = false
    }
    
    @IBAction func unwindToMapFromCreateHome(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromCreateHome")
        isUnwindFromSearch = false
        retrieveLocalHome() // reload the local markers
    }
    
    @IBAction func unwindToMapFromDeleteDestination(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromDeleteDestination")
        isUnwindFromSearch = false
        retrieveLocalDestinations() // reload the local markers
    }
    
    @IBAction func unwindToMapFromCreatePart(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromCreatePart")
        isUnwindFromSearch = false
        retrieveLocalDestinations() // reload the local markers
    }
    
    @IBAction func unwindToMapFromDeletePartsLoc(_ segue: UIStoryboardSegue) {
        print("unwindToMapFromDeletePartsLoc")
        isUnwindFromSearch = false
    }
    
    // MARK: Location Services
    @objc func checkLocationServicesEnabled() -> Bool
    {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return false
            case .restricted, .denied:
                print("Location services are not permitted")
                Helper.showUserMessage(title: "GPS not on or access restricted", theMessage: "Please allow location access to track vehicle location", theViewController: self)
                return false
            case .authorizedAlways:
                Helper.showUserMessage(title: "GPS not on or access restricted", theMessage: "Please allow location access to track vehicle location", theViewController: self)
                return false
            case .authorizedWhenInUse:
                print("Access OK")
                locationManager.startUpdatingLocation()
                return true
            @unknown default:
                Helper.showUserMessage(title: "GPS Status Unkown", theMessage: "Please allow location access to track vehicle location", theViewController: self)
                return false
            }
        } else {
            print("Location services are not enabled")
            Helper.showUserMessage(title: "Location Services Not Enabled", theMessage: "Please allow location access to track vehicle location", theViewController: self)
            return false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CLLocationManager - didFailWithError")
        print(error.localizedDescription)
        self.displayErrorMessage("Error finding location", duration: errorMessageDuration, onLabel: errorLabel)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            isOkToUseLocation = true
            locationManager.startUpdatingLocation()
        }
        else
        {
            mapView.isMyLocationEnabled = false
            mapView.settings.myLocationButton = false
            isOkToUseLocation = false
        }
    }
    
    /**
    * Called after a long-press gesture at a particular coordinate.
    *
    * @param mapView The map view that was pressed.
    * @param coordinate The location that was pressed.
    */
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D)
    {
        newLocation = coordinate
        performSegue(withIdentifier: "createSegue", sender: self)
    }
    
    /**
    * Called after a marker has been tapped.
    *
    * @param mapView The map view that was pressed.
    * @param marker The marker that was pressed.
    * @return YES if this delegate handled the tap event, which prevents the map
    *         from performing its default selection behavior, and NO if the map
    *         should continue with its default selection behavior.
    */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        newLocation = marker.position
        
        if let uData = marker.userData
        {
            if uData as? MarkerTypes == MarkerTypes.destination
            {
                performSegue(withIdentifier: "destinationDetailsSegue", sender: self)
            }
            else if uData as? MarkerTypes == MarkerTypes.bridgeHeight || uData as? MarkerTypes == MarkerTypes.bridgeWeight
            {
                performSegue(withIdentifier: "detailSegue", sender: self)
            }
            else if uData as? MarkerTypes == MarkerTypes.home
            {
                if let theHome = home
                {
                    for h in theHome
                    {
                        if h.latitude == marker.position.latitude && h.longitude == marker.position.longitude
                        {
                            confirmRemoveHome(home: h)
                        }
                    }
                }
            }
            else if uData as? MarkerTypes == MarkerTypes.parts
            {
                performSegue(withIdentifier: "partsDetailSegue", sender: self)
            }
        }
        else
        {
            performSegue(withIdentifier: "detailSegue", sender: self)
        }
        return true
    }
    
    var location1 :CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // currenty set to update ~ every 5 miles
        print("In didUpdateToLocation - lat = \(locations[0].coordinate.latitude)")
        
        /****
        let defaults = UserDefaults.standard
        let lastCacheDateTime = defaults.object(forKey: bridgeCacheKey) as? Date
        defaults.synchronize()   ***/
        
        // new location so record it
        currentLat = locations[0].coordinate.latitude
        currentLon = locations[0].coordinate.longitude
    
        /***
        if location1 == nil // grab first loc
        {
            location1 = CLLocation(latitude: currentLat, longitude: currentLon)
        }
        else
        {
            let location2 = CLLocation(latitude: currentLat, longitude: currentLon)
            let distanceInMeters = location2.distance(from: location1!)
            if distanceInMeters > distanceToUpdate
            {
            }
        }*****/
        
        mapView.camera = GMSCameraPosition.camera(withTarget: locations[0].coordinate, zoom: 8.0)
        didFindMyLocation = true
        
        // check cached data + valid cache before making this call
    
        /***
        if lastCacheDateTime == nil   // bridges ever cached? no then call api
        {
            getBridgeData(miles: numMilesToSearch)
         
        }
        else if let lastCachedAt = lastCacheDateTime
        {
            // bridge cache past expired time?  call api
            if let diff = Calendar.current.dateComponents([.hour], from: lastCachedAt, to: Date()).hour, diff > 24
            {
                getBridgeData(miles: numMilesToSearch)
            }
        }  ****/
        
         getBridgeData(miles: numMilesToSearch)
    }
    
    
    
    // reload within so mamy miles from my location
    @objc func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        
        print("In didTapMyLocation")
        didFindMyLocation = false   // reset for observer
       // mapView.clear()
        getBridgeData(miles: numMilesToSearch)
        return true // return true alter default behavior
    }
    
    @objc func getBridgeData(miles :Int)
    {
        activityIndicator.startAnimating()
        theToken = Helper.getTokenLocal()
        
        let urlAsString = "\(Constants.baseUrlAsString)/api/Bridge/GetByMiles"
        
        if let token = theToken.access_token
        {
            let URL = NSURL(string: urlAsString)
            var mutableURLRequest = URLRequest(url: URL! as URL)
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            mutableURLRequest.setValue("www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.httpMethod = HTTPMethod.get.rawValue
            
            let parameters = ["lat": "\(currentLat!)", "lon": "\(currentLon!)", "miles": "\(miles)"]
            
            print("paramteres = \(parameters)")
            // let encoding = URLEncoding.queryString
            
            do
            {
                mutableURLRequest = try URLEncoding.queryString.encode(mutableURLRequest, with: parameters)
                print("url request = \(mutableURLRequest)")
            }
            catch
            {
                print("Could not encode parameters")
                self.displayErrorMessage("Error creating network request", duration: errorMessageDuration, onLabel: errorLabel)
                activityIndicator.stopAnimating()
            }
            
            let manager = SessionManager.default
            let myRequest = manager.request(mutableURLRequest)
        
            // let flurryData = ["event": "getBridgeData api call"];
            Flurry.logEvent("API_call_getBridgeData", withParameters: nil);
           
            myRequest.responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers)
                { (Response) in
                    
                    self.activityIndicator.stopAnimating()
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
                        self.displayErrorMessage(error.localizedDescription, duration: self.errorMessageDuration, onLabel: self.errorLabel)
                        return
                    }
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        DispatchQueue.main.async
                        {
                            self.drawMap(result: resultAsJSON)
                            // OK cache and display
                           // self.saveBridgesToRealm(result: resultAsJSON)
                        }
                    }
                }
        }
        else
        {
            print("Not logged in go to Welcome VC")
            Helper.sendToLogin(theViewController: self)
        }
        
    }
    
    /***
    func saveBridgesToRealm(result: AnyObject)
    {
        DispatchQueue.global(qos: .background).async {
            
        let resultAsArray = result as! NSArray
        
        print("num bridges = \(resultAsArray.count)")

     
        for bridge in resultAsArray
        {
            // create new realm object
            let realmBridge = BridgeRealm()
            
            let b = bridge as! [String:AnyObject]
            
            let bridgeLat = b["Latitude"] as? Double
            let bridgeLon = b["Longitude"] as? Double
            
            print("lat = \(String(describing: bridgeLat))")
            
            // if lat or lon invalid don't try to save it
            if bridgeLat == nil || bridgeLon == nil { continue }
            if bridgeLat! < -90 || bridgeLat! > 90 { continue }
            if bridgeLon! < -180 || bridgeLon! > 180 { continue }
            
            realmBridge.latitude = bridgeLat!
            realmBridge.longitude = bridgeLon!
            
            let height = b["Height"] as? Double
            realmBridge.height.value = height
            
            let weightStraight = b["WeightStraight"] as? Double
            realmBridge.weightStraight.value = weightStraight
            
            let weightStraight_Tri = b["WeightStraight_TriAxle"] as? Double
            realmBridge.weightStraight_TriAxle.value = weightStraight_Tri
            
            let weightDouble = b["WeightDouble"] as? Double
            realmBridge.weightDouble.value = weightDouble
            
            let weightCombo = b["WeightCombination"] as? Double
            realmBridge.weightCombo.value = weightCombo
      
            let carried = b["FeatureCarried"] as? String
            realmBridge.featureCarried = carried
            
            let crossed = b["FeatureCrossed"] as? String
            realmBridge.featureCrossed = crossed
            
            let locationDescription = b["LocationDescription"] as? String
            realmBridge.locationDescription = locationDescription
            
            let state = b["State"] as? String
            realmBridge.state = state
            
            let county = b["County"] as? String
            realmBridge.county = county
            
            let town = b["Township"] as? String
            realmBridge.city = town
            
            let zip = b["Zip"] as? String
            realmBridge.zip = zip
            
            let country = b["Country"] as? String
            realmBridge.country = country
            
            let otherP = b["OtherPosting"] as? String
            realmBridge.otherPosting = otherP
            
            let numVotes = b["NumberOfVotes"] as? Int
            realmBridge.numVotes.value = numVotes ?? 0
            
            let isLocked = b["isLocked"] as? Bool
            realmBridge.isLocked.value = isLocked ?? true
            
            let isR = b["isRposted"] as? Bool
            realmBridge.isRPosted.value = isR

            // try save - persist the bridge to local storage
            do
            {
                // get the default Realm
                let realm = try Realm()
                
                try realm.write {
                    realm.add(realmBridge)
                }
            }
            catch { // error writing to realm db
                
                DispatchQueue.main.async {
                    self.displayErrorMessage("Error caching bridge", duration: 1, onLabel: self.errorLabel)
                }
            }
        } // end for
            
            // wrote all bridges to local storage - track when
            let defaults = UserDefaults.standard
            defaults.set(Date(), forKey: self.bridgeCacheKey)
            defaults.synchronize()
        
        } // end background
    }
    ****/
    
 
    @objc func drawMap(result: AnyObject)
    {
       // mapView.clear()
        removeBridgeWeightMarkersFromMap()
        removeBridgeHeightMarkersFromMap()
        
        let resultAsArray = result as! NSArray
        
        print("num bridges = \(resultAsArray.count)")
        
        for bridge in resultAsArray
        {
            let b = bridge as! [String:AnyObject]
            
            let bridgeLat = b["Latitude"] as? Double
            let bridgeLon = b["Longitude"] as? Double
            
            print("lat = \(String(describing: bridgeLat))")
            
            // if lat or lon invalid don't try to display it
            if bridgeLat == nil || bridgeLon == nil { continue }
            if bridgeLat! < -90 || bridgeLat! > 90 { continue }
            if bridgeLon! < -180 || bridgeLon! > 180 { continue }
            
            let height = b["Height"] as? Double
            if height != nil  // height
            {
                if isShowHeight
                {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(bridgeLat!, bridgeLon!)
                    marker.icon = UIImage(named: "marker_height2_orange.png")
                    marker.userData = MarkerTypes.bridgeHeight
                    marker.map = mapView
                    
                    bridgeHeightMarkers.append(marker)
                }
            }
            else // weight
            {
                if isShowWeight
                {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(bridgeLat!, bridgeLon!)
                    marker.icon = UIImage(named: "marker_weight2_orange.png")
                    marker.userData = MarkerTypes.bridgeWeight
                    marker.map = mapView
                    
                    bridgeWeightMarkers.append(marker)
                }
            }
        }
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createSegue"
        {
            let nextVc = segue.destination as! CreateTableViewController
            nextVc.lat = newLocation.latitude
            nextVc.lon = newLocation.longitude
        }
        else if segue.identifier == "detailSegue"
        {
            let nextVc = segue.destination as! DetailTableViewController
            nextVc.lat = newLocation.latitude
            nextVc.lon = newLocation.longitude
        }
        else if segue.identifier == "destinationDetailsSegue"
        {
            let nextVc = segue.destination as! DetailDestinationTableViewController
            
            if let d = dest
            {
                for destination in d
                {
                    // back off this a bit?
                    if destination.latitude == newLocation.latitude && destination.longitude == newLocation.longitude
                    {
                        nextVc.theDestination = destination
                    }
                }
            }
        }
        else if segue.identifier == "partsDetailSegue"
        {
            let nextVc = segue.destination as! DetailPartsLocationTableViewController
            
            if let p = parts
            {
                for destination in p
                {
                    if destination.latitude == newLocation.latitude && destination.longitude == newLocation.longitude
                    {
                        nextVc.thePartsLoc = destination
                    }
                }
            }
        }
    }
    
    // MARK: - display error message
    func displayErrorMessage(_ theMessage: String, duration: Double, onLabel: UILabel)
    {
        onLabel.isHidden = false
        onLabel.text = theMessage
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration)
        {
            onLabel.isHidden = true
        }
    }
    
    func setupErrorLabelUI(view :UIView) -> UILabel
    {
        let errorLabel = UILabel()
        
        errorLabel.text = ""
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(errorLabel)

        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -100))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0))
        
        return errorLabel
    }
    
    func setupRefreshUI(view :UIView)
    {
        let refreshButton = UIButton()
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setImage(UIImage(named: "refresh.png"), for: UIControl.State.normal)
        refreshButton.isHidden = false
        
        view.addSubview(refreshButton)
        
        refreshButton.addConstraint(NSLayoutConstraint(item: refreshButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
        refreshButton.addConstraint(NSLayoutConstraint(item: refreshButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
        
        view.addConstraint(NSLayoutConstraint(item: refreshButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: refreshButton, attribute: NSLayoutConstraint.Attribute.left, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 10))
    
        refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        return
    }
    
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    func setupActivityIndicatorUI(view :UIView)
    {
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        return
    }
    
    @objc func refreshButtonPressed()
    {
        confirmRefresh()
    }
    
    func confirmRefresh()
    {
        let alert = UIAlertController(title: "Refresh Bridge Data", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { (action) -> () in
            
            // need to set camera back to current loc
            let loc = CLLocation(latitude: self.currentLat, longitude: self.currentLon)
            self.mapView.camera = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 8.0)
            self.getBridgeData(miles: self.numMilesToSearch)
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }

    // MARK: Local Data and Markers
    /****
    func retrieveLocalBridges()
    {
        DispatchQueue.main.async {
            //print(Realm.Configuration.defaultConfiguration.fileURL!)

            do {
                self.removeBridgeHeightMarkersFromMap()
                self.removeBridgeWeightMarkersFromMap()
                self.bridgeHeightMarkers.removeAll()
                self.bridgeWeightMarkers.removeAll()
                
                let realm = try Realm()

                self.bridges = realm.objects(BridgeRealm.self)
                
                if let theBridges = self.bridges
                {
                    for  b in theBridges
                    {
                        let lat = b.latitude
                        let lon = b.longitude
                        
                        let marker = GMSMarker()
                        marker.position.latitude = lat
                        marker.position.longitude = lon
                        
                        // if lat or lon invalid don't try to display it
                        if b.latitude < -90 || b.longitude > 90 { continue }
                        if b.latitude < -180 || b.longitude > 180 { continue }
                    
                        if b.height.value != nil
                        {
                            if self.isShowHeight
                            {
                                marker.icon = UIImage(named: "marker_height2_orange.png")
                                marker.userData = MarkerTypes.bridgeHeight
                                self.bridgeHeightMarkers.append(marker)
                                marker.map = self.mapView
                            }
                        }
                        else
                        {
                            if self.isShowWeight
                            {
                                marker.icon = UIImage(named: "marker_weight2_orange.png")
                                marker.userData = MarkerTypes.bridgeWeight
                                self.bridgeWeightMarkers.append(marker)
                                marker.map = self.mapView
                            }
                        }
                  
                    }
                }
            }
            catch
            {
                // display error to user
                self.displayErrorMessage("Error loading bridges", duration: self.errorMessageDuration, onLabel: self.errorLabel)
            }
            
        }
    }  ***/
    
    func removeBridgeHeightMarkersFromMap()
    {
        for bridgeMarker in bridgeHeightMarkers
        {
            bridgeMarker.map = nil
        }
    }
    
    func removeBridgeWeightMarkersFromMap()
    {
        for bridgeMarker in bridgeWeightMarkers
        {
            bridgeMarker.map = nil
        }
    }
    
    // MARK: Local Data and Markers
    func retrieveLocalDestinations()
    {
        // query and update from any thread
        DispatchQueue.main.async {
           
            do {
                self.removeDestinationsFromMap()
                self.destinationMarkers.removeAll()
                
                let realm = try Realm()
                self.dest = realm.objects(Destination.self).filter("userName == '\(self.userName)'")
                
                if let destination = self.dest
                {
                    for destination in destination
                    {
                        let lat = destination.latitude
                        let lon = destination.longitude
                        
                        
                        let marker = GMSMarker()
                        marker.position.latitude = lat
                        marker.position.longitude = lon
                        marker.snippet = destination.name
                        
                        marker.icon = UIImage(named: "marker_destination2.png")
                        marker.userData = MarkerTypes.destination
                        
                        self.destinationMarkers.append(marker)
                        marker.map = self.mapView
                    }
                }
            }
            catch
            {
                // display error to user
                self.displayErrorMessage("Error loading destinations", duration: self.errorMessageDuration, onLabel: self.errorLabel)
            }
        
        }
    }

    func removeDestinationsFromMap()
    {
        for destMarker in destinationMarkers
        {
            destMarker.map = nil
        }
    }

    
    func retrieveLocalHome()
    {
        DispatchQueue.main.async {
            
            do {
                self.removeHomeMarkersFromMap()
                self.homeMarkers.removeAll()
                
                let realm = try Realm()
                self.home = realm.objects(Home.self).filter("userName == '\(self.userName)'")
                
                if let theHomeLocations = self.home
                {
                    for homeLocations in theHomeLocations
                    {
                        let lat = homeLocations.latitude
                        let lon = homeLocations.longitude
                        
                        let marker = GMSMarker()
                        marker.position.latitude = lat
                        marker.position.longitude = lon
                        
                        marker.icon = UIImage(named: "cabin.png")
                        marker.userData = MarkerTypes.home
                        
                        self.homeMarkers.append(marker)
                        marker.map = self.mapView
                        
                        // check if display home circle
                        if self.isShowHomeCircle == true
                        {
                            // show 100 mile (in meter) air radius
                            let circleCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let circle = GMSCircle(position: circleCenter, radius: self.oneHundredMilesInMeters)
                            // yellowish
                            circle.fillColor = UIColor(red: 250.0, green: 250.0, blue: 0.0, alpha: 0.10)
                            
                            self.homeCircles.append(circle)
                            circle.map = self.mapView
                        }
                    }
                }
            }
            catch
            {
                // display error to user
                self.displayErrorMessage("Error loading destinations", duration: self.errorMessageDuration, onLabel: self.errorLabel)
            }
            
        }
    }
    
    func retrieveLocalParts()
    {
        DispatchQueue.main.async {
            
            do {
                self.removePartsFromMap()
                self.partsMarkers.removeAll()
                
                let realm = try Realm()
                self.parts = realm.objects(PartsService.self).filter("userName == '\(self.userName)'")
                
                if let thePartsLocations = self.parts
                {
                    for partLocations in thePartsLocations
                    {
                        let lat = partLocations.latitude
                        let lon = partLocations.longitude
                        
                        let marker = GMSMarker()
                        marker.position.latitude = lat
                        marker.position.longitude = lon
                        
                        marker.icon = UIImage(named: "repair.png")
                        marker.userData = MarkerTypes.parts
                        
                        self.partsMarkers.append(marker)
                        marker.map = self.mapView
                    }
                }
            }
            catch
            {
                // display error to user
                self.displayErrorMessage("Error loading parts / service locations", duration: self.errorMessageDuration, onLabel: self.errorLabel)
            }
        }
    }
    
    
    func removeHomeMarkersFromMap()
    {
        for homeMarker in homeMarkers
        {
            homeMarker.map = nil
        }
    }
    
    func removePartsFromMap()
    {
        for parts in partsMarkers
        {
            parts.map = nil
        }
    }
    
    func removeHomeFromMap(lat: Double, lon: Double)
    {
        for (i,homeMarker) in homeMarkers.enumerated()
        {
            if homeMarker.position.latitude == lat &&
                homeMarker.position.longitude == lon
            {
                homeMarker.map = nil
                homeMarkers.remove(at: i)
            }
        }
        
        for (homeCircle) in homeCircles
        {
            if homeCircle.position.latitude == lat &&
                homeCircle.position.longitude == lon
            {
                homeCircle.map = nil
            }
        }
    }
    
    func removeAllHomeMarkersAndCirclesFromMap()
    {
        for homeMarker in homeMarkers
        {
            homeMarker.map = nil
        }
        
        homeMarkers.removeAll()
        
        for homeCircle in homeCircles
        {
            homeCircle.map = nil
        }
        
        homeCircles.removeAll()
    }
    
    func removeAllHomeCirclesFromMap()
    {
        for homeCircle in homeCircles
        {
            homeCircle.map = nil
        }
    }
    
    func rebuildHomeCircles()
    {
        removeAllHomeCirclesFromMap()
        homeCircles.removeAll()
        
        for marker in homeMarkers
        {
            let circleCenter = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            let circle = GMSCircle(position: circleCenter, radius: self.oneHundredMilesInMeters)
            // yellowish
            circle.fillColor = UIColor(red: 250.0, green: 250.0, blue: 0.0, alpha: 0.10)
            
            self.homeCircles.append(circle)
            
            if isShowHomeCircle
            {
                circle.map = mapView
            }
        }
    }
    
    func confirmRemoveHome(home: Home)
    {
        let alert = UIAlertController(title: "Delete Home", message: "Remove home marker", preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { (action) -> () in
                do
                {
                    // get the default Realm
                    let realm = try Realm()
                    let lat = home.latitude
                    let lon = home.longitude
                    
                    try realm.write {
                        realm.delete(home)
                    }
                
                    self.removeHomeFromMap(lat: lat, lon: lon)
                }
                catch { // error writing to realm db
                    
                    Helper.showUserMessage(title: "Error removing home", theMessage: "Try Again", theViewController: self)
                }
       }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        
        present(alert, animated: true, completion: nil)
        
    }

}
