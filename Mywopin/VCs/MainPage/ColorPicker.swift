//
//  ColorPicker.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/3.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import ChromaColorPicker
import RxSwift


class ColorPicker: UIViewController {
    
    static var LAST_COLOR:UIColor?
    static var LAST_LED_ON:Bool = true
    
//    @IBOutlet var iconLight:UILabel!
    @IBOutlet var iconLightBtn:UIButton!
    @IBOutlet var iconLight:UIImageView!
    
    var colorPicker: ChromaColorPicker!
    var powerFlag:Variable = Variable(LAST_LED_ON)
    
    
    var 👜 = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerSize = CGSize(width: view.bounds.width*0.8, height: view.bounds.width*0.8)
        let pickerOrigin = CGPoint(x: view.bounds.midX - pickerSize.width/2, y: view.bounds.midY - pickerSize.height/2)
        
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
//        colorPicker.delegate = self
        
        colorPicker.padding = 10
        colorPicker.stroke = 13 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        
        colorPicker.addButton.isHidden = true
        colorPicker.handleLine.isHidden = true
        colorPicker.hexLabel.isHidden = true
        
        self.view.addSubview(colorPicker)
        self.view.addSubview(colorPicker.shadeSlider)
        self.view.insertSubview(iconLightBtn, at: view.subviews.count)
        
        colorPicker.shadeSlider.frame = CGRect(x: view.bounds.midX - pickerSize.width/2, y: view.bounds.midY - pickerSize.height, width: pickerSize.width, height: 20)
        colorPicker.shadeSlider.centerY = view.bounds.height / 2 + 200

        colorPicker.shadeSlider.layoutLayerFrames()
        colorPicker.addTarget(self, action:  #selector(onChangeColor), for: UIControlEvents.valueChanged)
        
        
        powerFlag.asObservable().subscribe(onNext:{
            if $0{
                self.iconLightBtn.isSelected = true
//                self.iconLight.image = UIImage(named: "lightUI1")
                ColorPicker.LAST_LED_ON = true
                BLEController.shared.sendCommandToConnectedDevice(WopinCommand.COLOR_LED_ON)
                self.didSelect(color: ColorPicker.LAST_COLOR)
            }else{
                self.iconLightBtn.isSelected = false
//                self.iconLight.image = UIImage(named: "lightUI2")
                ColorPicker.LAST_LED_ON = false
                BLEController.shared.sendCommandToConnectedDevice(WopinCommand.COLOR_LED_OFF)
                self.didSelect(color: ColorPicker.LAST_COLOR)
            }
        }).disposed(by: 👜)
        
    }
    
    @IBAction func clickPowerBtn()
    {
        
        powerFlag.value = !powerFlag.value
    }
    
    @objc func onChangeColor(sender:UISlider){
        didSelect(color: colorPicker.currentColor)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.title = Language.getString("灯光设置")
        
        if let toColor = ColorPicker.LAST_COLOR
        {
            colorPicker.adjustToColor(toColor)
        }
        
        powerFlag.value = ColorPicker.LAST_LED_ON
        didSelect(color: ColorPicker.LAST_COLOR)
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
    

    
    private func didSelect(color: UIColor?) {
        if let c = color
        {
            //        print(color.redValue)
            let command = wopinLEDCommand(r: Int(c.redValue), g: Int(c.greenValue), b: Int(c.blueValue))
            BLEController.shared.sendCommandToConnectedDevice(command)
            WifiController.shared.sendRGBCommandToWopin(r: Int(c.redValue) , g: Int(c.greenValue), b: Int(c.blueValue))
            ColorPicker.LAST_COLOR = color
            
        }
    }
    
  
    
}

