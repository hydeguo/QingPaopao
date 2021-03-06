//
//  Cells.swift
//  karaoke
//
//  Created by Hydeguo on 30/11/2017.
//  Copyright © 2017 Hydeguo. All rights reserved.
//

import Foundation
import UIKit




class BtnCell :UICollectionViewCell
{
    
    @IBOutlet var picImage:UIImageView?
    @IBOutlet var nameLable:UILabel?
}
class LiveCell :UICollectionViewCell
{
    
    @IBOutlet var picImage:UIImageView?
    @IBOutlet var thumbImage:UIImageView?
    @IBOutlet var nameLable:UILabel?
}

class ResCell :UITableViewCell
{
    @IBOutlet var picImage:UIImageView?
    @IBOutlet var nameLable:UILabel?
    @IBOutlet var stateLable:UILabel?
    @IBOutlet var detailLable:UILabel?
    @IBOutlet var editBtn:UIButton?
    @IBOutlet var magageBtn:UIButton?
}

class ProfileCell :UITableViewCell
{

    @IBOutlet var iconText:UILabel?
    @IBOutlet var name:UILabel?

//    var dataVo:UserDatarVo?
//    // MARK: Cell Configuration
//    func configurateTheCell(_ vo:UserDatarVo) {
//        dataVo = vo
//
//        self.imagePic?.image(fromUrl:  vo.largePicUrl!)
//        self.name?.text = vo.name
//    }
}



class DeviceCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var powerView: UIButton!
    
    var postIdentifier:Int = 0
    var imageRequestedForIdentifier:Int = 0
    var cupData:CupItem?
    
    func configureWithData (_ data:CupItem) {
        
        self.cupData = data
        self.titleLabel!.text = data.name//String(htmlEncodedString: title!)
        
        powerView.isSelected = false
        
        let colorIndex = data.color ?? 1
        self.featuredImageView!.image = UIImage(named: "cup\(colorIndex)");
        
       checkOnline()
        
    }
    
    func checkOnline()
    {
        #if targetEnvironment(simulator)
        #else
        if let data = cupData
        {
            if data.type == DeviceTypeBLE
            {
                let device = BLEController.shared.bleManager.getDeviceByUUID(data.uuid)
                if device?.state == .connected
                {
                    powerView.isSelected = true
                }
                
            }
            else
            {
                WifiController.shared.allOnlineWifiCup.forEach { (wifiCup) in
                    if(data.uuid == wifiCup.uuid){
                        powerView.isSelected = (Date().timeIntervalSince1970 - wifiCup.lastOnline < 20)
                    }
                }
            }
        }
        
        
        #endif
    }
    
}

class AddDeviceCell: UITableViewCell {
    
    @IBOutlet weak var addBtn: UIButton!
     var addFunc:(()->Void)?
    
    @IBAction func onClickAdd()
    {
        addFunc?()
    }
}


class OldExchangeCell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    var addFunc:((UIButton)->Void)?
    
    @IBAction func onClickAdd(_ btn:UIButton)
    {
        addFunc?(btn)
    }
    
    func configure(goods:WooGoodsItem) -> Void {
        if goods.images.count > 0
        {
//            Log(goods.images.first!.src)
            imagePic.image(fromUrl: goods.images.first!.src)
        }
        var _subTitle = goods.short_description
        titleLabel.text = goods.name
        subTitle.text = _subTitle.filterHTML()
        price.text = "¥"+goods.price
    }
}

