//
//  PayManager.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/1.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
enum PaymentEvent:String {
    
    case paymentReturn = "paymentReturn"
    
}

public class PayManager : NSObject,MOBPayObserverDelegate
{
    
    static let shared:PayManager = PayManager()

    
    func doPayment(orderId:String, price:Int,channel:MPSChannel,itemDesc:String,address:String)
    {
        
        let charge = MPSCharge()
        charge.orderId = orderId
        charge.amount = 1//price;
        charge.channel = channel;
        charge.subject = itemDesc;
        
        //可选参数
//        var dese = ""
//        if let _selectedAddress = selectedAddress ?? getDefaultAddress()
//        {
//            dese = "\(_selectedAddress.userName)\(" ")\(String(Int(_selectedAddress.tel!)))\("\n")\(_selectedAddress.address1!)\(_selectedAddress.address2!)"
//        }
        charge.appUserId = myClientVo?._id;
        charge.appUserNickname = myClientVo?.userName;
        charge.body = itemDesc ;
        charge.desc = address;//"这笔订单只是测试，不加入统计";
//        charge.metadata = "@{@\"dec\":@\"metaData\"}";
        
        MOBPay.pay(with: charge)
        //        _currentCharge = charge;
        //        [MOBPay payWithCharge:charge];
    }

    public func paymentTransaction(_ transaction: MPSPaymentTransaction!, statusDidChange status: MPSPayStatus) {
        
        switch (status) {
            
        case .begin: //说明已获取到ticketId开始吊起支付
            Log(transaction.ticketId)
            break;
            
        case .success://支付成功
            
            Log("success")
            break;
            
        case .cancel://取消支付
            Log("cancel")
//            [MPSPayStatusHUD showWithInfo:@"付款失败，请稍后重试"];
            break;
            
        default://支付失败
            Log(transaction.error)
//            [MPSPayStatusHUD showWithInfo:@"付款失败，请稍后重试"];
            break;
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaymentEvent.paymentReturn.rawValue), object: self, userInfo: ["status":status])
//        if(status != MPSPayStatusBegin)
//        {
//            [self _persistenceOrderWithStatus:status];//缓存订单,demo演示用
//        }
    }

}
