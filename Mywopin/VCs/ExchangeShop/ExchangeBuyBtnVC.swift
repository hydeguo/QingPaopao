//
//  ExchangeShopPageVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/23.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit

class ExchangeBuyBtnVC: UIViewController {
    
    @IBOutlet var goodsDetail:UIView!
    @IBOutlet var btn:UIButton?
    var data : WooGoodsItem?
    var detailPage:ExchangeShopDetailVC!
    
    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let detailPage = childViewControllers.first as? ExchangeShopDetailVC else  {
            fatalError("Check storyboard for missing LocationTableViewController")
        }
        detailPage.data = data
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onActionEvent), name: NSNotification.Name(rawValue: "exchangeTimeOut"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.view.height = 100
//        self.view.isUserInteractionEnabled = false
    }
    
    @objc func onActionEvent(_ notice:Notification)
    {
        if ((notice as NSNotification).userInfo!["data"] as? Bool) == false
        {
            btn?.isEnabled = false
            btn?.backgroundColor = UIColor.lightGray
        }

    }
    
    @objc func onReturn()
    {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBuy()
    {
        guard let detailPage = childViewControllers.first as? ExchangeShopDetailVC else  {
            fatalError("Check storyboard for missing LocationTableViewController")
        }
//        if let exchagneGoods = detailPage.oldGoods
//        {
            let vc = R.storyboard.shop.exchangeBuyVC()
            vc?.modalPresentationStyle = .custom
            vc?.discountPrice = detailPage.discountPrice
            vc?.goods = detailPage.data
            vc?._parent = self
            self.present(vc!, animated: true, completion: { vc?.bgImage.backgroundColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.5)})
//        }
//        else
//        {
//
//            _ = SweetAlert().showAlert("Sorry", subTitle: Language.getString("请选择以旧换新的商品"), style: AlertStyle.warning)
//            let vc = R.storyboard.shop.exchangeNewBuyVC()
//            vc?.modalPresentationStyle = .custom
//            vc?.goods = detailPage.data
//            vc?.parentView = detailPage
//            self.present(vc!, animated: true, completion: { vc?.bgImage.backgroundColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.5)})
//        }
        
    }
}
