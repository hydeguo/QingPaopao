//
//  ChangePassword.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/24.
//  Copyright © 2018 Hydeguo. All rights reserved.
//


import Foundation
import UIKit
import Moya
import RxSwift

class ChangePassword: UIViewController  , UITextFieldDelegate{
    
    
    @IBOutlet var userIDTF:UITextField!
    @IBOutlet var passwordTF:UITextField!
    @IBOutlet var passwordTF2:UITextField!
    @IBOutlet var verifyTF:UITextField!
    @IBOutlet var submitBtn:UIButton!
    @IBOutlet var verifyBtn:UIButton!
    @IBOutlet var verifyBtnLabel:UILabel!
    
    var 👜 = DisposeBag()
    var verifyBtnFlag = Variable(true)
    var timerCount =  Variable(0)
    
    
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let phone = myClientVo?.phone
        {
            userIDTF.text = String(Int(phone))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIDTF.delegate = self
        verifyTF.delegate = self
        passwordTF.delegate = self
        passwordTF2.delegate = self
        //        submitBtn.layer.cornerRadius = 5
//        submitBtn.layer.borderWidth = 1
//        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        
        verifyBtnFlag.asObservable().bind(to: self.verifyBtn.rx_visible ).disposed(by: 👜)
        verifyBtnFlag.asObservable().bind(to: self.verifyBtnLabel.rx.isHidden ).disposed(by: 👜)
        
        Observable<Int>.interval(1, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribe { [unowned self] event in
                self.timerCount.value -= 1
                if(self.timerCount.value <= 0){
                    self.verifyBtnFlag.value = true
                }else{
                    self.verifyBtnFlag.value = false
                    DispatchQueue.main.async {
                        self.verifyBtnLabel.text = "\(self.timerCount.value)秒后重发"
                    }
                }
            }.disposed(by: 👜)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func onConmit()
    {
        if let phoneNum = userIDTF.text,let psw = passwordTF.text,let psw2 = passwordTF2.text,let v_code = verifyTF.text
        {
            guard (isPhoneNumber(phoneNumber: phoneNum))else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
                return
            }
            guard psw.count>0 else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入密码!", style: AlertStyle.error)
                return
            }
            guard psw == psw2 else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "输入密码不一致!", style: AlertStyle.error)
                return
            }
            guard v_code.count>0 else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入验证码!", style: AlertStyle.error)
                return
            }
            
            changePassword(userID: phoneNum, password: psw, v_code: v_code) { (flag) in
                if flag == true
                {
                    _ = SweetAlert().showAlert("修改成功", subTitle: "", style: AlertStyle.success)
                    
//                    if UserDefaults.standard.dictionary(forKey: "userInformation") == nil {
//                        login(phone: phoneNum, psw: psw, platform: 0) { (user) in
//                            if user != nil
//                            {
//                                myClientVo = user
//                                let vc = R.storyboard.main.mainPage()
//                                self.present(vc!, animated: false, completion: nil)
//                            }
//                        }
//                    }
                }
            }
        }
    }

    @IBAction func sendVerify()
    {
        if let phoneNum = userIDTF.text
        {
            guard (isPhoneNumber(phoneNumber: phoneNum))else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
                return
            }
            getCode(phone: phoneNum) { (flag) in
                if(flag){
                    self.timerCount.value = 60
                }
            }
            
        }
    }
}


