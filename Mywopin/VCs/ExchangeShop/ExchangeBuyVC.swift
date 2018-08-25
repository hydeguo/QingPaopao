//
//  ExchangeBuyVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/7.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

class ExchangeBuyVC: UIViewController {
    
    
    static var selectedAddress:AddressItem?
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var original_priceLf:UILabel!
    @IBOutlet var exchange_priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var numEditer:BuyNumEditer!
    var oldGoods:WooGoodsItem?
    var goods:WooGoodsItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numEditer.onChange = onchange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        exchange_priceLf.text = (oldGoods?.price)! + Language.getString("元")
        original_priceLf.text = (goods?.price)! + Language.getString("元")
        priceLf.text = "\((Int(goods!.price)! * Int(numEditer.numLf.text!)! - Int(oldGoods!.price)!) )\(Language.getString("元"))"
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
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
        
        priceLf.text = "\((Int(goods!.price)! * Int(numEditer.numLf.text!)! - Int(oldGoods!.price)!) )\(Language.getString("元"))"
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
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
        {
            _ = Wolf.request(type: MyAPI.payMentExchange(addressId: _selectedAddress.addressId, title: goods?.name ?? "", image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: Int(numEditer.numLf.text!)!, offerPrice: Int(oldGoods!.price)!, singlePrice: Int(goods!.price)!), completion: { (info: BaseReponse?, msg, code) in
                if(code == "0" )
                {
                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success)
                }
            }, failure: nil)
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("请输入详细地址"), style: AlertStyle.warning)
        }
    }
}

class ExchangeNewBuyVC: UIViewController {
    
    static var selectedAddress:AddressItem?
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var numEditer:BuyNumEditer!
    var goods:WooGoodsItem?
    var parentView:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numEditer.onChange = onchange
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        priceLf.text = (goods?.price)! + Language.getString("元")
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
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
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
        {
            _ = Wolf.request(type: MyAPI.payMentExchange(addressId: _selectedAddress.addressId, title:  goods?.name ?? "",image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: Int(numEditer.numLf.text!)!, offerPrice: 0, singlePrice: Int(goods!.price)!), completion: { (info: BaseReponse?, msg, code) in
                if(code == "0" )
                {
                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success)
                }
            }, failure: nil)
        }
        else
        {
             _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("请输入详细地址"), style: AlertStyle.warning)
        }
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
