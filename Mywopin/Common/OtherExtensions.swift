//
//  OtherExtensions.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/23.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red * 255.0 }
    var greenValue: CGFloat{ return CIColor(color: self).green  * 255.0 }
    var blueValue: CGFloat{ return CIColor(color: self).blue  * 255.0 }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha  * 255.0 }
}


extension String {
    var MD5: String {
        let cStrl = cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue));
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16);
        
        CC_MD5(cStrl, CC_LONG(strlen(cStrl!)), buffer);
        
        var md5String = "";
        
        for idx in 0...15 {
            
            let obcStrl = String.init(format: "%02x", buffer[idx]);
            
            md5String.append(obcStrl);
            
        }
        free(buffer);
        
        return md5String;
    }
}

extension String {
    //返回字数
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Date{
    
    /*
     几年几月 这个月的多少天
     */
    static func getDaysInMonth( year: Int, month: Int) -> Int{
        
        let calendar = NSCalendar.current
        
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        
        let endComps = NSDateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        
        let startDate = calendar.date(from: startComps as DateComponents)
        let endDate = calendar.date(from:endComps as DateComponents)!
        
        let diff = calendar.dateComponents([.day], from: startDate!, to: endDate)
        
        return diff.day!;
    }
    /*
     几年几月 这个月的第一天是星期几
     */
    static func firstWeekdayInMonth(year: Int, month: Int)->Int{
        
        let calender = NSCalendar.current;
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calender.date(from: startComps as DateComponents)
        let firstWeekday = calender.ordinality(of: .weekday, in: .weekOfMonth, for: startDate!)
        let week = firstWeekday! - 1;
        
        return week ;
    }
    
    /*
     今天是星期几
     */
    func dayOfWeek() -> Int {
        let interval = self.timeIntervalSince1970;
        let days = Int(interval / 86400);// 24*60*60
        return (days - 3) % 7;
    }
    static func getCurrentDay() ->Int {
        
        let com = self.getComponents();
        return com.day!
    }
    
    static func getCurrentMonth() ->Int {
        
        let com = self.getComponents();
        return com.month!
    }
    
    static func getCurrentYear() ->Int {
        
        let com = self.getComponents();
        return com.year!
    }
    
    static func getComponents()->DateComponents{
        
        let calendar = NSCalendar.current;
        //这里注意 swift要用[,]这样方式写
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from:Date());
        return com
    }
    
}

extension String {
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}

extension String {
    ///去掉字符串标签
    
    mutating func filterHTML() -> String?{
        
        let scanner = Scanner(string: self)
        var text: NSString?
        while !scanner.isAtEnd {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            self = self.replacingOccurrences(of: "\(text == nil ? "" : text!)>", with: "")
            
        }
        return self
    }
}



public extension UIDevice {
    
    public enum DeviceName {
        case iPhone
        case iPodTouch5
        case iPodTouch6
        case iPhone4
        case iPhone4s
        case iPhone5
        case iPhone5s
        case iPhone5c
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhoneSE
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iphoneX
        case ipad2
        case ipad3
        case ipad4
        case ipad5
        case ipadAir
        case ipadAir2
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro9_7
        case iPadPro12_9
        case iPadPro10_5
        case iPadPro12_9_2
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return "iPhone"
        }
    }
    
}
