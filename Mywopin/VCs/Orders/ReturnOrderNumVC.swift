//
//  ReturnOrderNumVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/9.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import IHKeyboardAvoiding
import PKHUD

class ReturnOrderNumVC: UITableViewController ,UITextFieldDelegate,PayRequestDelegate{

    @IBOutlet var deliveryOrder:UITextField!
    @IBOutlet var deliveryExpressName:UITextField!
    
    @IBOutlet var infoUserNameTF:UITextField!
    @IBOutlet var infoSexTF:UITextField!
    @IBOutlet var infoPhoneTF:UITextField!
    @IBOutlet var infoCupModelTF:UITextField!
    @IBOutlet var infoCupColorTF:UITextField!
    @IBOutlet var infoBuyTimeTF:UITextField!
    @IBOutlet var infoUsageTF:UITextField!
    
    @IBOutlet var buyBtn:UIButton?
    
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
        
        if order!.orderStatus != orderStatusArr[0]
        {
            buyBtn?.isEnabled = false
            buyBtn?.backgroundColor = UIColor.lightGray
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) -> Void {
        
        if(textField == infoUsageTF || textField == deliveryOrder || textField == deliveryExpressName){
            
            KeyboardAvoiding.avoidingView = self.tableView
        }else{
            if KeyboardAvoiding.isKeyboardVisible == false
            {
                KeyboardAvoiding.avoidingView = nil
            }
        }
        
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
        
        if deliveryOrder.text?.count == 0  ||
            deliveryExpressName.text?.count == 0 ||
            infoUserNameTF.text?.count == 0 ||
            infoSexTF.text?.count == 0 ||
            infoPhoneTF.text?.count == 0 ||
            infoCupModelTF.text?.count == 0 ||
            infoCupColorTF.text?.count == 0 ||
            infoBuyTimeTF.text?.count == 0 ||
            infoUsageTF.text?.count == 0
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: "请填写完整信息", style: AlertStyle.warning)
            return
        }
        
        
        HUD.show(.progress)
        
        _ = Wolf.request(type: MyAPI.exchangeOrderUpdate(orderId: order!.orderId, expressId: deliveryOrder.text!,expressName:deliveryExpressName.text!, infoUserName: infoUserNameTF.text!, infoSex: infoSexTF.text!, infoPhone: infoPhoneTF.text!, infoCupModel: infoCupModelTF.text!, infoCupColor: infoCupColorTF.text!, infoBuyTime: infoBuyTimeTF.text!, infoUsage: infoUsageTF.text!), completion: { (order: BaseReponse?, msg, code) in
            
            if(code == "0")
            {
                self.order?.expressReturnId = self.deliveryOrder.text!;
                self.order?.expressReturnName = self.deliveryExpressName.text!;
//                _ = SweetAlert().showAlert(Language.getString("保存成功"), subTitle: "", style: AlertStyle.success)
                self.payAction();
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
     func payAction()
    {
        if let orderData = order
        {
            
            
            let offerPrice = (orderData.offerPrice != nil) ? orderData.offerPrice! : 0
            let payPrice = orderData.singlePrice * orderData.num - offerPrice
            
            let address1Line = "\(orderData.address!.address1!)\(orderData.address!.address2!) \(orderData.address!.userName) \(orderData.address!.tel!) "
            
            PaySDK.instance.payDelegate = self
            PaySDK.instance.getWechatPaySign(totalAmount: payPrice * 100, subject: address1Line, payTitle: orderData.title! ,orderId:orderData.orderId)
            
            
        }
    }
    
    func wechatPaySign(data: WoPinWeChatPayRes) {
        PaySDK.instance.wechatPayRequest(resData: data)
    }
    
    func alipayPaySign(str: String) {
        PaySDK.instance.alipayPayRequest(sign: str)
    }
    
    func payRequestSuccess(data: Any) {
        Log("success")
        
        DispatchQueue.main.async {
            HUD.hide()
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.orderStatusUpdate(orderId: self.order!.orderId, status: 1), completion: { (order: BaseReponse?, msg, code) in
                HUD.hide()
                if(code == "0")
                {
                    self.order?.orderStatus = orderStatusArr[1]
                    _ = SweetAlert().showAlert(Language.getString("付款成功"), subTitle: "", style: AlertStyle.success)
                    self.buyBtn?.isEnabled = false
                    self.buyBtn?.backgroundColor = UIColor.lightGray
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
    
    func payRequestError(error: String) {
        print("pay error")
        HUD.hide()
        DispatchQueue.main.async {
            _ = SweetAlert().showAlert("付款未成功", subTitle: "请稍候重试", style: AlertStyle.warning)
        }
        
    }
}
