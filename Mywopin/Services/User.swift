//
//  User.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/21.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import PKHUD

func thirdPartyRegisterUser(  userName: String,userID: String,platform:UInt, completion: @escaping (Bool) -> Swift.Void) {
    HUD.show(.progress)
    _ = Wolf.request(type: MyAPI.thirdRegister(userName: userName, key: userID, type: String(platform)), completion: { (user: User?, msg, code) in
        completion(true)
        HUD.hide()
    }) { (error) in
        _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        completion(false)
        HUD.hide()
    }
    
}
func thirdPartyLogin( userID:String,platform:UInt,completion: @escaping (User?) -> Swift.Void)
{
    HUD.show(.progress)
    _ = Wolf.request(type: MyAPI.thirdLogin(key: userID, type: String(platform)), completion: { (user: User?, msg, code) in
        
        if(code == "0")
        {
            //                    print(user?.userId)
            myClientVo = user
            let userInfo = ["userId" : userID, "password" : "","platform":String(platform)]
            UserDefaults.standard.set(userInfo, forKey: "userInformation")
            completion(user)
            HUD.hide()
            return
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            completion(nil)
            HUD.hide()
        }
    }) { (error) in
        _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        completion(nil)
        HUD.hide()
    }
}

func registerUser( phone: String, userName: String,password: String, v_code: String, completion: @escaping (User?) -> Swift.Void) {
   
    _ = Wolf.request(type: MyAPI.register(phone: phone, userName: userName, password: password, v_code: v_code), completion: { (user: User?, msg, code) in
        
        if(code == "0")
        {
            //                    print(user?.userId)
            myClientVo = user
            let userInfo = ["userId" : phone, "password" : password,"platform":"0"]
            UserDefaults.standard.set(userInfo, forKey: "userInformation")
            completion(user)
            return
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            completion(nil)
        }
    }) { (error) in
        _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        completion(nil)
    }

}

func login( phone:String, psw:String,platform:UInt,completion: @escaping (User?) -> Swift.Void)
{
    _ = Wolf.request(type: MyAPI.login(phone: phone, password: psw), completion: { (user: User?, msg, code) in
        
        if(code == "0")
        {
            //                    print(user?.userId)
            myClientVo = user
            let userInfo = ["userId" : phone, "password" : psw,"platform":String(platform)]
            UserDefaults.standard.set(userInfo, forKey: "userInformation")
            completion(user)
            return
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            completion(nil)
        }
    }) { (error) in
        _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        completion(nil)
    }
}


func getCode( phone:String,completion: @escaping (Bool) -> Swift.Void)
{
    _ = Wolf.request(type: MyAPI.getCode(phone: phone), completion: { (info: BaseReponse?, msg, code) in
        
        if(code == "0")
        {
            completion(true)
            return
        }
        else
        {
            completion(false)
        }
    }) { (error) in
        completion(false)
    }
}

func changePassword( userID: String,password: String, v_code: String, completion: @escaping (Bool) -> Swift.Void) {
    
    _ = Wolf.request(type: MyAPI.changePassword(userId: userID,  password: password, v_code: v_code), completion: { (info: BaseReponse?, msg, code) in
        
        if(code == "0")
        {
            let userInfo = ["userId" : userID, "password" : password,"platform":"0"]
            UserDefaults.standard.set(userInfo, forKey: "userInformation")
            completion(true)
            return
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            completion(false)
        }
    }) { (error) in
        _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        completion(false)
    }
    
}

func refreshUserData(completion: @escaping (Bool) -> Swift.Void) {
    _ = Wolf.request(type: MyAPI.getUserData, completion: { (user: User?, msg, code) in
        if(code == "0")
        {
            myClientVo = user
            completion(true)
        }
        else
        {
            completion(false)
        }
    }) { (error) in
        completion(false)
    }
    
}
