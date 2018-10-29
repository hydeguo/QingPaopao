//
//  ThirdPartLoginVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/18.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import PKHUD


class ThirdPartLoginVC: UIViewController {
    
    @IBOutlet var wechatLoginBtn:UIButton!
    @IBOutlet var sinaLoginBtn:UIButton!
    @IBOutlet var QQLoginBtn:UIButton!
    
    
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        wechatLoginBtn.titleLabel?.font = UIFont.iconfont(size: 40)
//        wechatLoginBtn.setTitle("\u{e743}", for: .normal)
    }
    
    
    //授权QQ登录
    @IBAction func qqAuth(sender: UIButton) {
        HUD.show(.progress)
        let qqUser = ShareSDK.currentUser(SSDKPlatformType.typeQQ)
        //不为空直接登录 为空进行注册
        if qqUser?.credential != nil {
            //登录
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeQQ, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    print((user?.credential.uid)!)
                    print((user?.credential.token)!)
                    
                    //登录
                    if(user != nil){
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeQQ.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeQQ)
                            }
                        })
                    }
                    
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:  self.onCancel()
                default:
                    break
                }
            })
        } else {
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeQQ, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    print((user?.credential.uid)!)
                    print((user?.credential.token)!)
                    //注册并登录
                    if(user != nil)
                    {
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeQQ.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeQQ)
                            }
                        })
                    }
                    break
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:  self.onCancel()
                default:
                    break
                }
            })
        }
    }
    //授权微信登录
    @IBAction func weChatAuth(_ sender: UIButton) {
        HUD.show(.progress)
        let wechatUser = ShareSDK.currentUser(SSDKPlatformType.typeWechat)
        //不为空直接登录 为空进行注册
        if wechatUser?.credential != nil {
            //登录
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeWechat, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    //登录
                    if(user != nil){
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeWechat.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeWechat)
                            }
                        })
                    }
                    break
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:  self.onCancel()
                default:
                    break
                }
            })
        } else {
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeWechat, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    //注册并登录
                    if(user != nil)
                    {
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeWechat.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeWechat)
                            }
                        })
                    }
                    break
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:  self.onCancel()
                default:
                    break
                }
            })
        }
    }
    
    //授权微博登录
    @IBAction func sinaAuth(_ sender: UIButton) {
        HUD.show(.progress)
        let weiboUser = ShareSDK.currentUser(SSDKPlatformType.typeSinaWeibo)
        //不为空直接登录 为空进行注册
        if weiboUser?.credential != nil {
            //登录
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeSinaWeibo, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    print((user?.credential.uid)!)
                    print((user?.credential.token)!)
                    //登录
                    if(user != nil){
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeSinaWeibo.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeSinaWeibo)
                            }
                        })
                    }
                    break
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:  self.onCancel()
                default:
                    break
                }
            })
        } else {
            //此方法无论是否授权过,都会进行授权
            ShareSDK.authorize(SSDKPlatformType.typeSinaWeibo, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    print((user?.credential.uid)!)
                    print((user?.credential.token)!)
                    //注册并登录
                    if(user != nil)
                    {
                        thirdPartyRegisterUser(userName: user!.nickname, userID: (user?.credential.uid)!, platform: SSDKPlatformType.typeSinaWeibo.rawValue, completion: { (flag) in
                            if(flag == true){
                                self.sampleLogin(user: user!, platform:.typeSinaWeibo)
                            }
                        })
                    }
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel: self.onCancel()
                default:
                    break
                }
            })
        }
    }
    
    func onCancel()
    {
        print("操作取消")
        HUD.hide()
    }
    
    func sampleLogin(user:SSDKUser, platform:SSDKPlatformType){

        thirdPartyLogin(userID: user.credential.uid, platform:  platform.rawValue,  completion: { (userData) in
            if(userData != nil){
                myClientVo = userData
                if( userData?.icon == nil ){
                    myClientVo?.icon = user.icon;
                    _ = Wolf.request(type: MyAPI.changeIcon(icon: user.icon), completion: { (returnUser2: User?, msg, code) in
                    }, failure: nil)
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ThridPartLoginDone"), object: self)
            }
        })
    }
    
    //取消全部平台授权
    @IBAction func close(_ sender: UIButton) {
        ShareSDK.hasAuthorized(SSDKPlatformType.typeQQ)
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeQQ)
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeWechat)
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeSinaWeibo)
    }
    //获取当前已经授权用户
    @IBAction func searchInfo(_ sender: UIButton) {
        
        let qqUser = ShareSDK.currentUser(SSDKPlatformType.typeQQ)
        let weChatuser = ShareSDK.currentUser(SSDKPlatformType.typeWechat)
        let sinaChatuser = ShareSDK.currentUser(SSDKPlatformType.typeSinaWeibo)
        //防止 ! nil 引起崩溃
        if qqUser?.credential != nil && weChatuser?.credential != nil && sinaChatuser?.credential != nil {
            UIAlertView.init(title: "查询成功", message: "详细请看输出台", delegate: self, cancelButtonTitle: "好的").show()
            print("获取成功,qq用户信息为\(String(describing: (qqUser?.credential)!))")
            print("获取成功,微信用户信息为\(String(describing: (weChatuser?.credential)!))")
            print("获取成功,微博用户信息为\(String(describing: (sinaChatuser?.credential)!))")
        } else {
            UIAlertView.init(title: "查询失败", message: "错误:QQ微信微博至少有一个没登录", delegate: self, cancelButtonTitle: "再试一次").show()
        }
        //        //获取用户授权信息时,若授权,则查询,反之 ,将会跳转到授权页面
        //        ShareSDK.getUserInfo(SSDKPlatformType.typeQQ) { (state: SSDKResponseState, user: SSDKUser?, error: Error?)  ->
        //            Void in
        //            switch state{
        //            case SSDKResponseState.success: print("获取成功,用户信息为\(String(describing: user))\n ----- 获取凭证为\(String(describing: user?.credential))\n----- 验证平台为\(String(describing: user?.verifyType))")
        //            case SSDKResponseState.fail:    print("获取失败,错误描述:\(String(describing: error))")
        //            case SSDKResponseState.cancel:  onCancel()
        //            default: break
        //            }
        //        }
    }
}

