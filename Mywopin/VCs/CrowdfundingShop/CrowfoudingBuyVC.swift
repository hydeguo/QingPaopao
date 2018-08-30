//
//  CrowfoudingBuyVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/26.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


class CrowfoudingBuyVC: UIViewController {
    
    
    static var selectedAddress:AddressItem?
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var titleLf:UILabel!
    @IBOutlet var goodsImage:UIImageView!
    
    var goods:WooGoodsItem?
    
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
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
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
        if let _selectedAddress = ExchangeNewBuyVC.selectedAddress
        {
            _ = Wolf.request(type: MyAPI.payMentCrowdfunding(addressId: _selectedAddress.addressId, title: goods?.name ?? "", image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: 1, singlePrice: selectedPrice), completion: { (info: User?, msg, code) in
                if(code == "0" )
                {
                    myClientVo = info
                    _ = SweetAlert().showAlert(Language.getString("订单提交成功"), subTitle: "", style: AlertStyle.success,buttonTitle: "确定", action: { _ in
                        self.closeAction();
                    })
                }
                else
                {
                    _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
                }
            }, failure: nil)
        }
        else
        {
            _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("请输入详细地址"), style: AlertStyle.warning)
        }
    }
}