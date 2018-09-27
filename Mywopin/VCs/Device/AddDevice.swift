//
//  AddDevice.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//


import Foundation
import UIKit
import ChromaColorPicker
import RxSwift


class AddDevice: UIViewController {
    
    
    
    //    @IBOutlet var iconLight:UILabel!
    @IBOutlet var helpBtn:UIButton!
    @IBOutlet var iconLight:UIImageView!
    
    var powerFlag:Variable = Variable(true)
    
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
        NSAttributedStringKey.foregroundColor : UIColor.blue,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let attributeString = NSMutableAttributedString(string: Language.getString("如果不知道是什么版本？"),
                                                        attributes: yourAttributes)
        helpBtn.setAttributedTitle(attributeString, for: .normal)
    }
    
    @IBAction func clickPowerBtn()
    {
        powerFlag.value = !powerFlag.value
        WifiController.shared.sendToggleLED(on: powerFlag.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.title = ""
//        self.navigationItem.title = Language.getString("灯光设置")
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    @IBAction func onReturn()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //    override public func draw(_ rect: CGRect) {
    //
    //        let point = calculatePoint(color: selectedColor)
    //        cursorImageView.center = point
    //    }
    
    
    
    private func didSelect(color: UIColor) {
        
        print(color.redValue)
        let command = wopinLEDCommand(r: Int(color.redValue), g: Int(color.greenValue), b: Int(color.blueValue))
        BLEController.shared.sendCommandToConnectedDevice(command)
        WifiController.shared.sendRGBCommandToWopin(r: Int(color.redValue) , g: Int(color.greenValue), b: Int(color.blueValue))
    }
    
    
    
}

