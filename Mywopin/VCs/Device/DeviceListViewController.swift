//
//  DeviceListViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/3.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit
import Moya
import PKHUD


class DeviceListViewController: UITableViewController {
    
    static var shared:DeviceListViewController?
    var category = Dictionary<String, AnyObject>()
    var cups = [CupItem]()
    var cellHeight:CGFloat = 100
    
    var timer:Timer?
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            self.clearsSelectionOnViewWillAppear = false
//            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DeviceListViewController.shared = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.topItem?.title = Language.getString( "设备")
        
        cups = cup_list
        self.tabBarController?.tabBar.isHidden = false
        self.updatePostList()
        self.tableView.reloadData()
        
        timer = setInterval(interval: 1, block: {
            self.checkCupStatus()
        })
    }
    
    func checkCupStatus()
    {
        for i in 0..<cups.count {
            (self.tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? DeviceCell)?.checkOnline()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    func updatePostList() {

        cups = []
        HUD.show(.progress)
        _ = Wolf.requestList(type: MyAPI.cupList, completion: { (cups: [CupItem]?, msg, code) in
            if(code == "0")
            {
                Log(cups?.count)
                if let cupsItems = cups
                {
                    self.cups = cupsItems
                    cup_list = cupsItems
                    self.tableView.reloadData()
                }
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
            HUD.hide()
        }, failure: nil)
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if self.tableView.indexPathForSelectedRow != nil {
               
            }
        }
    }
    
    func addCallBack()
    {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addDeviceView")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    // MARK: - Table View
//    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 130
//    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section==1 ? 1 : cups.count
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section==1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddDevice", for: indexPath) as! AddDeviceCell
            cell.addFunc = addCallBack
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Device", for: indexPath) as! DeviceCell
            let cup = cups[indexPath.row]
            cell.configureWithData(cup);
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cups.count > indexPath.row
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceInfo") as! DeviceInfoVC
            self.navigationController?.pushViewController(vc, animated: true)
            vc.onSetData(info: cups[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (cups.count > 0) {
                print("Deleted \(cups[indexPath.row].uuid)")
                _ = Wolf.request(type: MyAPI.deleteACup(uuid: cups[indexPath.row].uuid), completion: { (user: User?, msg, code) in
                    if(code == "0")
                    {
                        self.cups.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                    else
                    {
                        _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
                    }
                }, failure: nil)
            }
        }
    }
}


