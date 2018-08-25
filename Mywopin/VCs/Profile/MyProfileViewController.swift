//
//  MyProfileViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/6.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit


class MyProfileViewController: UIViewController {
    
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var scoreLabel:UILabel!
    @IBOutlet var topPofileImage:UIImageView!
    @IBOutlet var topView:UIView!
    @IBOutlet var drinkCupLabel:UILabel!
    @IBOutlet var drinkCupTotalLabeL:UILabel!
    @IBOutlet var attendanceBtn:UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        createGradientLayer(view: self.topView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
       
        updateUI()
        
        updateDrinkText()
    }
    
    func updateUI(){
        let name = myClientVo?.userName ?? String(stringInterpolationSegment: myClientVo?.phone)
        nameLabel.text = name
        let myScores = myClientVo?.scores != nil ? Int(myClientVo!.scores!) : 0
        scoreLabel.text = "\(myScores) 积分"
        
        if(self.getDayString(day:Date()) == myClientVo?.lastAttendance)
        {
            attendanceBtn.isEnabled = false
            attendanceBtn.setTitle("已签到", for: .normal)
        }
        
    }
    func getDayString(day:Date)->String
    {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyyMMdd";
        return dateFormatter.string(from: day);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        
        if let myIcon = myClientVo?.icon
        {
            topPofileImage.image(fromUrl: myIcon)
        }
        
        
        drinkCupLabel.layer.cornerRadius = drinkCupLabel.height/2;
        drinkCupLabel.layer.masksToBounds = true;
        drinkCupLabel.layer.borderColor = UIColor.white.cgColor
        drinkCupLabel.layer.borderWidth = 1;//边框宽度
        drinkCupTotalLabeL.layer.cornerRadius = drinkCupTotalLabeL.height/2;
        drinkCupTotalLabeL.layer.masksToBounds = true;
        drinkCupTotalLabeL.layer.borderColor = UIColor.white.cgColor
        drinkCupTotalLabeL.layer.borderWidth = 1;//边框宽度
    }
    func updateDrinkText()
    {
        if let _todayDrinks = todayDrinks
        {
            self.drinkCupLabel.text = String(_todayDrinks.drinks!.count) + Language.getString("杯")
        }
        self.drinkCupTotalLabeL.text = String(Int(myClientVo?.drinks ?? 0)) + Language.getString("杯")
    }
    
    @IBAction func attendance()
    {
        _ = Wolf.request(type: MyAPI.attendance, completion: { (user: User?, msg, code) in
            
            if(code == "0")
            {
                myClientVo = user
                _ = SweetAlert().showAlert("", subTitle: Language.getString("签到成功"), style: AlertStyle.none)
                self.updateUI()
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
