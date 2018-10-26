//
//  ChangeBaseInfo.swift
//  Mywopin
//
//  Created by GuoXiaobin on 26/6/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation





class ChangeBaseInfo: UITableViewController,UITextFieldDelegate {
    
    var key1 = ""
    var key2 = ""
    var key3 = ""
    @IBOutlet var valueTf1:UITextField?
    @IBOutlet var valueTf2:UITextField?
    @IBOutlet var valueTf3:UITextField?

    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueTf1?.delegate = self
        valueTf2?.delegate = self
        valueTf3?.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        
        let rightBtn = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(save(_:)))
    
        navigationItem.rightBarButtonItem = rightBtn
        
    }
    
    @objc func save(_ sender: Any) {

        let  value_1  =  Double(valueTf1?.text ?? "0" )
        let  value_2  =  Double(valueTf2?.text ?? "0" )
        let  value_3  =  Double(valueTf3?.text ?? "0" )
        
        _ = Wolf.request(type: MyAPI.updateBodyProfiles(key: [key1,key2,key3], value: [value_1,value_2,value_3]), completion: { (user: User?, msg, code) in
            UIApplication.shared.keyWindow?.endEditing(true)
            if(code == "0")
            {
                myClientVo = user
                _ = SweetAlert().showAlert(Language.getString("保存成功"), subTitle: "", style: AlertStyle.success)
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("保存失败"), style: AlertStyle.warning)
            }
        }, failure: nil)
    }
    
}


class UpdateHeight: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "height"
        if let value = myClientVo?.profiles?.height
        {
            valueTf1?.text = "\(value)"
        }
    }
}

class UpdateWeight: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "weight"
        if let value = myClientVo?.profiles?.weight
        {
            valueTf1?.text = "\(value)"
        }
    }

}
class UpdateAge: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "age"
        if let value = myClientVo?.profiles?.age
        {
            valueTf1?.text = String( Int(value))
        }
    }
    
}
class UpdateBlood_sugar: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "blood_sugar_full"
        key2 = "blood_sugar_hugry"
        if let value = myClientVo?.profiles?.blood_sugar_full
        {
            valueTf1?.text = String( value)
        }
        if let value = myClientVo?.profiles?.blood_sugar_hugry
        {
            valueTf2?.text = String( value)
        }
    }
    
}
class UpdateBlood_lipid: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "blood_lipid_all"
        key2 = "blood_lipid"
        key3 = "blood_lipid_TG"
        if let value = myClientVo?.profiles?.blood_lipid_all
        {
            valueTf1?.text = String( value)
        }
        if let value = myClientVo?.profiles?.blood_lipid
        {
            valueTf2?.text = String( value)
        }
        if let value = myClientVo?.profiles?.blood_lipid_TG
        {
            valueTf3?.text = String( value)
        }
    }
    
}
class UpdateBlood_pressure: ChangeBaseInfo {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        key1 = "blood_pressure"
        key2 = "blood_pressure_press"
        if let value = myClientVo?.profiles?.blood_pressure
        {
            valueTf1?.text = String( value)
        }
        if let value = myClientVo?.profiles?.blood_pressure_press
        {
            valueTf2?.text = String( value)
        }
    }
    
}

