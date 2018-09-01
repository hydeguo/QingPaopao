//
//  OrderDetailVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/10.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ExchangeOrderDetailVC: UITableViewController {
    
    @IBOutlet var orderStatusLb:UILabel!
    @IBOutlet var orderStatusInfoLb:UILabel!
    @IBOutlet var orderNumLb:UILabel!
    @IBOutlet var orderTimeLb:UILabel!
    
    @IBOutlet var goodsImage:UIImageView!
    @IBOutlet var goodsName:UILabel!
    @IBOutlet var goodsPrice:UILabel!

    @IBOutlet var address1Line1:UILabel!
    @IBOutlet var address1Line2:UILabel!
    @IBOutlet var address2Line1:UILabel!
    @IBOutlet var address2Line2:UILabel!
    @IBOutlet var payment:UILabel!

    @IBOutlet var payBtn:UIButton!
    @IBOutlet var cancelBtn:UIButton!
    @IBOutlet var expressBtn:UIButton!
    
    var order:ExchangeOrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let orderData = order
        {
            
            let offerPrice = (orderData.offerPrice != nil) ? orderData.offerPrice! : 0
            let payPrice = orderData.singlePrice * orderData.num - offerPrice
            
            orderNumLb.text = "订单号：\(orderData.orderId)"
            orderTimeLb.text = "下单时间：\(orderData.createDate!)"
            orderStatusLb.text = orderData.orderStatus
            goodsImage.image(fromUrl: orderData.image ?? "")
            goodsName.text = orderData.title ?? ""
            goodsPrice.text = "￥\(payPrice)"
            
            address1Line1.text = "收件人：\(orderData.address!.userName) \(orderData.address!.tel!)"
            address1Line2.text = "\(orderData.address!.address1!)\(orderData.address!.address2!)"
            
            payBtn.isHidden =  orderData.orderStatus == "未付款"
            expressBtn.isHidden =  orderData.orderStatus != "未付款"
            
        }
    }
    
    @IBAction func payAction()
    {
//        PayManager.shared.doPayment(orderId: <#T##String#>, price: <#T##Int#>, channel: <#T##MPSChannel#>, item: <#T##WooGoodsItem#>)
    }
    
    @IBAction func expressInfoAction()
    {
        
    }
    
    @IBAction func cancelAction()
    {
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "showDetail" {
        //            if let indexPath = self.tableView.indexPathForSelectedRow {
        //                let post = posts[indexPath.row]
        //                let controller = (segue.destination as! UINavigationController).topViewController as! InfoDetailViewController
        //                controller.detailItem = post
        //                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        //                controller.navigationItem.leftItemsSupplementBackButton = true
        //            }
        //        }
    }
    
    
  
    
    
}
