//
//  ScoresBuyBtnVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/19.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import UIKit

class ScoresBuyBtnVC: UIViewController {
    
    @IBOutlet var goodsDetail:UIView!
    var data : WooGoodsItem?
    var detailPage:ExchangeShopDetailVC!
    
    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let detailPage = childViewControllers.first as? ScoresShopDetailVC else  {
            fatalError("Check storyboard for missing ScoresShopDetailVC")
        }
        detailPage.data = data
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        self.view.height = 100
        //        self.view.isUserInteractionEnabled = false
    }
    
    @objc func onReturn()
    {
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBuy()
    {
        guard let detailPage = childViewControllers.first as? ScoresShopDetailVC else  {
            fatalError("Check storyboard for missing ScoresShopDetailVC")
        }
        let vc = R.storyboard.shop.scoresBuyVC()
        vc?.modalPresentationStyle = .custom
        vc?.goods = detailPage.data
        self.present(vc!, animated: true, completion: { vc?.bgImage.backgroundColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.5)})
        
    }
}
