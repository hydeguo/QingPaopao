//
//  SystemSettingVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/13.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


class SystemSettingVC: UITableViewController {
    

    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.separatorInset = .zero;
        
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
    }
    
    
    
    
    @objc func save(_ sender: Any) {
        
    }
    
}

class VersionVC: UITableViewController {
    
    @IBOutlet var verstionLB :UILabel!
    var appStoreVersion:String?
    var isNewest:Bool = false
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.separatorInset = .zero;
        
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        
        let infoDictionary = Bundle.main.infoDictionary
        if let curverion = infoDictionary? ["CFBundleShortVersionString"] as? String,
            let identifier = infoDictionary?["CFBundleIdentifier"] as? String,let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)")
        {
            verstionLB.text = "V\(curverion)"
            
            do{
                
                let data = try Data(contentsOf: url)
                guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
                    //            throw VersionError.invalidResponse
                    return
                }
                if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
                    print("version in app store", version);
                    self.appStoreVersion = version
                    if version != curverion && version > curverion
                    {
                        self.popupUpdateDialogue();
                    }
                    else
                    {
                        self.isNewest = true
                    }
                }
                
            }catch{
                
            }
        }
        
        
    }
    
    func popupUpdateDialogue(){
        let versionInfo = self.appStoreVersion ?? ""

        let alertMessage = "可以使用新版本的氢泡泡应用程序，请更新至版本 "+versionInfo;
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okBtn = UIAlertAction(title: "更新", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/cn/app/%E6%B0%A2%E6%B3%A1%E6%B3%A1/id1194023418?mt=8"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"忽略此版本" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func clickUpdate(){
        
        
        let alertMessage = "氢泡泡应用程序已经是最新版本";
        let alert = UIAlertController(title: "版本信息", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let noBtn = UIAlertAction(title:"确定" , style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
   
}
