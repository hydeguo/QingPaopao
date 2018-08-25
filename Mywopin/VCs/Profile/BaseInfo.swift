//
//  BaseInfo.swift
//  Mywopin
//
//  Created by GuoXiaobin on 26/6/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


class BaseInfo: UITableViewController {
    
    
    @IBOutlet var nameLb:UILabel!
    @IBOutlet var icon:UIImageView!
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        if let myIcon = myClientVo?.icon
        {
            icon.image(fromUrl: myIcon)
        }
        nameLb.text = myClientVo?.userName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        
        let _view = UIView()
        _view.backgroundColor = .clear
        self.tableView.tableFooterView = _view
        
    }
    
    
    
}

