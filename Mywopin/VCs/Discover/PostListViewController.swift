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
//    case likes = "likes"
    case following = "following"
    case my = "my"
    case someOne = "someOne"
    case search = "search"
}

class PostListViewController: UITableViewController {
    
    @IBOutlet var emptyView:UIView?
    
    var numPrePage = 20
    var curPage = 1
    
    var category = Dictionary<String, AnyObject>()
    var posts = [BlogPostItem]()
    var cellHeight:CGFloat = 140
    
    var mode:POST_MODE = .hot
    var searchText:String = ""
    
    var getByUserId:String?
    
    var loadingMore = false
    var isEnd = false
    
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
    
    private func updateTitle()
    {
        switch mode {
        case .history:
            navigationController?.navigationBar.topItem?.title = Language.getString( "浏览历史")
        case .following:
            navigationController?.navigationBar.topItem?.title = Language.getString( "关注话题")
        case .collect:
            navigationController?.navigationBar.topItem?.title = Language.getString( "我的收藏")
        case .someOne:
            navigationController?.navigationBar.topItem?.title = Language.getString( "话题列表")
        default:
            navigationController?.navigationBar.topItem?.title = Language.getString( "探索")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(topRefreshData),
                                  for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "reloading...")
        tableView.addSubview(refreshControl!)
        
        curPage = 1
        isEnd = false
        loadingMore = false
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
            else if mode == .following
            {
                let retrievedMessage = try Disk.retrieve("followingsPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            else if mode == .my
            {
                let retrievedMessage = try Disk.retrieve("myPostList.json", from: .caches, as: [BlogPostItem].self)
                posts = retrievedMessage
            }
            
            if posts.count != 0 && posts.count != numPrePage{
                self.isEnd = true
            }
            
        } catch _ as NSError {}
    }
    
    
    func changeMode(mode:POST_MODE)
    {
        if self.mode != mode || mode == .search
        {
            curPage = 1
            loadingMore = false
            isEnd = false
            self.mode = mode
            self.refreshControl?.endRefreshing()
            setInitData()
            self.tableView.reloadData()
            if checkRefreshTime(mode: self.mode){
                self.updatePostList()
            }
        }
    }
    
    func checkRefreshTime(mode:POST_MODE)-> Bool
    {
        if let _time = UserDefaults.standard.value(forKey: "refreshTime-\(mode.rawValue)") as? TimeInterval
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
        if newPosts.count != numPrePage{
            self.isEnd = true
        }
        if loadingMore == true{
            self.posts.append(contentsOf:newPosts)
            loadingMore = false
        }else{
            self.posts = newPosts
        }
        
        DispatchQueue.main.async(execute: {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    @objc func topRefreshData() {
        
        curPage = 1
        loadingMore = false
        isEnd = false
        updatePostList()
    }
    @objc func updatePostList() {
        if(posts.count==0 || checkRefreshTime(mode: self.mode)){
            refreshControl?.layoutIfNeeded()
            refreshControl?.beginRefreshing()
            
        }
        if loadingMore == true
        {
            curPage = 1 + (posts.count / numPrePage)
        }
        
        self.tableView.backgroundView = nil
        
        if mode == .new
        {
            _ = Wolf.requestList(type: MyAPI.getLastBlogPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .new
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "PostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .hot
        {
            _ = Wolf.requestList(type: MyAPI.getHotBlogPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    
                    if self.mode == .hot
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "hotPostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .history
        {
            _ = Wolf.requestList(type: MyAPI.getHistoryBlogPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .history
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "historyPostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .collect
        {
            _ = Wolf.requestList(type: MyAPI.getColletionPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .collect
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "collectPostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .following
        {
            _ = Wolf.requestList(type: MyAPI.getFollowingBlogPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .following
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "followingPostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .my
        {
            _ = Wolf.requestList(type: MyAPI.getMyBlogPostList(page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .my
                    {
                        do {
                            if self.curPage == 1 {
                                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshTime-\(self.mode.rawValue)");
                                try Disk.save(_posts, to: .caches, as: "myPostList.json")
                            }
                        } catch _ as NSError {}
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .someOne
        {
            _ = Wolf.requestList(type: MyAPI.getOthersBlogPostList(userId: getByUserId ?? "",page: curPage, num: numPrePage), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    
                    if self.mode == .someOne
                    {
                        self.onReceiveNewData(_posts)
                    }
                }
            }, failure: nil)
        }
        else if mode == .search
        {
            _ = Wolf.requestList(type: MyAPI.searchBlogPostList(search: searchText), completion: { (posts: [BlogPostItem]?, msg, code) in
                if let _posts = posts {
                    if self.mode == .search
                    {
                        self.onReceiveNewData(_posts)
                        if _posts.count == 0
                        {
                            self.tableView.backgroundView = self.emptyView
                        }
                    }
                }
            }, failure: nil)
        }
    }
    
    
    func loadMore()
    {
        if(!loadingMore && !isEnd){
            loadingMore = true
            self.updatePostList()
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            
            let post  = self.posts.remove(at: indexPath.row);
            do {
                try Disk.save(self.posts, to: .caches, as: "myPostList.json")
            } catch _ as NSError {}
            _ = Wolf.request(type: MyAPI.deleteMyPost(id: post.id), completion: { (posts: BaseReponse?, msg, code) in
            }, failure: nil)
            
            self.tableView.reloadData()
        }
        
//        let share = UITableViewRowAction(style: .normal, title: "Disable") { (action, indexPath) in
//            // share item at indexPath
//        }
//        share.backgroundColor = UIColor.blue
        if mode == .my{
            return [delete]
        }else{
            return []
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEnd || posts.count == 0 ?  posts.count : posts.count + 1
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == posts.count{
            return 60
        }else{
            return cellHeight
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == posts.count{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            loadMore()
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Post", for: indexPath) as! PostTableViewCell
            let post = posts[indexPath.row]
            cell.configureWithPostDictionary(post);
            
            return cell
        }
    }
    
}


