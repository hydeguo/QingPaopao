//
//  CrowdfoudingBuyBtnVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/26.
//  Copyright © 2018 Wopin. All rights reserved.
//
import Foundation
import UIKit

class CrowdfoudingBuyBtnVC: UIViewController {
    
    @IBOutlet var goodsDetail:UIView!
    @IBOutlet var btn:UIButton?
    var data : WooGoodsItem?
    var detailPage:ExchangeShopDetailVC!
    
    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let detailPage = childViewControllers.first as? CrowdfundingShopDetailVC else  {
            fatalError("Check storyboard for missing CrowdfundingShopDetailVC")
        }
        detailPage.data = data
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onActionEvent), name: NSNotification.Name(rawValue: "crowdfundingTimeOut"), object: nil)
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
        guard let detailPage = childViewControllers.first as? CrowdfundingShopDetailVC else  {
            fatalError("Check storyboard for missing CrowdfundingShopDetailVC")
        }
        let vc = R.storyboard.shop.crowfoudingBuyVC()
        vc?.modalPresentationStyle = .custom
        vc?.goods = detailPage.data
        self.present(vc!, animated: true, completion: { vc?.bgImage.backgroundColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.5)})
        
    }
}
