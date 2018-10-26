//
//  ChangePhoneVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/13.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import Moya
import RxSwift

class ChangePhoneVC: UIViewController  , UITextFieldDelegate{
    
    
    @IBOutlet var phoneTF:UITextField!
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
            phoneTF.text = String(Int(phone))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTF.delegate = self
        verifyTF.delegate = self
        
        
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
        if let phoneNum = phoneTF.text,let v_code = verifyTF.text
        {
            UIApplication.shared.keyWindow?.endEditing(true)
            guard (isPhoneNumber(phoneNumber: phoneNum))else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
                return
            }
            guard (phoneNum != String(myClientVo?.phone ?? 0 ) )else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "新手机号码与当前号码相同!", style: AlertStyle.warning)
                return
            }
           
            guard v_code.count>0 else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入验证码!", style: AlertStyle.error)
                return
            }
            
            _ = Wolf.request(type: MyAPI.changePhone(phone: phoneNum, v_code: v_code), completion: { (user: User?, msg, code) in
                
                if(code == "0")
                {
                    myClientVo = user
                    _ = SweetAlert().showAlert(Language.getString("绑定成功"), subTitle: "", style: AlertStyle.success)
                }
                else
                {
                    _ = SweetAlert().showAlert(Language.getString("绑定失败"), subTitle: msg, style: AlertStyle.warning)
                }
            }, failure: nil)
        }
    }
    
    @IBAction func sendVerify()
    {
        if let phoneNum = phoneTF.text
        {
            guard (isPhoneNumber(phoneNumber: phoneNum))else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
                return
            }
            guard (phoneNum != String(myClientVo?.phone ?? 0 ) )else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "新手机号码与当前号码相同!", style: AlertStyle.warning)
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


