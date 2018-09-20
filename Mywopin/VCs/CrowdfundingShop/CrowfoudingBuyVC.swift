//
//  CrowfoudingBuyVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/26.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import PKHUD


class CrowfoudingBuyVC: UIViewController,PayRequestDelegate {
    
    
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var titleLf:UILabel!
    @IBOutlet var goodsImage:UIImageView!
    
    var goods:WooGoodsItem?
    var order:CrowdfundingOrderItem?
    
    var selectedOptionIndex:Int = 0
    var selectedPrice:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if goods != nil && goods!.attributes.count > selectedOptionIndex
        {
            var option = goods!.attributes[selectedOptionIndex];
            selectedPrice = Int(option.name)!
            priceLf.text = "¥"+option.name
            titleLf.text = option.options[0]
            goodsImage.image(fromUrl: goods!.images.first!.src)
        }
        if let _selectedAddress = selectedAddress ?? getDefaultAddress()
        {
            
            addressLf.text = "\(_selectedAddress.userName)\(" ")\(String(Int(_selectedAddress.tel!)))\("\n")\(_selectedAddress.address1!)\(_selectedAddress.address2!)"
        }
        else
        {
            addressLf.text = Language.getString("请选择您的收货地址")
        }
    }
    
    
    @IBAction func changeAddress()
    {
        
        let vc = R.storyboard.main.addressListVC()
        //        self.show(vc!, sender: nil)
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    @IBAction func closeAction()
    {
        self.dismiss(animated: true, completion: nil)
        bgImage.backgroundColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0)
    }
    
    @IBAction func buyAction()
    {
        if let _selectedAddress = selectedAddress ?? getDefaultAddress()
        {
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.payMentCrowdfunding(addressId: _selectedAddress.addressId, title: titleLf.text!.count > 0 ? titleLf.text! : goods!.name, image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: 1, singlePrice: selectedPrice), completion: { (order: CrowdfundingOrderItem?, msg, code) in
                if(code == "0" ){
                    if let myOrder = order
                    {
                        
                        self.order = myOrder
                        let payPrice = self.selectedPrice
                        let address1Line = self.addressLf.text
                        
                        PaySDK.instance.payDelegate = self
                        PaySDK.instance.getWechatPaySign(totalAmount: (payPrice * 100), subject: address1Line!, payTitle: self.titleLf.text!,orderId:myOrder.orderId)
                    }
                }
//                if(code == "0" )
//                {
//                    myClientVo = info
//                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
//                        self.closeAction();
//                    })
//                }
//                else
//                {
//                    _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
//                }
            }, failure: nil)
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("请输入详细地址"), style: AlertStyle.warning)
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
         HUD.hide()
        HUD.show(.progress)
        _ = Wolf.request(type: MyAPI.orderStatusUpdate(orderId: order!.orderId, status: 1), completion: { (order: BaseReponse?, msg, code) in
            HUD.hide()
            if(code == "0")
            {
                _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
                    self.closeAction();
                })
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
    func payRequestError(error: String) {
        print("pay error")
        HUD.hide()
        _ = SweetAlert().showAlert("付款未成功", subTitle: "可以到我的订单继续完成付款", style: AlertStyle.warning)
    }
}
