//
//  NoticeController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/5.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import AudioToolbox
import UserNotifications

class NoticeController
{
    
    //振动
    @IBAction func systemVibration(sender: AnyObject) {
        //建立的SystemSoundID对象
        let soundID = SystemSoundID(kSystemSoundID_Vibrate)
        //振动
        AudioServicesPlaySystemSound(soundID)
    }
    
    let drinkNoticeNormal = [[7,30,"清晨一杯富氢水，美丽心情一整天"],
                [9,00,"努力工作，尽情收获，喝杯富氢水吧"],
                [11,00,"勤喝富氢水可保持健康身体，美丽容颜"],
                [13,00,"提神醒脑喝一杯吧"],
                [15,00,"累了吗？喝杯富氢水吧！"],
                [17,30,"为了今天的圆满工作庆贺，干杯！^_^"],
                [20,00,"排毒养颜喝一杯"],
                [22,00,"放松、减压，离不开多喝富氢水哦！"]]
    
    func createLocalNotice()
    {
        for item in drinkNoticeNormal
        {
            var dateComponents = DateComponents()
            dateComponents.hour = item[0] as? Int
            dateComponents.minute = item[1] as? Int
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "喝水提醒"
//            content.subtitle = "Lets code,Talk is cheap"
            content.body = item[2] as! String
            content.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier:item[2] as! String, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request){(error) in
                
                if (error != nil){
                    print(error?.localizedDescription as Any)
                }else{
                    //    print("Notifcation is there.")
                }
            }
        }
    }
}
