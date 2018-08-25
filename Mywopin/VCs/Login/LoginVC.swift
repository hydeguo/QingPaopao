//
//  LoginVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/17.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


import UIKit
import Moya


class LoginVC: UIViewController , UITextFieldDelegate{
    
    
    @IBOutlet var userIDTF:UITextField!
    @IBOutlet var passwordTF:UITextField!
    @IBOutlet var submitBtn:UIButton!
    
    //MARK: Push to relevant ViewController
    func pushTo(viewController: ViewControllerType)  {
        switch viewController {
        case .conversations:
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
            //            self.present(vc, animated: false, completion: nil)
            break
        case .welcome:
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeVC
//            self.present(vc, animated: false, completion: nil)
            break
        }
    }
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoMainScene), name: NSNotification.Name(rawValue: "ThridPartLoginDone"), object: nil)
        
        if let phone = myClientVo?.phone
        {
            userIDTF.text = String(Int(phone))
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIDTF.delegate = self
        passwordTF.delegate = self
//        submitBtn.layer.cornerRadius = 5
//        submitBtn.layer.borderWidth = 1
//        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//
//    }
    @IBAction func onReturn()
    {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func gotoMainScene()
    {
        let vc = R.storyboard.main.mainPage()
        self.present(vc!, animated: false, completion: nil)
    }
    
    @IBAction func onConmit()
    {
        if let phoneNum = userIDTF.text,let psw = passwordTF.text
        {
            guard (isPhoneNumber(phoneNumber: phoneNum))else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
                return
            }
            guard psw.count>0 else {
                _ = SweetAlert().showAlert("Sorry", subTitle: "请输入密码!", style: AlertStyle.error)
                return
            }
            login(phone: phoneNum, psw: psw, platform: 0) { (user) in
                if user != nil
                {
                    self.gotoMainScene()
                }
            }
        }
    }
}


