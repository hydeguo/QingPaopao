//
//  ChangeDeviceNameVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/14.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ChangeDeviceNameVC: UIViewController,UITextFieldDelegate {
    
    
    var cupData : CupItem?
    //    @IBOutlet var iconLight:UILabel!
    @IBOutlet var nameLf:UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLf.delegate = self
    }
    
    func setData(cupData:CupItem)
    {
        self.cupData = cupData
    }
    
    
    @IBAction func clickCommitBtn()
    {
        guard cupData != nil else{
            return
        }
        guard (nameLf.text?.count)! > 0  else{
            return
        }
         self.cupData?.name = nameLf.text!
        _ = Wolf.request(type: MyAPI.addOrUpdateACup(type: cupData!.type!, uuid: cupData!.uuid!, name: nameLf.text!, add: false), completion: { (user: User?, msg, code) in
            if(code == "0")
            {
                myClientVo = user
                self.onReturn()
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.title = ""
        
        nameLf.text = cupData?.name
    }
    
    
    @IBAction func onReturn()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DeviceInfoChange"), object: self,userInfo:["data":cupData as Any])
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

