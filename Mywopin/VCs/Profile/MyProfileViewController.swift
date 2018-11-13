//
//  MyProfileViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/6.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit


class MyProfileViewController: AvatarViewController {
    
    static var checkNewMsg:CheckNewMsgData?
    @IBOutlet var newMsgLabel:UILabel?
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var scoreLabel:UILabel!
    @IBOutlet var topPofileImage:UIImageView!
    @IBOutlet var topView:UIView!
    @IBOutlet var drinkCupLabel:UILabel!
    @IBOutlet var drinkCupTotalLabeL:UILabel!
    @IBOutlet var attendanceBtn:UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        createGradientLayer(view: self.topView)
        
        if(MyProfileViewController.checkNewMsg == nil){

            _ = Wolf.request(type: MyAPI.checkNewMessage, completion: { (data: CheckNewMsgData?, msg, code) in
                if let _newMsg = data {
                   MyProfileViewController.checkNewMsg = _newMsg
                    self.updateMsgAlertUI()
                }
            }, failure: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        updateUI()
        
        updateDrinkText()
        
        updateMsgAlertUI()
    }
    
    func updateMsgAlertUI(){
        if let newMsgData =  MyProfileViewController.checkNewMsg{
            newMsgLabel?.text = String(newMsgData.count)
            newMsgLabel?.isHidden = newMsgData.count == 0
        }else{
            newMsgLabel?.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "history"{
            let controller = segue.destination as! PostListViewController
            controller.mode = .history
        }
        if segue.identifier == "collectionPosts"{
            let controller = segue.destination  as! PostListViewController
            controller.mode = .collect
        }
        if segue.identifier == "followingPosts"{
            let controller = segue.destination  as! PostListViewController
            controller.mode = .following
        }
        
    }
    
    func updateUI(){
        let name = myClientVo?.userName ?? String(stringInterpolationSegment: myClientVo?.phone)
        nameLabel.text = name
        let myScores = myClientVo?.scores != nil ? Int(myClientVo!.scores!) : 0
        scoreLabel.text = "\(myScores) 积分"
        
        if(self.getDayString(day:Date()) == myClientVo?.lastAttendance)
        {
            attendanceBtn.isEnabled = false
            attendanceBtn.setTitle("已签到", for: .normal)
        }
        if let myIcon = myClientVo?.icon
        {
            topPofileImage.image(fromUrl: myIcon)
        }
    }
    func getDayString(day:Date)->String
    {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyyMMdd";
        return dateFormatter.string(from: day);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        
        
        drinkCupLabel.layer.cornerRadius = drinkCupLabel.height/2;
        drinkCupLabel.layer.masksToBounds = true;
        drinkCupLabel.layer.borderColor = UIColor.white.cgColor
        drinkCupLabel.layer.borderWidth = 1;//边框宽度
        drinkCupTotalLabeL.layer.cornerRadius = drinkCupTotalLabeL.height/2;
        drinkCupTotalLabeL.layer.masksToBounds = true;
        drinkCupTotalLabeL.layer.borderColor = UIColor.white.cgColor
        drinkCupTotalLabeL.layer.borderWidth = 1;//边框宽度
    }
    
    @IBAction func clickAvatar()
    {
        changePic()
    }
    
    
    func updateDrinkText()
    {
        if let _todayDrinks = todayDrinks
        {
            self.drinkCupLabel.text = String(_todayDrinks.drinks!.count) + Language.getString("杯")
        }
        self.drinkCupTotalLabeL.text = String(Int(myClientVo?.drinks ?? 0)) + Language.getString("杯")
    }
    
    @IBAction func attendance()
    {
        _ = Wolf.request(type: MyAPI.attendance, completion: { (user: User?, msg, code) in
            
            if(code == "0")
            {
                myClientVo = user
                _ = SweetAlert().showAlert("", subTitle: Language.getString("签到成功"), style: AlertStyle.success)
                self.updateUI()
            }
        }) { (error) in
        }
    }
    
    
    @IBAction func shareApp()
    {
        let shareParams: NSMutableDictionary = NSMutableDictionary()
        shareParams.ssdkSetupShareParams(byText: "一杯好水改变生活轨迹", images: "https://is3-ssl.mzstatic.com/image/thumb/Purple118/v4/f4/1c/64/f41c64d3-21e4-6e66-26d4-9b48872fd3c9/AppIcon-1x_U007emarketing-85-220-3.png/230x0w.jpg", url: URL.init(string: "http://wifi.h2popo.com:8081/downloadApp"), title: "邀请您一起", type: SSDKContentType.auto)
        
        ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParams) { (state, type, info, entity, error, end) in

            if state == SSDKResponseState.success {
                print("分享成功")
            } else {
                print("分享失败")
            }
        }
        
//        ShareSDK.share(.typeQQ, parameters: shareParams) { (state, info, entity, error) in
//            Log(error)
//             Log(state)
//            if state == SSDKResponseState.success {
//                                print("分享成功")
//                            } else {
//                                print("分享失败")
//                            }
//        }
        
    }
    
   
}