class CrowdfundingCell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var persTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var per_Silder: UISlider!
    

    
    func configure(goods:WooGoodsItem) -> Void {
        if goods.images.count > 0
        {
            //            Log(goods.images.first!.src)
            imagePic.image(fromUrl: goods.images.first!.src)
        }
        if(goods.attributes.count > 0){
            price.text = "¥"+goods.attributes[0].name
        }
        per_Silder.setThumbImage(UIImage(), for: .application)
        per_Silder.size.height = 10
      
        titleLabel.text = goods.name
        
        _ = Wolf.requestList(type: MyAPI.crowdfundingOrderTotalMoney(goodsId: goods.id), completion: { (info: [CrowdfundingMoney]?, msg, code) in
            if(code == "0" )
            {
                var totalPrice = 0
                if(info != nil && info!.count>0)
                {
                    totalPrice = Int(info![0].totalPrice!)
                }
 
                let persent = Int(totalPrice * 100 / Int(goods.price)!)
                self.per_Silder.setValue(Float(CGFloat(persent)/100), animated: true)
                
                self.persTitle.text = "\(persent)%"
            }
            else
            {
                _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
        
    }
}

class Crowdfunding2Cell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var persTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var per_Silder: UISlider!
    var sliderLabel: UILabel?
    
    @IBOutlet var numPeopleLb:UILabel!
    @IBOutlet var remainDayLb:UILabel!
    @IBOutlet var moneyGetLb:UILabel!
    func createSliderUI()
    {
        if(sliderLabel != nil){
            return
        }
        if let handleView = self.per_Silder.subviews.last as? UIImageView {
            let s_thumb = UIImageView(image: UIImage(named: "slider_b"))
            s_thumb.frame = CGRect(x: (handleView.bounds.width-50)/2, y: 0, width: 60, height: handleView.bounds.height)
            handleView.addSubview(s_thumb)
            
            let label = UILabel(frame: s_thumb.frame)
            label.backgroundColor = .clear
            label.textAlignment = .center
            handleView.addSubview(label)
            
            self.sliderLabel = label
            //set label font, size, color, etc.
            label.text = "50%"
        }
    }
    func configure(goods:WooGoodsItem) -> Void {
        if goods.images.count > 0
        {
            //            Log(goods.images.first!.src)
            imagePic.image(fromUrl: goods.images.first!.src)
        }
        
        
        titleLabel.text = goods.name
        
        _ = Wolf.requestList(type: MyAPI.crowdfundingOrderTotalPeople(goodsId: goods.id), completion: { (info: [CrowdfundingPeople]?, msg, code) in
            if(code == "0" )
            {
                if(info != nil && info!.count>0)
                {
                    self.numPeopleLb.text = "\(Int(info![0].totalPeople!))"
                }
                else
                {
                    self.numPeopleLb.text = "0 "
                }
            }
            else
            {
                _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
        
        _ = Wolf.requestList(type: MyAPI.crowdfundingOrderTotalMoney(goodsId: goods.id), completion: { (info: [CrowdfundingMoney]?, msg, code) in
            if(code == "0" )
            {
                var totalPrice = 0
                if(info != nil && info!.count>0)
                {
                    totalPrice = Int(info![0].totalPrice!)
                }
                if(self.sliderLabel == nil){
                    self.createSliderUI()
                }
                self.moneyGetLb.text = "\(totalPrice) 元"
                let persent = Int(totalPrice * 100 / Int(goods.price)!)
                self.per_Silder.value = Float(CGFloat(persent)/100)
                self.sliderLabel?.text = "\(persent)%"
            }
            else
            {
                _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
        
        
        
        if let date_from =  goods.date_on_sale_from , let date_to = goods.date_on_sale_to
        {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let time_from = dateFormatterGet.date(from: date_from)!//2017-08-28T08:24:37
            let time2 = dateFormatterGet.date(from: date_to)!//2017-08-28T08:24:37
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: Date())
            let date2 = calendar.startOfDay(for: time2)
            
            if time_from > Date()
            {
                remainDayLb.text = "\(dateFormatter.string(from: time_from)) 开始"
             
            }
            else if Date() > time2
            {
                remainDayLb.text = "活动已结束"
            }
            else
            {
                let components = calendar.dateComponents([.day], from: date1, to: date2).day!
                remainDayLb.text = "\(components)天"
            
            }
            
        }
    }
    
    
}

class ExchangeOrderCell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var typeLb: UILabel!
    @IBOutlet weak var price_prospect: UILabel!
    @IBOutlet weak var price_pay: UILabel!
    @IBOutlet weak var deliverBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    var addFunc:(()->Void)?
    var orderItem:ExchangeOrderItem?
    
    @IBAction func onClickDetailBtn()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowExchangeDetail"), object: self, userInfo: ["data":orderItem!])
    }
    
    @IBAction func onClickDeliverBtn()
    {
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowExchangeDeliver"), object: self, userInfo: ["data":orderItem!])
    }
    
    func configure(order:ExchangeOrderItem) -> Void {
        
        orderItem = order
        deliverBtn.layer.cornerRadius = 5;
        deliverBtn.layer.masksToBounds = true;
        deliverBtn.layer.borderColor = UIColor.darkGray.cgColor
        deliverBtn.layer.borderWidth = 1;
        detailBtn.layer.cornerRadius = 5;
        detailBtn.layer.masksToBounds = true;
        detailBtn.layer.borderColor = UIColor.darkGray.cgColor
        detailBtn.layer.borderWidth = 1;
        
        let offerPrice = (order.offerPrice != nil) ? order.offerPrice! : 0
        let payPrice = order.singlePrice * order.num - offerPrice
     
        date.text = order.createDate
        status.text = order.orderStatus
        imagePic.image(fromUrl: order.image ?? "")
        titleLabel.text = order.title ?? ""
        //                cell.typeLb.text = order.orderStatus
        price_prospect.text = (order.offerPrice != nil && order.offerPrice != 0) ? "￥\(order.offerPrice!).00" : "--"
        price_pay.text = "￥\(payPrice).00"
     
    }
}

class CreditsOrderCell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var deliverBtn: UIButton?
    var addFunc:(()->Void)?
    var orderItem:ScoresOrderItem?
    
    @IBAction func onClickAdd()
    {
        addFunc?()
    }
    
    func configure(order:ScoresOrderItem) -> Void {
        
        orderItem = order
        deliverBtn?.layer.cornerRadius = 5;
        deliverBtn?.layer.masksToBounds = true;
        deliverBtn?.layer.borderColor = UIColor.darkGray.cgColor
        deliverBtn?.layer.borderWidth = 1;
        deliverBtn?.isHidden = order.orderStatus != orderStatusArr[2]
        
       let payPrice = order.singlePrice //* order.num
        
        orderId.text = order.orderId
        date.text = order.createDate
        status.text = order.orderStatus
        imagePic.image(fromUrl: order.image ?? "")
        titleLabel.text = order.title ?? ""
        //                cell.typeLb.text = order.orderStatus
        price.text = "\(payPrice)\(Language.getString("积分"))"
        
    }
}
class CrowdfundingOrderCell: UITableViewCell {
    
    @IBOutlet weak var imagePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var deliverBtn: UIButton!
    @IBOutlet weak var paymentBtn: UIButton!
    var addFunc:(()->Void)?
    var orderItem:CrowdfundingOrderItem?
    
    @IBAction func onClickAdd()
    {
        addFunc?()
    }
    
    func configure(order:CrowdfundingOrderItem) -> Void {
        
        orderItem = order
        deliverBtn.layer.cornerRadius = 5;
        deliverBtn.layer.masksToBounds = true;
        deliverBtn.layer.borderColor = UIColor.darkGray.cgColor
        deliverBtn.layer.borderWidth = 1;
        
        paymentBtn.layer.cornerRadius = 5;
        paymentBtn.layer.masksToBounds = true;
        paymentBtn.layer.borderColor = UIColor.darkGray.cgColor
        paymentBtn.layer.borderWidth = 1;
        
        let payPrice = order.singlePrice //* order.num
        
        orderId.text = order.orderId
        date.text = order.createDate
        status.text = order.orderStatus
        imagePic.image(fromUrl: order.image ?? "")
        titleLabel.text = order.title ?? ""
        
        paymentBtn.isHidden = order.orderStatus != orderStatusArr[0]
        deliverBtn.isHidden = order.orderStatus != orderStatusArr[2]
        
        //                cell.typeLb.text = order.orderStatus
        price.text = "\(payPrice)\(Language.getString("元"))"
        
    }
}
class AddressCell: UITableViewCell {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var defaultBtn: UIButton!
    @IBOutlet weak var line1:UILabel!
    @IBOutlet weak var line2:UILabel!
    
    var toEditAction:(()->Void)?
    var deleteAction:(()->Void)?
    var setDefaultAction:(()->Void)?
    
    
    @IBAction func onDeleteEdit()
    {
        deleteAction?()
    }
    @IBAction func onClickEdit()
    {
        toEditAction?()
    }
    @IBAction func onDefaultEdit()
    {
        setDefaultAction?()
    }
}


class ScoresShopCell: UICollectionViewCell {
    
    @IBOutlet weak var imagePic:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var price:UILabel!
    

    func configure(goods:WooGoodsItem) -> Void {
        if goods.images.count > 0
        {
            imagePic.image(fromUrl: goods.images.first!.src)
        }
        titleLabel.text = goods.name
        price.text = goods.price+"积分"
    }
}


class FansCell: UITableViewCell {
    
    @IBOutlet weak var imagePic:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    
    func configure(fans:FansData) -> Void {
       
        nameLabel.text = fans.userName
        if let icon = fans.icon
        {
            imagePic.image(fromUrl:icon)
        }
    }
}
