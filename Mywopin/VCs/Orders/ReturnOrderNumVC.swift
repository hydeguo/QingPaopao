//
//  ReturnOrderNumVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/9.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

class ReturnOrderNumVC: UITableViewController {

    @IBOutlet var deliveryOrder:UITextField!
    
    
    var order:ExchangeOrderItem?
    
    override func viewWillAppear(_ animated: Bool) {
        if(order == nil){
            return
        }
        deliveryOrder.text = order?.expressReturnId
    }
    
    @IBAction func onCommit()
    {
        if(order == nil){
            return
        }
        _ = Wolf.request(type: MyAPI.exchangeOrderUpdate(orderId: order!.orderId, expressId: deliveryOrder.text!), completion: { (order: BaseReponse?, msg, code) in
            
            if(code == "0")
            {
                self.order?.expressReturnId = self.deliveryOrder.text!;
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
