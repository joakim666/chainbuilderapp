//
//  Extensions.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-03-04.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

// Allow creation of an UIColor instance from a hex string
extension UIColor {
    
    /**
     Creates a UIColor instance from the given hex string.
     
     - parameters:
        - hexString:    The hex string to make an UIColor instance from.
     
    */
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    /**
      Creates a hex string describing the color represented by the UIColor instance.
    */
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

// Usage example:
//
//    if UIDevice().type == .simulator {
//       print("You're running on the simulator... boring!")
//    } else {
//       print("Wow! Running on a \(UIDevice().type.rawValue)")
//    }
public enum Model : String {
    case simulator = "simulator/sandbox",
    iPod1          = "iPod 1",
    iPod2          = "iPod 2",
    iPod3          = "iPod 3",
    iPod4          = "iPod 4",
    iPod5          = "iPod 5",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPad4          = "iPad 4",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5C       = "iPhone 5C",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadMini3      = "iPad Mini 3",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6Splus   = "iPhone 6S Plus",
    iPhoneSE       = "iPhone SE",
    iPhone7        = "iPhone 7",
    iPhone7plus    = "iPhone 7 Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad2,5"   : .iPadMini1,
            "iPad2,6"   : .iPadMini1,
            "iPad2,7"   : .iPadMini1,
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPad4,1"   : .iPadAir1,
            "iPad4,2"   : .iPadAir2,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,3" : .iPhone7,
            "iPhone9,4" : .iPhone7plus,
            ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        
        return Model.unrecognized
    }
}

// Allows creating of system icons for use with e.g. UIButton
extension UIImage{
    
    class func imageFromSystemBarButton(_ systemItem: UIBarButtonSystemItem, renderingMode:UIImageRenderingMode = .automatic)-> UIImage {
        
        let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        
        // add to toolbar and render it
        UIToolbar().setItems([tempItem], animated: false)
        
        // got image from real uibutton
        let itemView = tempItem.value(forKey: "view") as! UIView
        
        for view in itemView.subviews {
            if view is UIButton {
                let button = view as! UIButton
                let image = button.imageView!.image!
                image.withRenderingMode(renderingMode)
                return image
            }
        }
        
        return UIImage()
    }
}
