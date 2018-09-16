//
//  MyProfileViewController
//  Mywopin
//
//  Created by Hydeguo on 2018/6/3.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit
import Disk
import PKHUD

enum POST_MODE:String {
    
    case history = "history"
    case new = "new"
    case hot = "hot"
    case collect = "collect"
    case likes = "likes"
}

class PostListViewController: UITableViewController {
    
    var category = Dictionary<String, AnyObject>()
    var posts = [BlogPostItem]()
    var cellHeight:CGFloat = 140
    
    var mode:POST_MODE = .hot
    
    
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
        case .history:
            navigationController?.navigationBar.topItem?.title = Language.getString( "浏览历史")
        case .likes:
            navigationController?.navigationBar.topItem?.title = Language.getString( "关注话题")
        case .collect:
            navigationController?.navigationBar.topItem?.title = Language.getString( "我的收藏")
        default:
            navigationController?.navigationBar.topItem?.title = Language.getString( "探索")
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
        
    }
    
    func setInitData()
    {
        posts.removeAll()
        do {
            if mode == .new
            {
                let retrievedMessage = try Disk.retrieve("PostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            else if mode == .history
            {
                let retrievedMessage = try Disk.retrieve("historyPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            else if mode == .hot
            {
                let retrievedMessage = try Disk.retrieve("hotPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            else if mode == .collect
            {
                let retrievedMessage = try Disk.retrieve("collectPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            else if mode == .likes
            {
                let retrievedMessage = try Disk.retrieve("likesPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            
        } catch _ as NSError {}
    }
    
    
    func changeMode(mode:POST_MODE)
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
        if(posts.count==0){
            refreshControl?.beginRefreshing()
        }
        if mode == .new
        {
            _ = Wolf.requestList(type: MyAPI.getLastBlogPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    self.posts = _posts
                    
                    do {
                        try Disk.save(self.posts, to: .caches, as: "PostList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
        else if mode == .hot
        {
            _ = Wolf.requestList(type: MyAPI.getHotBlogPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    self.posts = _posts
                    
                    do {
                        try Disk.save(self.posts, to: .caches, as: "hotPostList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        HUD.hide()
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
        else if mode == .history
        {
            _ = Wolf.requestList(type: MyAPI.getHistoryBlogPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    self.posts = _posts
                    
                    do {
                        try Disk.save(self.posts, to: .caches, as: "historyPostList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        HUD.hide()
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
        else if mode == .collect
        {
            _ = Wolf.requestList(type: MyAPI.getColletionPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    self.posts = _posts
                    
                    do {
                        try Disk.save(self.posts, to: .caches, as: "collectPostList.json")
                    } catch _ as NSError {}
                    
                    DispatchQueue.main.async(execute: {
                        HUD.hide()
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
            }, failure: nil)
        }
        else if mode == .likes
        {
            _ = Wolf.requestList(type: MyAPI.getLikedPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    self.posts = _posts
                    
                    do {
                        try Disk.save(self.posts, to: .caches, as: "likesPostList.json")
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
                let post = posts[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PostDetailController
                controller.detailItem = post
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
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
        return posts.count
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Post", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configureWithPostDictionary(post);
        
        return cell
    }
    
}


