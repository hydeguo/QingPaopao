//
//  BindingThirdpartAccountVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/16.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Moya
import PKHUD

class BindingThirdpartAccountVC: UITableViewController  {
    
    
    @IBOutlet var btn_sina:UIButton!
    @IBOutlet var btn_QQ:UIButton!
    @IBOutlet var btn_wechat:UIButton!
    
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Wolf.requestList(type: MyAPI.getThirdBinding(), completion: { (info: [ThirdpartLogin]?, msg, code) in
            if(code == "0")
            {
                for item in info!
                {
                    if item.thirdType == String(SSDKPlatformType.typeWechat.rawValue)
                    {
                        self.btn_wechat.setTitle("已授权", for: .normal)
                        self.btn_wechat.isEnabled = false
                    }
                    else if item.thirdType == String(SSDKPlatformType.typeQQ.rawValue)
                    {
                        self.btn_QQ.setTitle("已授权", for: .normal)
                        self.btn_QQ.isEnabled = false
                    }
                    else if item.thirdType == String(SSDKPlatformType.typeSinaWeibo.rawValue)
                    {
                        self.btn_sina.setTitle("已授权", for: .normal)
                        self.btn_sina.isEnabled = false
                    }
                }
                return
            }
        }, failure: nil)
        
        let _view = UIView()
        _view.backgroundColor = .clear
        self.tableView.tableFooterView = _view
    }
    
    
    func onCancel()
    {
        print("操作取消")
        HUD.hide()
    }
    
    @IBAction func onConmit(_ sander:UIButton)
    {
        var type = SSDKPlatformType.typeWechat
        if(sander == btn_sina){
            type = SSDKPlatformType.typeSinaWeibo
        }else if(sander == btn_QQ){
            type = SSDKPlatformType.typeQQ
        }
        HUD.show(.progress)
        //此方法无论是否授权过,都会进行授权
        ShareSDK.authorize(type, settings: nil, onStateChanged: { (state: SSDKResponseState, user: SSDKUser?, error: Error?) -> Void in
            switch state{
            case SSDKResponseState.success:
                //注册并登录
                if(user != nil)
                {
                    _ = Wolf.request(type: MyAPI.thirdBinding(key: user!.credential.uid, type: String(type.rawValue)), completion: { (info: BaseReponse?, msg, code) in
                        if(code == "0")
                        {
                            HUD.hide()
                            sander.setTitle("已授权", for: .normal)
                            return
                        }
                    }, failure: nil)
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
