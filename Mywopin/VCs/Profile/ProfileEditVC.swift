//
//  ProfileEditVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/13.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ProfileEditVC: UITableViewController {

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
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changePassword" {
            guard myClientVo?.phone != nil && myClientVo?.phone != 0 else{
                let vc = R.storyboard.main.bindingPhone()
                self.show(vc!, sender: nil)
                return
            }
//            let vc = R.storyboard.main.bandPhone()
//            self.show(vc!, sender: nil)
        }
//        else  if segue.identifier == "bandPhone" {
//        }
    }
    
    @IBAction func logout(_ sender: Any) {
        
        _ = Wolf.request(type: MyAPI.logout, completion: { (user: BaseReponse?, msg, code) in
            if(code == "0")
            {
                self.dismiss(animated: true, completion: {});
                self.navigationController?.popViewController(animated: true);
                return
            }
        }, failure: nil)
    }
    
}
