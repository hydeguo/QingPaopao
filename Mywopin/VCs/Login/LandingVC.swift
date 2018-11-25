//
//  LandingVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/18.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

import UIKit
import Moya


class LandingVC: UIViewController {
    
    
    
    //MARK: Push to relevant ViewController
    func pushTo(viewController: ViewControllerType)  {
        switch viewController {
        case .conversations:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainPage")
            self.present(vc!, animated: false, completion: nil)
            break
        case .welcome:
           
            let vc =  R.storyboard.login.loginPage()
            self.present(vc!, animated: false, completion: nil)
            break
        }
    }
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            if let userId = userInformation["userId"] as? String,
            let password = userInformation["password"] as? String,
            let platform = userInformation["platform"] as? String
            {
                if(platform == "0"){
                    login(phone: userId, psw: password, platform: 0) { (user) in
                        if user != nil
                        {
                            self.gotoMainScene()
                        }else{
                            self.pushTo(viewController: .welcome)
                        }
                    }
                }else{
                    let platformID = UInt(platform)
                    if(platformID == SSDKPlatformType.typeQQ.rawValue){
                        doThirdLogin(type: SSDKPlatformType.typeQQ)
                    }else if(platformID == SSDKPlatformType.typeWechat.rawValue){
                        doThirdLogin(type: SSDKPlatformType.typeWechat)
                    }else if(platformID == SSDKPlatformType.typeSinaWeibo.rawValue){
                        doThirdLogin(type: SSDKPlatformType.typeSinaWeibo)
                    }
                }
            }else{
                self.pushTo(viewController: .welcome)
            }
            
        }else{
            self.pushTo(viewController: .welcome)
        }
    }
    
    func doThirdLogin(type:SSDKPlatformType)
    {
        let user = ShareSDK.currentUser(type)
        if user?.credential != nil{
            myThirdpartyVo = ShareSDK.currentUser(type)
            thirdPartyLogin(userID:user!.credential.uid , platform: type.rawValue) { (returnUser) in
                if( returnUser?.icon?.contains("profileIcon.png") == true ){
                    _ = Wolf.request(type: MyAPI.changeIcon(icon: user!.icon), completion: { (returnUser2: User?, msg, code) in
                    }, failure: nil)
                }
                if returnUser != nil
                {
                    self.gotoMainScene()
                }else{
                    self.pushTo(viewController: .welcome)
                }
            }
        }else{
            self.pushTo(viewController: .welcome)
        }
    }
    
    
    @objc func gotoMainScene()
    {
        let vc = R.storyboard.main.mainPage()
        self.present(vc!, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.navigationController?.setNavigationBarHidden(false, animated: false)
    //
    //    }
    
}


