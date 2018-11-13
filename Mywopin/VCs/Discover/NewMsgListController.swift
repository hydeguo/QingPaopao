//
//  NewMsgListController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/11/10.
//  Copyright © 2018 Wopin. All rights reserved.
//


import Foundation
import Disk


class NewMsgListController: UITableViewController {
    
    var newMsg:BlogMsgData?
    var cellHeight:CGFloat = 140
    
    var getByUserId:String?
    
    var myComments:[BlogComment] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = ""

        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTitle()
    }

    
    private func updateTitle()
    {
        navigationController?.navigationBar.topItem?.title = Language.getString( "新的评论")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NotificationCenter.default.removeObserver(self)
    }
    
  


    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SysMsgDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let post = posts[indexPath.row - 3]
//                let controller = segue.destination as! PostDetailController
//                controller.detailItem = post
//                controller.sysMsg = true
//                controller.showBackBtn = false
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
    
    
    // MARK: - Table View
    //    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 130
    //    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        return []
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return newMsg?.newComment.count ?? 0
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCommentMsgCell", for: indexPath) as! NewCommentMsgCell
        cell.configure(newMsg!.newComment[indexPath.row])
        return cell
    }
    
    
}


