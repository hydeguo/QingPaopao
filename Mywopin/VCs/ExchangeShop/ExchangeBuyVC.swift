//
//  ExchangeBuyVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/7.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import PKHUD

class ExchangeBuyVC: UIViewController ,PayRequestDelegate{
    

    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var original_priceLf:UILabel!
    @IBOutlet var exchange_priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var numEditer:BuyNumEditer!
//    var oldGoods:WooGoodsItem?
    var discountPrice:String = ""
    var goods:WooGoodsItem?
    var order:ExchangeOrderItem?
    var _parent:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numEditer.onChange = onchange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let previousPrice = (goods?.price)! + Language.getString("元")
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: previousPrice, attributes: [:])
        attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:attributeString.length))
        
        let currentPrice : NSMutableAttributedString = NSMutableAttributedString(string: "")
        currentPrice.append(attributeString)
        original_priceLf.attributedText = currentPrice
        
        exchange_priceLf.text = discountPrice + Language.getString("元")
//        original_priceLf.text = (goods?.price)! + Language.getString("元")
        priceLf.text = "\((Int(goods!.price)! * Int(numEditer.numLf.text!)! - (Int(discountPrice) ?? 0)) )\(Language.getString("元"))"
        if let _selectedAddress = selectedAddress ?? getDefaultAddress()
        {
            
            addressLf.text = "\(_selectedAddress.userName)\(" ")\(String(Int(_selectedAddress.tel!)))\("\n")\(_selectedAddress.address1!)\(_selectedAddress.address2!)"
        }
        else
        {
            addressLf.text = Language.getString("请选择您的收货地址")
        }
    }
    
    func onchange()
    {
        
        priceLf.text = "\((Int(goods!.price)! - (Int(discountPrice) ?? 0) ) * Int(numEditer.numLf.text!)!  )\(Language.getString("元"))"
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
            _ = Wolf.request(type: MyAPI.payMentExchange(addressId: _selectedAddress.addressId, title: goods?.name ?? "", image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: Int(numEditer.numLf.text!)!, offerPrice: Int(discountPrice) ?? 0, singlePrice: Int(goods!.price)!), completion: { (order: ExchangeOrderItem?, msg, code) in
                
                HUD.hide()
                if(code == "0" ){
                    if let myOrder = order
                    {
                        if let stockNum = self.goods?.stock_quantity , stockNum > 0
                        {
                            self.goods?.stock_quantity = stockNum - 1
                        }
                        
                        self.order = myOrder
                        let payPrice = ((Int(self.goods!.price) ?? 0) - (Int(self.discountPrice) ?? 0 ))  * Int(self.numEditer.numLf.text!)!
                        let address1Line = self.addressLf.text
                        PaySDK.instance.payDelegate = self
                        PaySDK.instance.getWechatPaySign(totalAmount: payPrice * 100, subject: address1Line!, payTitle: self.goods!.name,orderId:myOrder.orderId)
  
                    }
                }
                
//                if(code == "0" )
//                {
//                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
//                        self.closeAction();
//                    })
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
          
                _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "请继续完成申请表", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
                    self.closeAction();
                    
                    let orderInfo = R.storyboard.main.returnOrderNumVC()!
                    orderInfo.order = self.order
                    self._parent?.show(orderInfo, sender: nil)

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

class ExchangeNewBuyVC: UIViewController ,PayRequestDelegate{
    
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var numEditer:BuyNumEditer!
    var goods:WooGoodsItem?
    var parentView:UIViewController?
    var order:ExchangeOrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numEditer.onChange = onchange
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        priceLf.text = (goods?.price)! + Language.getString("元")
        if let _selectedAddress = selectedAddress ?? getDefaultAddress()
        {
            
            addressLf.text = "\(_selectedAddress.userName)\(" ")\(String(Int(_selectedAddress.tel!)))\("\n")\(_selectedAddress.address1!)\(_selectedAddress.address2!)"
        }
        else
        {
            addressLf.text = Language.getString("请选择您的收货地址")
        }
    }
    
    func onchange()
    {
       
        priceLf.text = "\(Int(goods!.price)! * Int(numEditer.numLf.text!)! )\(Language.getString("元"))"
    }
    @IBAction func changeAddress()
    {
        let vc = R.storyboard.main.addressListVC()
//        parentView?.show(vc!, sender: nil)
        self.show(vc!, sender: nil)
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
            _ = Wolf.request(type: MyAPI.payMentExchange(addressId: _selectedAddress.addressId, title:  goods?.name ?? "",image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: Int(numEditer.numLf.text!)!, offerPrice: 0, singlePrice: Int(goods!.price)!), completion: { (order: ExchangeOrderItem?, msg, code) in
                
                if(code == "0" ){
                    if let myOrder = order
                    {
                        
                        self.order = myOrder
                        let payPrice = Int(self.goods!.price)! * Int(self.numEditer.numLf.text!)! 
                        let address1Line = self.addressLf.text
                        
                        PaySDK.instance.payDelegate = self
                        PaySDK.instance.getWechatPaySign(totalAmount: payPrice * 100, subject: address1Line!, payTitle: self.goods!.name,orderId:myOrder.orderId)
                    }
                }
//                if(code == "0" )
//                {
//                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
//                        self.closeAction();
//                    })
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





class BuyNumEditer:UIView{
    
    var onChange:(()->Void)?
    @IBOutlet var numLf:UILabel!
    
    @IBAction func addNum(){
        let num = Int(numLf.text!)
        numLf.text = String(num! + 1)
        onChange?()
    }
    
    @IBAction func decNum(){
        let num = Int(numLf.text!)
        let newNum = num! - 1 >= 0 ? num! - 1 : 0
        numLf.text = String(newNum)
        onChange?()
    }
    
    
}
