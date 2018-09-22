

import UIKit

extension PaySDK {
    public func sendAuthRequest() -> Void {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = state
        WXApi.send(req)
    }
}

extension PaySDK: WXApiDelegate {
    public func onResp(_ resp: BaseResp!) {
        if let authResp = resp as? SendAuthResp {
            if 0 == authResp.errCode && state == authResp.state {
//                self.authDelegate?.authRequestSuccess(code: authResp.code)
            } else {
//                self.authDelegate?.authRequestError(error: authResp.errStr)
            }
        }
        else if let payResp = resp as? PayResp
        {
            
            if 0 == payResp.errCode {
                payDelegate?.payRequestSuccess(data: payResp.returnKey)
            } else {
                payDelegate?.payRequestError(error: payResp.errStr ?? "canceled")
            }
        }
    }
}
