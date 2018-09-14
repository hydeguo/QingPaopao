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


class PostListViewController: UITableViewController {
    
    static var updateFlag:Bool = false;
    var category = Dictionary<String, AnyObject>()
    var posts = [BlogPostItem]()
    var cellHeight:CGFloat = 140
    
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
        if PostListViewController.updateFlag == true{
            PostListViewController.updateFlag = false;
            self.updatePostList()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let retrievedMessage = try Disk.retrieve("PostList.json", from: .caches, as: [BlogPostItem].self)
            posts = retrievedMessage
        } catch _ as NSError {}
        
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(updatePostList),
                                  for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "reloading...")
        tableView.addSubview(refreshControl!)
        
        self.updatePostList()
    }
    
    func changeType(type:Int)
    {
        
    }
    
    @objc func updatePostList() {
        if(posts.count==0){
            HUD.show(.progress)
        }
        _ = Wolf.requestList(type: MyAPI.getBlogPostList(page: 1, num: 20), completion: { (posts: [BlogPostItem]?, msg, code) in
            if let _posts = posts {
                self.posts = _posts
                
                do {
                    try Disk.save(self.posts, to: .caches, as: "PostList.json")
                } catch _ as NSError {}
                
                DispatchQueue.main.async(execute: {
                    HUD.hide()
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                })
            }
        }, failure: nil)
        
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


