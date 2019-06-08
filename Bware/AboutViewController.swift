//
//  AboutViewController.swift
//  Bware
//
//  Created by James on 7/5/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import GoogleMaps
import StoreKit
import BFPaperButton

class AboutViewController: UIViewController, SKStoreProductViewControllerDelegate {
    
    
    @IBOutlet weak var shareButton: BFPaperButton!
    @IBOutlet weak var rateButton: BFPaperButton!
    @IBOutlet weak var label1: CustomLabel!
    @IBOutlet weak var label2: CustomLabel!
    @IBOutlet weak var label3: CustomLabel!
    @IBOutlet weak var disclaimerLabel: CustomLabel!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var googleMapsLegal: UITextView!
    
    @objc var storeVC: SKStoreProductViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.styleButton(theButton: shareButton)
        Helper.styleButton(theButton: rateButton)
        
        theScrollView.contentSize = CGSize(width: 900, height: 502)

        googleMapsLegal.text = GMSServices.openSourceLicenseInfo()
    }
    
    @objc func drawLabelWithBorder(theLabel: UILabel)
    {
        let img = UIImage(named: "bubble.png")
        let imgSize = theLabel.frame.size
        
        UIGraphicsBeginImageContext(imgSize)
        img?.draw(in: CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let img = newImage
        {
            theLabel.backgroundColor = UIColor(patternImage: img)
        }
    }
    
    @IBAction func ratePressed(sender: UIButton)
    {
        storeVC = SKStoreProductViewController()
        storeVC.delegate = self
        
        let productParams = [ SKStoreProductParameterITunesItemIdentifier : "627908713" ]   // id for all my apps
    
        storeVC.loadProduct(withParameters: productParams) { (result, error) in
    
            if result == true
            {
    
                self.present(self.storeVC, animated: true, completion: nil)
            }
            else
            {
                Helper.showUserMessage(title: "App info not found", theMessage: "Please try again later", theViewController: self)
            }
        
        }
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func sharePressed(sender: UIButton)
    {
        
        // FB does not show pre-filled text but shows link to app - twitter, mail, message ...
        let theMessage = "I'm using the B*ware iOS app to assist drivers in locating posted bridges. Please join in and help improve the data."
        
        let theURL = NSURL(string: "https://itunes.apple.com/us/app/b*ware/id1039988525?mt=8")
        
        let itemsToShare :[Any] = [theMessage, theURL!]
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
         activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.print]
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    

}


class CustomLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
   required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        let HEIGHTOFPOPUPTRIANGLE:CGFloat = 20.0
        let WIDTHOFPOPUPTRIANGLE:CGFloat = 40.0
        let borderRadius:CGFloat = 8.0
        let strokeWidth:CGFloat = 3.0
        
        // Get the context
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        //
        let currentFrame: CGRect = self.bounds
        context.setLineJoin(CGLineJoin.round)
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        // Draw and fill the bubble
        
        context.beginPath()
        
        context.move(to: CGPoint(x: borderRadius + strokeWidth + 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5))
        context.addLine(to: CGPoint(x: round(currentFrame.size.width / 2.0 - WIDTHOFPOPUPTRIANGLE / 2.0) + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5))
        context.addLine(to: CGPoint(x: round(currentFrame.size.width / 2.0) + 0.5, y: strokeWidth + 0.5))
        context.addLine(to: CGPoint(x: round(currentFrame.size.width / 2.0 + WIDTHOFPOPUPTRIANGLE / 2.0) + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5))
        
        context.addArc(tangent1End:  CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5), tangent2End:  CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)

        context.addArc(tangent1End:  CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End:  CGPoint(x: round(currentFrame.size.width / 2.0 + WIDTHOFPOPUPTRIANGLE / 2.0) - strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
    

        context.addArc(tangent1End:  CGPoint(x: strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End:  CGPoint(x: strokeWidth + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End:  CGPoint(x: strokeWidth + 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5), tangent2End:  CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
        
        context.closePath()
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        drawText(in: rect)
        print("drawRect has updated the view")
    }
    
    override func drawText(in rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        if context == nil { return }
        
        context!.textMatrix = CGAffineTransform.identity
        context!.translateBy(x: 0.0, y: rect.size.height+10)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        super.drawText(in: rect)
    }
    
}
