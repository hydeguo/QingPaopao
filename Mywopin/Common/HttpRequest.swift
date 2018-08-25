//
//  HttpRequest.swift
//
//  Created by Hydeguo on 10/07/2017.
//  Copyright © 2017 onwardsmg. All rights reserved.
//

//import Foundation
//import Alamofire
//import SwiftyJSON
//
//class HttpRequest {
//    
//    
//
//    
//    public static func login(_ name:String,_ ps:String, callback:@escaping (String?)->Void)->Void{
//    
//        let param = [
//           "username_email":name,
//           "password":ps
//        ]
//        Alamofire.request(server_url+":"+http_port+"/viewers/login", method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { response in
//            //            print(json)
//            if  response.result.error == nil && response.data != nil {
//                print("login response:\(String(describing: response))")
//                do{
////                     let loginResponse:LoginResponse = try JSONDecoder().decode(LoginResponse.self, from: response.data!)
//                    var data = try JSON(data: response.data!)
//                    
//                        taken = data["token"].stringValue
//                        myClientVo = ClientVo(id: data["_id"].stringValue,name: data["username"].stringValue, email: data["email"].stringValue, isOnline: true)
//                        callback(taken)
//               
//                }catch{
//                    print("[login response error]:\(error.localizedDescription)")
//                }
//                
//            }else{
//                
//                _ = SweetAlert().showAlert("Sorry!", subTitle: response.result.error?.localizedDescription, style: AlertStyle.warning)
//                
//                callback(nil)
//            }
//        }
//    }
//    
//    public static func logout(_ email:String)->Void{
//        
//        let param = [
//            "email":email
//        ]
//        Alamofire.request((server_url+":"+http_port+"/logout/"+email),method:.post,parameters:param,encoding: JSONEncoding.default).responseJSON {(json) in
//            print("logout :\(json)")
//        }
//    }
//    
//   
//    
//    
//    
//    
//
//    public static func sendWatchReport(vo:VideoVo,videoUrl:String){
//        
//        let dateFormator = DateFormatter()
//        dateFormator.dateFormat = "MMM dd,yyyy,hh:mm:ss"
//        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
//        
//        let infoDic = Bundle.main.infoDictionary
//        let json = ["usageReports":[
//            
//            "productCode"  : "OP",
//            "projectCode"  : "OMGPRO",
//            "deviceType"   : "IOS",
//            "deviceModel"  : UIDevice.current.model,
//            "deviceOS"     : UIDevice.current.systemVersion,
//            "deviceId"     : UIDevice.current.identifierForVendor!.uuidString,
//            "userId"       : myClientVo!.email,
//            "timeUTC"      : Date().timeIntervalSince1970,
//            "errorCode"  : 200,
//            "errorMsg"   : "NO ERROR",
//            
//            "appVersion" : String(describing: infoDic?["CFBundleShortVersionString"]),
//            "appName" : String(describing: infoDic?["CFBundleDisplayName"]),
//            "video": [
//                "appID":"Pro Demo",
//                "appVersion": "1.0",
//                "videoID": vo.id!,
//                "videoType": vo.type!,
//                "videoName": vo.detail!["en"]!.title,
//                "videoUrl": videoUrl,
//                "playbackStatus": "Success",
//                "sessionID": myClientVo!.id,
//                "action": "",
//                "viewDurationInSec": 0,
//                "tags": [],
//                "interrupts": 15,
//                "totalBufferTimeInSec": 60,
//                "trafficInBytes": 0,
//                "clientIP": GetIPAddresses()!
//            ]
//            ]]
//        
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: json,
//                                                      options: .prettyPrinted)
//            
//            let myURL = URL(string: "http://210.5.181.70:5624/video")!
//            let request = NSMutableURLRequest(url: myURL as URL)
//            request.httpMethod = "POST"
//            
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            request.httpBody = jsonData
//            let task = URLSession.shared.dataTask(with: request as URLRequest) {
//                data, response, error in
////                print("sendReport response:\(response)")
////                print("sendReport error:\(error)")
//            }
//            task.resume()
//            
//        } catch let error {
//            print("error converting to json: \(error)")
//            return
//        }
//    }
//
//    public static func ArrayJsonToArrayString(_ arrayJson:[JSON])->[String]{
//        var arrayString = [String]()
//        for one in arrayJson {
//            arrayString.append(one.stringValue)
//        }
//        return arrayString
//    }
//    
//    
//    
//}



