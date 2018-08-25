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


class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    
    var postIdentifier:Int = 0
    var imageRequestedForIdentifier:Int = 0
    
    func configureWithPostDictionary (_ post:Dictionary<String, AnyObject>) {
        
        let title = post["title"] as? String
        self.titleLabel!.text = title//String(htmlEncodedString: title!)
        
        self.dateLabel!.text = nil;
        
        if let dateStringFull = post["date"] as? String {
            // date is in the format "2016-01-29T01:45:33+02:00",
            let dateString = dateStringFull.substring(to: dateStringFull.characters.index(dateStringFull.startIndex, offsetBy: 10))  // keep only the date part
            
            let parsingDateFormatter = DateFormatter()        // TODO: a static var
            parsingDateFormatter.dateFormat = "yyyy-MM-dd"
            let date = parsingDateFormatter.date(from: dateString)
            
            let printingDateFormatter = DateFormatter()       // TODO: a static var
            printingDateFormatter.dateStyle = .long
            printingDateFormatter.timeStyle = .none
            
            self.dateLabel!.text = printingDateFormatter.string(from: date!)
        }
        
        self.featuredImageView!.image = nil;
        if let idf = post["ID"] as? Int {
            postIdentifier = idf
        }
        
        if let url = post["featured_image"] as? String {    // there is a link to an image
            if url != "" {
                imageRequestedForIdentifier = postIdentifier
                WordPressWebServices.sharedInstance.loadImage (url, completionHandler: {(image, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        // test if the cell has been recycled since we request the image !
                        if self.postIdentifier == self.imageRequestedForIdentifier {
                            self.featuredImageView!.image = image;
                            self.setNeedsLayout()
                        }
                        else {
                            print("postIdentifier: \(self.postIdentifier) different from imageRequestedForIdentifier: \(self.imageRequestedForIdentifier)")
                        }
                    })
                })
            }
        }
        
    }
    
}

class DeviceCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var powerView: UIButton!
    
    var postIdentifier:Int = 0
    var imageRequestedForIdentifier:Int = 0
    
    func configureWithData (_ data:CupItem) {
        
        self.titleLabel!.text = data.name//String(htmlEncodedString: title!)
        
        powerView.isSelected = false
        
//        if(data.type)
//        self.featuredImageView!.image = nil;
        #if targetEnvironment(simulator)
        #else
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
    @IBOutlet weak var deliverBtn: UIButton!
    var addFunc:(()->Void)?
    var orderItem:ScoresOrderItem?
    
    @IBAction func onClickAdd()
    {
        addFunc?()
    }
    
    func configure(order:ScoresOrderItem) -> Void {
        
        orderItem = order
        deliverBtn.layer.cornerRadius = 5;
        deliverBtn.layer.masksToBounds = true;
        deliverBtn.layer.borderColor = UIColor.darkGray.cgColor
        deliverBtn.layer.borderWidth = 1;
        
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
