//
//  OrderListVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/8.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import PKHUD

class OrderListTopVC: UIViewController {
    
    static var selectIndex  = 1
    @IBOutlet var segmentedControl:UISegmentedControl!
    var tabelOrderListVC:OrderListVC!
    var crowdfundingOrder:CrowdfundingOrderItem?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OrderListVC,
            segue.identifier == "EmbedSegue" {
            self.tabelOrderListVC = vc
        }
    }
    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        tabelOrderListVC.changeType(index: segmentedControl.selectedSegmentIndex)
        OrderListTopVC.selectIndex = segmentedControl.selectedSegmentIndex
    }
    
    override func viewDidLoad() {
         segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabelOrderListVC.changeType(index: OrderListTopVC.selectIndex)
        segmentedControl.selectedSegmentIndex = OrderListTopVC.selectIndex
    }
    
}

class OrderListVC: UITableViewController,PayRequestDelegate {
    
        
    var exchangeList = [ExchangeOrderItem]()
    var scoresList = [ScoresOrderItem]()
    var crowdfundingList = [CrowdfundingOrderItem]()
    var cellHeight:CGFloat = 140
    var currentType :Int = -1
    
    var crowdfundingOrder:CrowdfundingOrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onShowExchangeDetail), name: NSNotification.Name(rawValue: "ShowExchangeDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onShowExchangeDeliver), name: NSNotification.Name(rawValue: "ShowExchangeDeliver"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentType = -1
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onShowExchangeDetail(_ notice:Notification){
        
        if  let order:ExchangeOrderItem=(notice as NSNotification).userInfo!["data"] as? ExchangeOrderItem
        {
            let vc = R.storyboard.main.exchangeOrderDetailVC()
            vc?.order = order
            self.show(vc!, sender: nil)
        }
    }
    @objc func onShowExchangeDeliver(_ notice:Notification){
        
        if  let order:ExchangeOrderItem=(notice as NSNotification).userInfo!["data"] as? ExchangeOrderItem
        {
            
            let vc = R.storyboard.main.returnOrderNumVC()
            vc?.order = order
            self.show(vc!, sender: nil)
        }
    }
    
    func refreshExchangeOrder()
    {
        _ = Wolf.requestList(type: MyAPI.getExchangeOrder, completion: { (orders: [ExchangeOrderItem]?, msg, code) in
            
            if(code == "0")
            {
                self.exchangeList = orders!
                
                self.tableView.reloadData()
                
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    func refreshCrowdfundingOrder()
    {
        _ = Wolf.requestList(type: MyAPI.getCrowdfundingOrder, completion: { (orders: [CrowdfundingOrderItem]?, msg, code) in
            
            if(code == "0")
            {
                self.crowdfundingList = orders!
                self.tableView.reloadData()
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    func refreshScoresOrder()
    {
        _ = Wolf.requestList(type: MyAPI.getScoresOrder, completion: { (orders: [ScoresOrderItem]?, msg, code) in
            
            if(code == "0")
            {
                self.scoresList = orders!
                self.tableView.reloadData()
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
    func changeType(index:Int)
    {
        if(currentType == index){
            return
        }
        currentType = index
        self.tableView.reloadData()
        
        if currentType == 0
        {
            refreshScoresOrder()
        }
        else  if currentType == 1
        {
            refreshExchangeOrder()
        }
        else
        {
            refreshCrowdfundingOrder()
        }
    }
    
    @IBAction func checkExpress(_ btn:UIButton)
    {
        
        if currentType == 0
        {
            let order = scoresList[btn.tag]
            DeliverPageViewController.url = URL(string:"http://m.kuaidi100.com/result.jsp?nu=\(order.expressSendId ?? "")")
        }
        else
        {
            let order = crowdfundingList[btn.tag]
            DeliverPageViewController.url = URL(string:"http://m.kuaidi100.com/result.jsp?nu=\(order.expressSendId ?? "")")
        }
        
        let vc = R.storyboard.main.deliverPageViewController()
        
        self.show(vc!, sender: nil)
    }
    
    @IBAction func crowdfundingOrderPayAction(_ btn:UIButton)
    {
        let order = crowdfundingList[btn.tag]
        crowdfundingOrder = order
        
        HUD.show(.progress)
        
        let payPrice = order.singlePrice
        
        let address1Line = "\(order.address!.address1!)\(order.address!.address2!) \(order.address!.userName) \(order.address!.tel!) "
        
        PaySDK.instance.payDelegate = self
        PaySDK.instance.getWechatPaySign(totalAmount: payPrice * 100, subject: address1Line, payTitle: order.title! ,orderId:order.orderId)
        
        
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
            if(self.crowdfundingOrder == nil){
                return
            }
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.orderStatusUpdate(orderId: self.crowdfundingOrder!.orderId, status: 1), completion: { (order: BaseReponse?, msg, code) in
                HUD.hide()
                if(code == "0")
                {
                    self.crowdfundingOrder?.orderStatus = orderStatusArr[1]
                    self.refreshCrowdfundingOrder()
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
    
    
    // MARK: - Table View
    //    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 130
    //    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            
            var orderId = ""
            if self.currentType == 0{
                let order = self.scoresList[indexPath.row]
                orderId = order.orderId
                self.scoresList.remove(at: indexPath.row);
            }
            else if self.currentType == 1{
                let order = self.exchangeList[indexPath.row]
                orderId = order.orderId
                self.exchangeList.remove(at: indexPath.row);
            }
            else
            {
                let order = self.crowdfundingList[indexPath.row]
                orderId = order.orderId
                self.crowdfundingList.remove(at: indexPath.row);
            }
            
            _ = Wolf.request(type: MyAPI.deleteOrder(orderId: orderId), completion: { (posts: BaseReponse?, msg, code) in
                
                self.tableView.reloadData()
            }, failure: nil)
        }
        var orderStatus = ""
        if currentType == 0{
            let order = scoresList[indexPath.row]
            orderStatus = order.orderStatus ?? ""
        }
        else if currentType == 1{
            let order = exchangeList[indexPath.row]
            orderStatus = order.orderStatus ?? ""
        }
        else{
            let order = crowdfundingList[indexPath.row]
            orderStatus = order.orderStatus ?? ""
        }
        if orderStatus == orderStatusArr[0]{
            return [delete]
        }else{
            return []
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentType == 0 {
            return self.scoresList.count
        }else if currentType == 1 {
            return self.exchangeList.count
        }else  {
            return self.crowdfundingList.count
        }
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if currentType == 1{
            return 170
        }
        
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentType == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreditsOrderCell", for: indexPath) as! CreditsOrderCell
            let order = scoresList[indexPath.row]
            cell.configure(order: order)
            cell.deliverBtn?.tag = indexPath.row
            
            return cell
        }
        else if currentType == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeOrderCell", for: indexPath) as! ExchangeOrderCell
            let order = exchangeList[indexPath.row]
            cell.configure(order: order)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CrowdfundingOrderCell", for: indexPath) as! CrowdfundingOrderCell
            let order = crowdfundingList[indexPath.row]
            cell.configure(order: order)
            cell.paymentBtn.tag = indexPath.row
            cell.deliverBtn.tag = indexPath.row
            
            return cell
        }
        
    }
    
}
