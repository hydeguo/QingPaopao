//
//  ExchangeList.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/22.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit

import PKHUD


class ExchangeList: UITableViewController {
    
    var goods:[WooGoodsItem] = []
    var cellHeight:CGFloat = 140
    

    override func viewWillAppear(_ animated: Bool) {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePostList()
    }
    
    func updatePostList() {
        
        HUD.show(.progress)
        _ = Wolf.requestBaseList(type: WooAPI.getExchangeGoods(), completion: { (goods: [WooGoodsItem]?, msg, code) in
            if(code == "0")
            {
                Log(goods?.count)
                if let goodsItems = goods
                {
                    self.goods = goodsItems
                    self.tableView.reloadData()
                }
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
            HUD.hide()
        }, failure: nil)
  
    
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let post = posts[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! InfoDetailViewController
//                controller.detailItem = post
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    //    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 130
    //    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goods.count
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OldExchangeCell", for: indexPath) as! OldExchangeCell
        let goods = self.goods[indexPath.row]
        cell.configure(goods: goods);
        cell.buyBtn.tag = indexPath.row
        cell.addFunc = showDetail
        
        return cell
    }
    
    override func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let goods = self.goods[indexPath.row]
//        let vc = R.storyboard.main.exchangeShopDetailVC()
//        vc?.data = goods
//        self.show(vc!, sender: nil)
       
        showDetail(sander:  (tableView.cellForRow(at: indexPath) as! OldExchangeCell).buyBtn)
        
    }
    
    func showDetail(sander:UIButton)
    {
//        if let indexPath = self.tableView.indexPathForSelectedRow {
//        }
        let goods = self.goods[sander.tag]
        let vc = R.storyboard.shop.exchangeBuyBtnVC()
        vc?.data = goods
        self.show(vc!, sender: nil)
    }
    
    
    
}


