//
//  MessageViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/11/10.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import Disk

class MessageViewController: UITableViewController {
    
    
    var category = Dictionary<String, AnyObject>()
    var posts = [BlogPostItem]()
    var newMsg:BlogMsgData?
    var cellHeight:CGFloat = 140
    
    var getByUserId:String?

    var newMsgCell:MsgBarCell?
    
    
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
        updateTitle()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTitle()
    }
    
    @objc func updatePostData(_ notice:Notification){
        
        
        if  let blogData:BlogPostItem = (notice as NSNotification).userInfo?["data"] as? BlogPostItem
        {
            for i in 0..<posts.count
            {
                if posts[i].id == blogData.id
                {
                    posts[i] = blogData
                }
            }
            
        }
    }
    
    private func updateTitle()
    {
        
        navigationController?.navigationBar.topItem?.title = Language.getString( "消息")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(topRefreshData),
                                  for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "reloading...")
        tableView.addSubview(refreshControl!)
        
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        
        self.updatePostList()
        
        getNewMsg()
    }
    
    func getNewMsg()  {
        _ = Wolf.request(type: MyAPI.newBlogMessage, completion: { (posts: BlogMsgData?, msg, code) in
            if let _newMsg = posts {
                self.newMsg = _newMsg
                self.newMsgCell?.configure(_newMsg)
                MyProfileViewController.checkNewMsg = nil
            }
        }, failure: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setInitData()
    {
        posts.removeAll()
        do {
        
       
            let retrievedMessage = try Disk.retrieve("sysPostList.json", from: .caches, as: [BlogPostItem].self)
            posts = retrievedMessage
            
        } catch _ as NSError {}
    }
    
    
    func checkRefreshTime()-> Bool
    {
        if let _time = UserDefaults.standard.value(forKey: "refreshTime-sys") as? TimeInterval
        {
            return Date().timeIntervalSince1970 - _time > 1800
        }
        else
        {
            return true
        }
    }
    
    func onReceiveNewData(_ newPosts: [BlogPostItem])
    {
        self.posts = newPosts
        
        DispatchQueue.main.async(execute: {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    
    @objc func topRefreshData() {
        
        updatePostList()
    }
    @objc func updatePostList() {
        if(posts.count==0 || checkRefreshTime()){
            refreshControl?.layoutIfNeeded()
            refreshControl?.beginRefreshing()
            
        }

        self.tableView.backgroundView = nil
        
        _ = Wolf.requestList(type: MyAPI.sysMessage, completion: { (posts: [BlogPostItem]?, msg, code) in
            if let _posts = posts {
                do {
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-sys");
                    try Disk.save(_posts, to: .caches, as: "sysPostList.json")
                } catch _ as NSError {}
                self.onReceiveNewData(_posts)
            }
        }, failure: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SysMsgDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let post = posts[indexPath.row - 3]
                let controller = segue.destination as! PostDetailController
                controller.detailItem = post
                controller.sysMsg = true
                controller.showBackBtn = false
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "collectionDetail" {
            let controller = segue.destination as! MyCommentListController

        }
        else if segue.identifier == "showLikePost" {
            let controller = segue.destination as! PostListViewController
            controller.mode = .likes
        }
        else if segue.identifier == "newCommentDetail" {
            let controller = segue.destination as! NewMsgListController
            controller.newMsg = newMsg
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
        return posts.count + 3
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 58
        }else if indexPath.row == 1{
            return 100
        }else if indexPath.row == 2{
            return 58
        }else {
            return 84
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkNoticeCell", for: indexPath) as! DrinkNoticeCell
            cell.btn?.isOn = switchNotice
            return cell
            
        }
        else if indexPath.row == 1{
            if newMsgCell == nil{
                newMsgCell = tableView.dequeueReusableCell(withIdentifier: "MsgBarCell", for: indexPath) as? MsgBarCell
            }
            newMsgCell?.configure(newMsg)
            return newMsgCell!
            
        }
        else if indexPath.row == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SysLb", for: indexPath)
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SysMsgCell", for: indexPath) as! SysMsgCell
            let post = posts[indexPath.row - 3]
            cell.configure(post);
            
            return cell
        }
    }
    
}


