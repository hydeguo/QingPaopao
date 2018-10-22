
//  AppDelegate.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = main_color
        
        let attrs = [
            NSAttributedStringKey.foregroundColor:UIColor.colorFromRGB(0xFFFFFF),
            //            NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        // remove return button title
        let attributes = [NSAttributedStringKey.font:  UIFont(name: "Helvetica-Bold", size: 0.1)!, NSAttributedStringKey.foregroundColor: UIColor.clear]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
        
        
        Language.share.setLanguage("zh-Hans")
        
//        WordPressWebServices.sharedInstance.loginWP(id: "") { (flag, err) in
//            Log("WordPressWebServices login...\(flag)")
//        }
//        Language.share.setLanguage("en")
        
        PaySDK.wxAppid = "wxf42ec50449767feb"
        PaySDK.instance.signUrl = server_url+"/getWeChatPaySign"
        
        _ = WifiController.shared;  //init
        
        
        /**
         *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
         *  在将生成的AppKey传入到此方法中。我们Demo提供的appKey为内部测试使用，可能会修改配置信息，请不要使用。
         *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
         *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
         *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
         */
        
        ShareSDK.registerActivePlatforms( [], onImport: { (platform : SSDKPlatformType) in
            
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
        };
        ShareSDK.registerActivePlatforms(
            [
                SSDKPlatformType.typeSinaWeibo.rawValue,
//                SSDKPlatformType.typeTencentWeibo.rawValue,
//                SSDKPlatformType.typeDouBan.rawValue,
//                SSDKPlatformType.typeCopy.rawValue,
//                SSDKPlatformType.typeFacebook.rawValue,
//                SSDKPlatformType.typeTwitter.rawValue,
//                SSDKPlatformType.typeMail.rawValue,
//                SSDKPlatformType.typeSMS.rawValue,
                SSDKPlatformType.typeWechat.rawValue,
                SSDKPlatformType.typeQQ.rawValue,
//                SSDKPlatformType.typeRenren.rawValue,
//                SSDKPlatformType.typeKaixin.rawValue,
//                SSDKPlatformType.typeGooglePlus.rawValue,
//                SSDKPlatformType.typePocket.rawValue,
//                SSDKPlatformType.typeInstagram.rawValue,
//                SSDKPlatformType.typeTumblr.rawValue,
//                SSDKPlatformType.typeLinkedIn.rawValue,
//                SSDKPlatformType.typeWhatsApp.rawValue,
//                SSDKPlatformType.typeYouDaoNote.rawValue,
//                SSDKPlatformType.typeFlickr.rawValue,
//                SSDKPlatformType.typeLine.rawValue,
//                SSDKPlatformType.typeYinXiang.rawValue,
//                SSDKPlatformType.typeEvernote.rawValue
            ],
            // onImport 里的代码,需要连接社交平台SDK时触发
            onImport: {(platform : SSDKPlatformType) -> Void in
                switch platform
                {
                case SSDKPlatformType.typeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                case SSDKPlatformType.typeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                case SSDKPlatformType.typeQQ:
                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                default:
                    break
                }
        },
            onConfiguration: {(platform : SSDKPlatformType , appInfo : NSMutableDictionary?) -> Void in
                switch platform
                {
                case SSDKPlatformType.typeSinaWeibo:
                    //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                    appInfo?.ssdkSetupSinaWeibo(byAppKey: "1871771910",
                                                appSecret: "b255a1185ff2d6255b076db56a6823b3",
                                                redirectUri: "http://sns.whalecloud.com",
                                                authType: SSDKAuthTypeBoth)
                    
                case SSDKPlatformType.typeWechat:
                    //设置微信应用信息
                    appInfo?.ssdkSetupWeChat(byAppId: "wxf42ec50449767feb",
                                             appSecret: "7fd977698fed0ac469207abf358222a5")
                    
//                case SSDKPlatformType.typeTencentWeibo:
//                    //设置腾讯微博应用信息，其中authType设置为只用Web形式授权
//                    appInfo?.ssdkSetupTencentWeibo(byAppKey: "801307650",
//                                                   appSecret: "ae36f4ee3946e1cbb98d6965b0b2ff5c",
//                                                   redirectUri: "http://www.sharesdk.cn")
                    
                    
//                case SSDKPlatformType.typeFacebook:
//                    //设置Facebook应用信息，其中authType设置为只用SSO形式授权
//                    appInfo?.ssdkSetupFacebook(byApiKey: "107704292745179",
//                                               appSecret: "38053202e1a5fe26c80c753071f0b573",
//                                               displayName: "ShareSDK",
//                                               authType: SSDKAuthTypeBoth)
                    
//                case SSDKPlatformType.typeTwitter:
//                    //设置Twitter应用信息
//                    appInfo?.ssdkSetupTwitter(byConsumerKey: "LRBM0H75rWrU9gNHvlEAA2aOy",
//                                              consumerSecret: "gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G",
//                                              redirectUri: "http://mob.com")
                    
                case SSDKPlatformType.typeQQ:
                    //设置QQ应用信息
                    appInfo?.ssdkSetupQQ(byAppId: "1105931776",
                                         appKey: "c4dPgCZjcuf5dEPx",
                                         authType: SSDKAuthTypeWeb)
                    
                    
//                case SSDKPlatformType.typeDouBan:
//                    //设置豆瓣应用信息
//                    appInfo?.ssdkSetupDouBan(byApiKey: "02e2cbe5ca06de5908a863b15e149b0b",
//                                             secret: "9f1e7b4f71304f2f",
//                                             redirectUri: "http://www.sharesdk.cn")
                    
                    
//                case SSDKPlatformType.typeRenren:
//                    //设置人人网应用信息
//                    appInfo?.ssdkSetupRenRen(byAppId: "226427",
//                                             appKey: "fc5b8aed373c4c27a05b712acba0f8c3",
//                                             secretKey: "f29df781abdd4f49beca5a2194676ca4",
//                                             authType: SSDKAuthTypeBoth)
                    
//                case SSDKPlatformType.typeKaixin:
//                    //设置开心网应用信息
//                    appInfo?.ssdkSetupKaiXin(byApiKey: "358443394194887cee81ff5890870c7c",
//                                             secretKey: "da32179d859c016169f66d90b6db2a23",
//                                             redirectUri: "http://www.sharesdk.cn/")
//
//                case SSDKPlatformType.typePocket:
//                    //设置Pocket应用信息
//                    appInfo?.ssdkSetupPocket(byConsumerKey: "11496-de7c8c5eb25b2c9fcdc2b627",
//                                             redirectUri: "pocketapp1234",
//                                             authType: SSDKAuthTypeBoth)
//
//                case SSDKPlatformType.typeInstagram:
//                    //设置Instagram应用信息
//                    appInfo?.ssdkSetupInstagram(byClientID: "ff68e3216b4f4f989121aa1c2962d058",
//                                                clientSecret: "1b2e82f110264869b3505c3fe34e31a1",
//                                                redirectUri: "http://sharesdk.cn")
//
//                case SSDKPlatformType.typeLinkedIn:
//                    //设置LinkedIn应用信息
//                    appInfo?.ssdkSetupLinkedIn(byApiKey: "ejo5ibkye3vo",
//                                               secretKey: "cC7B2jpxITqPLZ5M",
//                                               redirectUrl: "http://sharesdk.cn")
//
//                case SSDKPlatformType.typeTumblr:
//                    //设置Tumblr应用信息
//                    appInfo?.ssdkSetupTumblr(byConsumerKey: "2QUXqO9fcgGdtGG1FcvML6ZunIQzAEL8xY6hIaxdJnDti2DYwM",
//                                             consumerSecret: "3Rt0sPFj7u2g39mEVB3IBpOzKnM3JnTtxX2bao2JKk4VV1gtNo",
//                                             callbackUrl: "http://sharesdk.cn")
//
//                case SSDKPlatformType.typeFlickr:
//                    //设置Flickr应用信息
//                    appInfo?.ssdkSetupFlickr(byApiKey: "33d833ee6b6fca49943363282dd313dd",
//                                             apiSecret: "3a2c5b42a8fbb8bb")
//
//                case SSDKPlatformType.typeYouDaoNote:
//                    //设置YouDaoNote应用信息
//                    appInfo?.ssdkSetupYouDaoNote(byConsumerKey: "dcde25dca105bcc36884ed4534dab940",
//                                                 consumerSecret: "d98217b4020e7f1874263795f44838fe",
//                                                 oauthCallback: "http://www.sharesdk.cn/")
                    
//                    //印象笔记分为国内版和国际版，注意区分平台
//                //设置印象笔记（中国版）应用信息
//                case SSDKPlatformType.typeYinXiang:
//                    appInfo?.ssdkSetupEvernote(byConsumerKey: "sharesdk-7807",
//                                               consumerSecret: "d05bf86993836004",
//                                               sandbox: true)
//
//                //设置印象笔记（国际版）应用信息
//                case SSDKPlatformType.typeEvernote:
//                    appInfo?.ssdkSetupEvernote(byConsumerKey: "sharesdk-7807",
//                                               consumerSecret: "d05bf86993836004",
//                                               sandbox: true)
                    
                default:
                    break
                }
        })
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return PaySDK.instance.handleOpenURL(url)
    }
}

