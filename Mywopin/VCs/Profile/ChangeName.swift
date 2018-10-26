//
//  ChangeName.swift
//  Mywopin
//
//  Created by GuoXiaobin on 26/6/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ChangeName: UITableViewController ,UITextFieldDelegate{
    
    @IBOutlet var nameTf:UITextField!
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTf.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        
        let rightBtn = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(save(_:)))
        navigationItem.rightBarButtonItem = rightBtn
        
    }
    
    @objc func save(_ sender: Any) {
        
        if (nameTf.text?.count == 0){
            _ = SweetAlert().showAlert(Language.getString("名字不能为空"), subTitle: "", style: AlertStyle.success)
            return
        }
        
        _ = Wolf.request(type: MyAPI.changeUserName( userName: nameTf.text!), completion: { (user: User?, msg, code) in
            UIApplication.shared.keyWindow?.endEditing(true)
            if(code == "0")
            {
                myClientVo?.userName = self.nameTf.text!
                _ = SweetAlert().showAlert(Language.getString("保存成功"), subTitle: "", style: AlertStyle.success)
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("保存失败"), style: AlertStyle.warning)
            }
        }, failure: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

