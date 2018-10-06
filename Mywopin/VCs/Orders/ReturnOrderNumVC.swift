//
//  ReturnOrderNumVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/9.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

class ReturnOrderNumVC: UITableViewController ,UITextFieldDelegate{

    @IBOutlet var deliveryOrder:UITextField!
    @IBOutlet var deliveryExpressName:UITextField!
    
    @IBOutlet var infoUserNameTF:UITextField!
    @IBOutlet var infoSexTF:UITextField!
    @IBOutlet var infoPhoneTF:UITextField!
    @IBOutlet var infoCupModelTF:UITextField!
    @IBOutlet var infoCupColorTF:UITextField!
    @IBOutlet var infoBuyTimeTF:UITextField!
    @IBOutlet var infoUsageTF:UITextField!
    
    
    var order:ExchangeOrderItem?
    
    override func viewWillAppear(_ animated: Bool) {
        if(order == nil){
            return
        }
        deliveryOrder.text = order?.expressReturnId
        deliveryExpressName.text = order?.expressReturnName ?? ""
        
        infoUserNameTF.text = order?.infoUserName ?? ""
        infoSexTF.text = order?.infoSex ?? ""
        infoPhoneTF.text = order?.infoPhone ?? ""
        infoCupModelTF.text = order?.infoCupModel ?? ""
        infoCupColorTF.text = order?.infoCupColor ?? ""
        infoBuyTimeTF.text = order?.infoBuyTime ?? ""
        infoUsageTF.text = order?.infoUsage ?? ""
        
        
        deliveryOrder.delegate = self
        deliveryExpressName.delegate = self
        infoUserNameTF.delegate = self
        infoSexTF.delegate = self
        infoPhoneTF.delegate = self
        infoCupModelTF.delegate = self
        infoCupColorTF.delegate = self
        infoBuyTimeTF.delegate = self
        infoUsageTF.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func onCommit()
    {
        if(order == nil){
            return
        }
        _ = Wolf.request(type: MyAPI.exchangeOrderUpdate(orderId: order!.orderId, expressId: deliveryOrder.text!,expressName:deliveryExpressName.text!, infoUserName: infoUserNameTF.text!, infoSex: infoSexTF.text!, infoPhone: infoPhoneTF.text!, infoCupModel: infoCupModelTF.text!, infoCupColor: infoCupColorTF.text!, infoBuyTime: infoBuyTimeTF.text!, infoUsage: infoUsageTF.text!), completion: { (order: BaseReponse?, msg, code) in
            
            if(code == "0")
            {
                self.order?.expressReturnId = self.deliveryOrder.text!;
                self.order?.expressReturnName = self.deliveryExpressName.text!;
                _ = SweetAlert().showAlert(Language.getString("保存成功"), subTitle: "", style: AlertStyle.success)
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
}
