//
//  AddressListVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/8.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class AddressListVC: UITableViewController {
    
    var cellHeight:CGFloat = 140
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        if myClientVo?.addressList == nil
        {
            myClientVo?.addressList = []
        }
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        let addButton =  UIBarButtonItem(title: Language.getString("新增") , style: .plain, target: self, action:  #selector(onAddNew))
        self.navigationController!.topViewController!.navigationItem.rightBarButtonItem =  addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.tableView.reloadData()
        
    }
    @objc func onReturn()
    {
                self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    @objc func onAddNew()
    {
        let vc = R.storyboard.main.addressInfoVC()
        self.show(vc!, sender: nil)
    }
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAddress" {
            if let btn = sender  {
                let indexPath = (btn as! UIButton) .tag
                let controller = segue.destination as! AddressInfoVC
                controller.onSetData (data: (myClientVo?.addressList![indexPath])!)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "selectAddress" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let post = posts[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! AddressInfoVC
//                controller.detailItem = post
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    //    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 130
    //    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myClientVo!.addressList!.count
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        if let address = myClientVo?.addressList![indexPath.row]
        {
            cell.line1.text = "\(address.userName ) \(String(Int(address.tel!)))"
            cell.line2.text = "\(address.address1 ?? "" ) \(String(address.address2 ?? ""))"
        }
        cell.editBtn.tag = indexPath.row
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        NSLog("You selected cell number: \(indexPath.row)!")
//        self.performSegue(withIdentifier: "yourIdentifier", sender: self)
        ExchangeBuyVC.selectedAddress = myClientVo?.addressList![indexPath.row]
        ExchangeNewBuyVC.selectedAddress = myClientVo?.addressList![indexPath.row]
        onReturn()
    }
    
}
