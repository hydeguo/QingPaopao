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
