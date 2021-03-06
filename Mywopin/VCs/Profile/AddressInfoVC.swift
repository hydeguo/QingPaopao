//
//  AddressInfoVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/7.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation




class AddressInfoVC: UITableViewController,AddressPickerViewDelegate ,UITextFieldDelegate{
    
    @IBOutlet var nameLf:UITextField!
    @IBOutlet var phoneLf:UITextField!
    @IBOutlet var addressLf1:UITextField!
    @IBOutlet var addressLf2:UITextField!
    
    var picker: AddressPickerView?
    var myAddressItem:AddressItem = AddressItem(addressId: UUID().uuidString, userName: "", address1: "",  address2: "", postCode: nil, tel: nil, isDefault: false)
    
    func onSetData(data:AddressItem)
    {
       myAddressItem = data
    }
    
    //MARK: Check if user is signed in or not
    override func viewWillAppear(_ animated: Bool) {
        let _editAddress = myAddressItem
        
            nameLf.text = _editAddress.userName
        phoneLf.text = _editAddress.tel == nil ? "" : String(Int(_editAddress.tel! ))
            addressLf1.text = _editAddress.address1
            addressLf2.text = _editAddress.address2
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLf.delegate = self
        phoneLf.delegate = self
        addressLf1.delegate = self
        addressLf2.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let offset_y:CGFloat = UIDevice.current.modelName  == "iPhone X" ? 20.0 : 0.0;
        picker = AddressPickerView.addTo(superView: view, offsetTop: (self.navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.height + offset_y)
        picker?.delegate = self
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !picker!.isHidden {
            picker!.hide()
        }
    }
    @IBAction  func showAddressSelecter()
    {
        //        picker?.isAutoOpenLast = false
        picker?.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func saveAction(sender: AnyObject) {
        
        UIApplication.shared.keyWindow?.endEditing(true)
        if(nameLf.text?.count==0){
            _ = SweetAlert().showAlert("Sorry", subTitle: "请输入名字!", style: AlertStyle.error)
            return
        }else if(!isPhoneNumber(phoneNumber: phoneLf.text!)){
            _ = SweetAlert().showAlert("Sorry", subTitle: "请输入正确手机号码!", style: AlertStyle.error)
            return
        }else if(addressLf1.text?.count==0){
            _ = SweetAlert().showAlert("Sorry", subTitle: "请选择地区!", style: AlertStyle.error)
            return
        }else if(addressLf2.text?.count==0){
            _ = SweetAlert().showAlert("Sorry", subTitle: "请输入详细地址!", style: AlertStyle.error)
            return
        }
        
        if(myClientVo?.addressList?.count == 0){
            myAddressItem.isDefault = true
        }
        
//        let address = "\(addressLf1.text! )\(addressLf2.text!)"
        _ = Wolf.request(type: MyAPI.addOrUpdateAddress(addressId: myAddressItem.addressId, userName: nameLf.text!, address1:addressLf1.text!, address2: addressLf2.text! , tel: Int(phoneLf.text!)! , isDefault: myAddressItem.isDefault!), completion: { (user: User?, msg, code) in
            
            if(code == "0")
            {
                myClientVo = user
                _ = SweetAlert().showAlert(Language.getString("保存成功"), subTitle: msg, style: AlertStyle.success)

            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
    //-----------------------------------
    func addressSure(provinceID: Int?, cityID: Int?, regionID: Int?) {
        
    }
    
    func addressSure(province: String?, city: String?, region: String?) {
        var p = ""
        var c = ""
        var r = ""
        if province != nil { p = province! }
        if city != nil { c = city! }
        if region != nil { r = region! }
        addressLf1.text = p + c + r
    }
  
}
