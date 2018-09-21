//
//  MyFansList.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/15.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import Disk
import PKHUD


enum Fans_MODE:String {
    
    case fans = "fans"
    case follow = "follow"
    
}


class MyFansList: UITableViewController {
    
    var category = Dictionary<String, AnyObject>()
    var fansList = [FansData]()
    var cellHeight:CGFloat = 60
    
    var mode:Fans_MODE = .fans
    
    
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
        switch mode {
        case .fans:
            navigationController?.navigationBar.topItem?.title = Language.getString( "我的粉丝")
        default:
            navigationController?.navigationBar.topItem?.title = Language.getString( "我的关注")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(updatePostList),
                                  for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "reloading...")
        tableView.addSubview(refreshControl!)
        
        self.updatePostList()
        
        self.tableView.tableFooterView=UIView(frame: CGRect.zero)
        self.tableView.separatorInset = .zero;
    }
    
    func setInitData()
    {
        fansList.removeAll()
        do {
            if mode == .fans
            {
                let retrievedMessage = try Disk.retrieve("fansList.json", from: .caches, as: [FansData].self)
                fansList = retrievedMessage
            }
            else if mode == .follow
            {
                let retrievedMessage = try Disk.retrieve("followList.json", from: .caches, as: [FansData].self)
                fansList = retrievedMessage
            }
            
            
        } catch _ as NSError {}
    }
    
    
    func changeMode(mode:Fans_MODE)
    {
        if self.mode != mode
        {
            self.mode = mode
            setInitData()
            self.tableView.reloadData()
            self.updatePostList()
        }
    }
    
    @objc func updatePostList() {
        if(fansList.count==0){
            refreshControl?.beginRefreshing()
        }
        if mode == .fans
        {
            _ = Wolf.requestList(type: MyAPI.getFansList, completion: { (fans: [FansData]?, msg, code) in
                if let _fans = fans {
                    self.fansList = _fans
                    
                    do {
                        try Disk.save(self.fansList, to: .caches, as: "fansList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
        else if mode == .follow
        {
            _ = Wolf.requestList(type: MyAPI.getMyFollowList, completion: { (fans: [FansData]?, msg, code) in
                if let _fans = fans {
                    self.fansList = _fans
                    
                    do {
                        try Disk.save(self.fansList, to: .caches, as: "followList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        HUD.hide()
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
       
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let post = posts[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! PostDetailController
//                controller.detailItem = post
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fansList.count
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FansCell", for: indexPath) as! FansCell
        let fansData = fansList[indexPath.row]
        cell.configure(fans: fansData);
        
        return cell
    }
}


