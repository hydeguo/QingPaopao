//
//  MediaRequest.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/8.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import Alamofire

public func uploadImage(fileName:String ,imageData:Data, callback:@escaping (_ response : String?)->Void){
   
    let imageUrl = server_url + "/uploadImage"
    Alamofire.upload( multipartFormData: { multipartFormData in
        
        multipartFormData.append(imageData, withName: "file", fileName: fileName, mimeType: "image/png")
        
    },to:imageUrl,headers:nil, encodingCompletion: { encodingResult in
        
        switch encodingResult {
        case .success(let upload, _, _):
            upload.responseJSON { response in
                debugPrint("SUCCESS RESPONSE: \(response)")
                let url = GetValue(obj: response.result.value as AnyObject, field: "url", defaultVal:"")
                callback(server_url+url)
            }
        case .failure(let encodingError):
            //                self.removeSpinnerFromView()
            print("ERROR RESPONSE: \(encodingError)")
            callback(nil)
        }
    })
    
}

public  func GetValue<T>(obj : AnyObject, field : String, defaultVal : T) -> T {
    let jsf = obj[field] as AnyObject?
    if let d = jsf as? T {
        return d
    } else {
        return defaultVal
    }
}
