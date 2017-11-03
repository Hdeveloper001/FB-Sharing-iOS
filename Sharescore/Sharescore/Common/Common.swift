//
//  Common.swift
//  My-Mo
//
//  Created by iDeveloper on 10/11/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ImageIO
import AVFoundation



class Common: NSObject, UIAlertViewDelegate {
    
    func methodForAlert (titleString:String, messageString:String, OKButton:String, CancelButton:String, viewController: UIViewController){
        
//        let alertView = UIAlertView()
//        
//        alertView.title = titleString
//        alertView.message = messageString
//        if (OKButton != ""){
//            alertView.addButton(withTitle: OKButton)
//        }
//        if (CancelButton != ""){
//            alertView.addButton(withTitle: CancelButton)
//        }
//        alertView.show()
        
        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: CancelButton, style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
//            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//            print("OK")
        }
        
        if (CancelButton != ""){
            alertController.addAction(cancelAction)
        }
        
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func X(view: UIView) -> CGFloat{
        return view.frame.origin.x
    }
    
    func Y(view: UIView) -> CGFloat{
        return view.frame.origin.y
    }
    
    func WIDTH(view: UIView) -> CGFloat{
        return view.bounds.size.width
    }
    
    func HEIGHT(view: UIView) -> CGFloat{
        return view.bounds.size.height
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func methodIsValidEmailAddress(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailTest.evaluate(with: email) != true {
            return false
        }
        else {
            return true
        }
    }
    
    func convertTimestamp(aTimeStamp: String) -> String{
        let date = Date(timeIntervalSince1970: Double(aTimeStamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedDateString = dateFormatter.string(from: date)
        return formattedDateString
    }
    
    func get_Current_UTC_Date() -> String{
        let date = Date()
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        return dateformattor.string(from: date)
    }
    
    func get_Current_UTC_Time() -> String{
        let date = Date()
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        return dateformattor.string(from: date)
    }
    
    func get_Current_UTC_Date_Time() -> String{
        let date = Date()
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        return dateformattor.string(from: date)
    }
    
    func get_Date_time_from_UTC_time(string : String) -> String {
        
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let dt = string
        let dt1 = dateformattor.date(from: dt as String)
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.local
        return dateformattor.string(from: dt1!)
    }
    
    func get_Date_from_UTC_time(string : String) -> String {
        
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let dt = string
        let dt1 = dateformattor.date(from: dt as String)
        dateformattor.dateFormat = "yyyy-MM-dd"
        dateformattor.timeZone = NSTimeZone.local
        return dateformattor.string(from: dt1!)
    }
    
    func get_Time_from_UTC_time(string : String) -> String {
        
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let dt = string
        let dt1 = dateformattor.date(from: dt as String)
        dateformattor.dateFormat = "HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.local
        return dateformattor.string(from: dt1!)
    }

    func getLabelSize(text: NSString, size: CGSize, font: UIFont) -> CGSize{
//        let cellFont: UIFont = UIFont.systemFont(ofSize: 12)
        let constraintSize: CGSize = CGSize(width: size.width, height: CGFloat(MAXFLOAT))
        let r: CGRect = text.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return CGSize(width: r.size.width, height: r.size.height)
    }
}

class ImageProcessing: NSObject{
    
    func makeRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageLayer = CALayer()
        imageLayer.backgroundColor = UIColor.clear.cgColor
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageLayer.contents = (image.cgImage! as Any)
        imageLayer.masksToBounds = true
//        imageLayer.cornerRadius = CGFloat(radius)
        imageLayer.cornerRadius = image.size.width / 2
        UIGraphicsBeginImageContext(image.size)
        imageLayer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return roundedImage
    }
    
    func makeMergeImage(bottomImage: UIImage, topImage: UIImage) -> UIImage{
        let size = CGSize(width: 40, height: 54)
        UIGraphicsBeginImageContext(size)
        
        let areaSize00 = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let areaSize01 = CGRect(x: 2, y: 2, width: 36, height: 36)
        bottomImage.draw(in: areaSize00)
        topImage.draw(in: areaSize01, blendMode: .normal, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imageSize(with url: NSURL) -> CGSize {
        
        var size: CGSize = .zero
        let source = CGImageSourceCreateWithURL(url, nil)!
        let options = [kCGImageSourceShouldCache as String: false]
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, options as CFDictionary?)  {
            
            if let properties = properties as? [String: Any],
                let width = properties[kCGImagePropertyPixelWidth as String] as? Int,
                let height = properties[kCGImagePropertyPixelHeight as String] as? Int {
                size = CGSize(width: width, height: height)
            }
        }
        
        return size
    }
    
    func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        
        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    
}

class Station: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}


class ImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        let colors: [CGColor] = [
            UIColor.clear.cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,
            UIColor.clear.cgColor ]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,  0.3, 0.5, 0.7, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

