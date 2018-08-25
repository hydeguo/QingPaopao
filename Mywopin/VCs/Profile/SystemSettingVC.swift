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
    
   
}
