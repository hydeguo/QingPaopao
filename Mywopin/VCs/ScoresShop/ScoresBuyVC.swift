//
//  ScoresBuyVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/19.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


class ScoresBuyVC: UIViewController {
    
    @IBOutlet var bgImage:UIImageView!
    @IBOutlet var priceLf:UILabel!
    @IBOutlet var original_priceLf:UILabel!
    @IBOutlet var addressLf:UILabel!
    @IBOutlet var numEditer:BuyNumEditer!
  
    var goods:WooGoodsItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numEditer.onChange = onchange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let myScores = myClientVo?.scores != nil ? Int(myClientVo!.scores!) : 0
        original_priceLf.text = "\(myScores) \(Language.getString("积分"))"
        priceLf.text = "\((Int(goods!.price)! * Int(numEditer.numLf.text!)!) )\(Language.getString("积分"))"
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
        
        priceLf.text = "\((Int(goods!.price)! * Int(numEditer.numLf.text!)! ) )\(Language.getString("积分"))"
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
            _ = Wolf.request(type: MyAPI.payMentScores(addressId: _selectedAddress.addressId, title: goods?.name ?? "", image: goods?.images.first?.src ?? "", goodsId: goods!.id, num: Int(numEditer.numLf.text!)!, singlePrice: Int(goods!.price)!), completion: { (info: User?, msg, code) in
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
