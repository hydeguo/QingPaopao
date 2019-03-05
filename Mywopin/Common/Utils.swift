

import Foundation
import AVFoundation
import UIKit
import Kingfisher


// 屏幕宽度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
// 屏幕高度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width


class Utils {
    
    
    static var initAVAudioObserver:Bool = false
    /**
    获取文档路径
    
    :returns: 文档路径
    */
    class func documentPath() -> String{
        //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // file:///var/mobile/Containers/Data/Application/2E4CAE25-CAC3-4513-92E5-93D3E3180222/Documents/
       // /var/mobile/Containers/Data/Application/2E4CAE25-CAC3-4513-92E5-93D3E3180222/Documents
        
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
    }

    
    class var  isHeadphoneIn :Bool{
        
        get{
            var isHeadphone:Bool = false
            let currentRoute = AVAudioSession.sharedInstance().currentRoute
            if currentRoute.outputs.count > 0 {
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSessionPortHeadphones {
                        print("headphone plugged in")
                        isHeadphone = true
                    } else {
                        print("headphone pulled out")
                    }
                }
            } else {
                print("requires connection to device")
            }
            return isHeadphone
        }
    }
    
    class func setToSpeaker(_ flag:Bool)
    {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            if(Utils.initAVAudioObserver == false){
                NotificationCenter.default.addObserver(self, selector: #selector(Utils.routeChange), name: .AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
                Utils.initAVAudioObserver = true
            }
            
            print("setToSpeaker......: \(flag)")
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            if(flag){
                try session.overrideOutputAudioPort(.speaker)
            }else{
                try session.overrideOutputAudioPort(.none)
            }
            try session.setActive(true)
        } catch let error as NSError {
            print("AVAudioSession..... error: \(error.localizedDescription)")
        }
    }
    
    @objc class func routeChange(_ notify: Notification){
        //        debugPrint("setToSpeaker ...AVAudioSessionRouteChange")
        //        if notify=nil {
//        print("setToSpeaker 声音声道改变------------\(notify)")
        
        if((notify.userInfo != nil)){
            if let c_key = notify.userInfo!["AVAudioSessionRouteChangeReasonKey"] as? Int
            {
                if((c_key) == 8 && !Utils.isHeadphoneIn)
                {
                   Utils.setToSpeaker(!Utils.isHeadphoneIn);
                }
            }
            
        }
        
        //        }
        //        let route: AVAudioSessionRouteDescription? = AVAudioSession.sharedInstance().currentRoute
        //        for desc: AVAudioSessionPortDescription in route?.outputs {
        //            print("当前声道\(desc.portType)")
        //            print("输出源名称\(desc.portName)")
        //            if (desc.portType == "Headphones") {
        //                DispatchQueue.main.async(execute: {() -> Void in
        //                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverrideNone)
        //                })
        //            }
        //            else {
        //                DispatchQueue.main.async(execute: {() -> Void in
        //                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverrideSpeaker)
        //                })
        //            }
        //        }
    }
    
    //    NotificationCenter.default.addObserver(self,selector: #selector(self.audioRouteChangeListener),name:NSNotification.Name.AVAudioSessionRouteChange,object: AVAudioSession.sharedInstance())
    
    
    //    dynamic private func audioRouteChangeListener(notification:NSNotification) {
    //        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
    //
    //        switch audioRouteChangeReason {
    //        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
    //            print("headphone plugged in")
    //            setToSpeaker(false)
    //        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
    //            print("headphone pulled out")
    //            setToSpeaker(true)
    //
    //        default:
    //            break
    //        }
    //    }
}


public func versionCheck(view:UIViewController)
{
    let url = URL(string: "https://newweb.onwardsmediagroup.com/internal/OMGPro/ios_version")
    
    do {
        let last_version = try String(contentsOf:url!).trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if let cur_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String
        {
            if ( last_version == cur_version) {return}
            
            let alertController = UIAlertController(title: "Update to lastest version?",
                                                    message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Later", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Yes", style: .default, handler: { (alter) in
                UIApplication.shared.open(URL(string : "itms-services://?action=download-manifest&url=itms-services://?action=download-manifest&url=https%3a%2f%2fnewweb.onwardsmediagroup.com%2finternal%2fplist%2fapp_onwardspro_dev.plist")!, options: [:], completionHandler: { (status) in
                    exit(0);
                })
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            view.present(alertController, animated: true, completion: nil)
            
        }
    }
    catch let error {
        // Error handling
        debugPrint(error.localizedDescription)
    }
    
}
extension UIImageView {
    public func image(fromUrl urlString: String) {
        guard let url = URL(string: urlString.urlEncoded()) else {
            print("[warning]:Couldn't create URL from \(urlString)")
            self.image = R.image.dafault()
            return
        }
        self.kf.cancelDownloadTask()
        self.kf.setImage(with: url, placeholder: R.image.dafault(), options: nil, progressBlock: nil, completionHandler: nil)
    }
}

extension UIFont {
    public class func iconfont(size: CGFloat) -> UIFont {
        return UIFont(name: "iconfont", size: size)!
    }
}


func setStatusBarBackgroundColor(color: UIColor) {
    
    guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
    statusBar.backgroundColor = color
}



func isPhoneNumber(phoneNumber:String) -> Bool {
    if phoneNumber.count == 0 {
        return false
    }
    let mobile = "^(13[0-9]|15[0-9]|18[0-9]|17[0-9]|147)\\d{8}$"
    let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
    if regexMobile.evaluate(with: phoneNumber) == true {
        return true
    }else
    {
        return false
    }
}



func createGradientLayer(view:UIView,startPoint:CGPoint? = nil,endPoint:CGPoint?  = nil)
{
    //设置渐变的主颜色
    let gradientColors = [UIColor.colorFromRGB(0x77ffd2).cgColor,UIColor.colorFromRGB(0x6297db).cgColor,UIColor.colorFromRGB(0x1eecff).cgColor]
    //定义每种颜色所在的位置
    let gradientLocations:[NSNumber] = [0.0,  0.5,  1.0]
    
    //创建CAGradientLayer对象并设置参数
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = gradientColors
    gradientLayer.locations = gradientLocations
    
    //设置渲染的起始结束位置（横向渐变）
    gradientLayer.startPoint = (startPoint != nil) ? startPoint! : CGPoint(x: 0, y: 1)
    gradientLayer.endPoint = (endPoint != nil) ? endPoint! : CGPoint(x: 1, y: 0)
    
    //设置其CAGradientLayer对象的frame，并插入view的layer
    gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height) 
    view.layer.insertSublayer(gradientLayer, at: 0)
}

func currentTimeZoneDate() -> String {
    let dtf = DateFormatter()
    dtf.timeZone = TimeZone.current
    dtf.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dtf.string(from: Date())
}


