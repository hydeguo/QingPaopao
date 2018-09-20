

import UIKit
import Alamofire
import Disk

public struct WoPinWeChatPayRes: Codable {
    
    var status: String
    var msg: String?
    var result: WeChatPay?
    
}
public struct WeChatPay: Codable {
    
    var noncestr: String
    var partnerid: String
    var prepayid: String
    var timestamp: UInt32
    var package: String
    var sign: String
    
}


extension PaySDK {
    
    
    public func getWechatPaySign(totalAmount: Int, subject: String, payTitle: String,orderId:String) -> Void {
        if let signUrl = self.signUrl {
            
            do {
                let retrievedMessage = try Disk.retrieve("\(orderId).json", from: .caches, as: WoPinWeChatPayRes.self)
                self.payDelegate?.wechatPaySign(data: retrievedMessage)
            } catch _ as NSError {
                
                let requestURL = signUrl
                let endpointUrl = URL(string: requestURL)
                
                let params = "amount=\(totalAmount)&subject=\(subject)&body=\(payTitle)&orderId=\(orderId)"
                let postString = params
                var request = URLRequest(url: endpointUrl!)
                request.httpMethod = "POST"
                request.httpBody = postString.data(using: .utf8)
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if error != nil {
                        self.payDelegate?.payRequestError(error: error?.localizedDescription ?? "error")
                        return;
                    }
                    do {
                        let item = try JSONDecoder().decode(WoPinWeChatPayRes.self, from: data!)
                        self.payDelegate?.wechatPaySign(data: item)
                        
                        do {
                            try Disk.save(item, to: .caches, as: "\(orderId).json")
                        } catch _ as NSError {}
                        
                    } catch {
                        print(error)
                    }
                })
                task.resume()
            }
            
        } else {
            self.payDelegate?.payRequestError(error: "签名地址不存在")
        }
    }
    
    public func wechatPayRequest(resData: WoPinWeChatPayRes) {
        
        if(resData.status == "0"){
            let payReq = PayReq()
            let signData = resData.result
            
            payReq.nonceStr = signData?.noncestr
            payReq.partnerId = signData?.partnerid
            payReq.prepayId = signData?.prepayid
            payReq.timeStamp = (signData?.timestamp)!
            payReq.package = signData?.package
            payReq.sign = signData?.sign
            
            DispatchQueue.main.async {
                WXApi.send(payReq)
            }
            
        }else{
            self.payDelegate?.payRequestError(error: resData.msg ?? "订单错误")
        }
    }
}
