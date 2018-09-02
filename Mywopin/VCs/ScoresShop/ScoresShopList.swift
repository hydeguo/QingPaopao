//
//  ScoresShopList.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/19.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import Disk

class ScoresShopList:UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var items = [WooGoodsItem]()
    var loading:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        do {
            let retrievedMessage = try Disk.retrieve("ScoresShopList.json", from: .caches, as: [WooGoodsItem].self)
            items = retrievedMessage
        } catch _ as NSError {}
        
        loading  = items.count==0
        
        self.collectionView?.reloadData()
        refreahList()
    }
    
    @objc func refreahList()
    {
        _ = Wolf.requestBaseList(type: WooAPI.getScoresGoods(), completion: { (goods: [WooGoodsItem]?, msg, code) in
            if(code == "0")
            {
                Log(goods?.count)
                self.loading  = false
                if let goodsItems = goods
                {
                    self.items = goodsItems
                    do {
                        try Disk.save(self.items, to: .caches, as: "ScoresShopList.json")
                    } catch _ as NSError {}
                    self.collectionView?.reloadData()
                }
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
        
    }
    
    

    deinit {
        
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return loading ? 4 : items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       
        let size_w = (SCREEN_WIDTH - 1)/2
        return CGSize(width: size_w, height: size_w * 1.1)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if loading == true{
            return collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as UICollectionViewCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScoresShopCell", for: indexPath) as! ScoresShopCell
        cell.configure(goods: items[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let goods = items[indexPath.row]
        let vc = R.storyboard.shop.scoresBuyBtnVC()
        vc?.data = goods
        self.show(vc!, sender: nil)
    }
    
    
    
}

