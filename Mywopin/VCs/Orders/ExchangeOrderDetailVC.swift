//
//  OrderDetailVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/10.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import PKHUD



class ExchangeOrderDetailVC: UITableViewController ,PayRequestDelegate{
    
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
       initLayout()
    }
    
    func initLayout()
    {
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
            
            payBtn.isHidden =  orderData.orderStatus != orderStatusArr[0]
            expressBtn.isHidden =  orderData.orderStatus != orderStatusArr[2]
            
            
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
        
        DispatchQueue.main.async {
            HUD.hide()
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.orderStatusUpdate(orderId: self.order!.orderId, status: 1), completion: { (order: BaseReponse?, msg, code) in
                HUD.hide()
                if(code == "0")
                {
                    self.order?.orderStatus = orderStatusArr[1]
                    self.initLayout()
                    _ = SweetAlert().showAlert(Language.getString("付款成功"), subTitle: "", style: AlertStyle.success)
                }
                else
                {
                    _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
                }
            }) { (error) in
                _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
            }
        }
    }
    
    func payRequestError(error: String) {
        print("pay error")
        HUD.hide()
        DispatchQueue.main.async {
            _ = SweetAlert().showAlert("付款未成功", subTitle: "请稍候重试", style: AlertStyle.warning)
        }
        
    }
    
  
    @IBAction func payAction()
    {
        if let orderData = order
        {
            
            HUD.show(.progress)
            
            let offerPrice = (orderData.offerPrice != nil) ? orderData.offerPrice! : 0
            let payPrice = orderData.singlePrice * orderData.num - offerPrice
            
            let address1Line = "\(orderData.address!.address1!)\(orderData.address!.address2!) \(orderData.address!.userName) \(orderData.address!.tel!) "
            
            PaySDK.instance.payDelegate = self
            PaySDK.instance.getWechatPaySign(totalAmount: payPrice * 100, subject: address1Line, payTitle: orderData.title! ,orderId:orderData.orderId)
            
            
        }
    }
    
    @IBAction func expressInfoAction()
    {
        if let orderData = order
        {
            DeliverPageViewController.url = URL(string:"http://m.kuaidi100.com/result.jsp?nu=\(orderData.expressSendId ?? "")")
            let vc = R.storyboard.main.deliverPageViewController()
            
            self.show(vc!, sender: nil)
        }
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
