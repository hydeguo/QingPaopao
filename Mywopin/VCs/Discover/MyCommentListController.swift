//
//  MyCommentListController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/11/12.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import Disk
import IHKeyboardAvoiding
import PKHUD


class MyCommentListController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet var keyboardView:UIView?
    @IBOutlet var enterText:UITextField?
    @IBOutlet var tableView:UITableView!
    
    @IBOutlet var emptyView:UIView?
    
    var getByUserId:String?
    
    var myCommentRes:MyCommentRes?
    
    var numPrePage = 20
    var curPage = 1
    
    var curSelectCom:BlogComment?
 
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = ""
        
//        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTitle()
    }
    
    
    private func updateTitle()
    {
        navigationController?.navigationBar.topItem?.title = Language.getString( "我的评论")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterText?.delegate = self
        KeyboardAvoiding.avoidingView = self.view//logoView
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(topRefreshData),
                                  for: .valueChanged)
        tableView.refreshControl!.attributedTitle = NSAttributedString(string: "reloading...")
        tableView.addSubview(tableView.refreshControl!)
        loadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func onSend()
    {
        UIApplication.shared.keyWindow?.endEditing(true)
        if let content = enterText?.text, content.count > 0, let curCom = curSelectCom
        {
            
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.newComment(postId: curCom.post, content: content, parent: 0), completion: { (postComment: BlogComment?, msg, code) in
                HUD.hide()
                self.enterText?.text = ""
                if postComment != nil {
                    self.loadData()
                    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                    PKHUD.sharedHUD.show()
                    PKHUD.sharedHUD.hide(afterDelay: 1.0) { success in
                        
                    }
                }
            }) { (error) in}
        }
        
    }
    
    @objc func topRefreshData() {
        
        loadData()
    }
    
    func loadData(){
        
        tableView.refreshControl?.layoutIfNeeded()
        tableView.refreshControl?.beginRefreshing()
        
        _ = Wolf.request(type: MyAPI.getMyCommentList(page: curPage, num: numPrePage), completion: { (coms: MyCommentRes?, msg, code) in
            
            
            if let _coms = coms  {
                self.myCommentRes = _coms
            }
            self.sortComment()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
            if self.myCommentRes?.comments.count == 0
            {
                self.tableView.backgroundView = self.emptyView
            }
            
        }, failure: nil)
    }
    
    func loadMore(){
        
        tableView.refreshControl?.layoutIfNeeded()
        tableView.refreshControl?.beginRefreshing()
        
        _ = Wolf.request(type: MyAPI.getMyCommentList(page: curPage, num: numPrePage), completion: { (coms: MyCommentRes?, msg, code) in
            
            if let _coms = coms  {
                self.myCommentRes?.comments += _coms.comments
                self.myCommentRes?.relatedPosts += _coms.relatedPosts
            }
            self.sortComment()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }, failure: nil)
    }
    
    func sortComment()
    {
        if (self.myCommentRes?.comments) != nil {
            var commentList:[BlogComment] = self.myCommentRes?.comments ?? []
            let subComments:[BlogComment] = self.myCommentRes?.commentsReplyMe ?? []
            
            for  item in subComments
            {
                let _p = item.parent
                
                for i in 0..<commentList.count
                {
                    if commentList[i].id == _p
                    {
                        commentList.insert(item, at: i + 1)
                    }
                }
            }
            self.myCommentRes?.comments = commentList
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let myComments = myCommentRes?.comments
        {
            if indexPath.row == myComments.count - 1 {
                if myComments.count % numPrePage == 0
                {
                    self.curPage += 1
                    self.loadMore()
                }
            }
        }
        
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        return []
        
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myCommentRes?.comments.count ?? 0
    }
    
     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let curComData = myCommentRes?.comments[indexPath.row]
        if curComData?.parent != 0 && myCommentRes!.commentsReplyMe.contains(where: { (com) -> Bool in
            return com.id == curComData?.id
        }){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCommentMsgCell", for: indexPath) as! ReplyCommentMsgCell
            cell.commentLabel?.text = Language.getString("回复:") + (curComData?.content?.htmlToString ?? "")
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentMsgCell", for: indexPath) as! CommentMsgCell
            cell.configure(curComData!)
            for item in myCommentRes!.relatedPosts {
                if(item.id == curComData?.post){
                    cell.configurePost(item)
                }
            }
            cell.deleteBtn?.tag = indexPath.row
            cell.deleteBtn?.addTarget(self, action: #selector(deleteComment), for: .touchUpInside)
            cell.replyBtn?.tag = indexPath.row
            cell.replyBtn?.addTarget(self, action: #selector(replyPost), for: .touchUpInside)
            return cell
        }
    }
    
    
    @objc func replyPost(_ btn : UIButton){
        
        if let myComments = myCommentRes?.comments
        {
            if( btn.tag < myComments.count){
                self.curSelectCom = myComments[btn.tag]
                self.enterText?.becomeFirstResponder()
            }
        }
      
    }
    
    
    @objc func deleteComment(_ btn : UIButton){
        
        if let myComments = myCommentRes?.comments
        {
            if( btn.tag < myComments.count){
                let comment = myComments[btn.tag]
                _ = Wolf.request(type: MyAPI.deleteMyComment(id: comment.id), completion: { (posts: BaseReponse?, msg, code) in
                }, failure: nil)
                
                myCommentRes?.comments.remove(at: btn.tag)
                
                self.tableView.reloadData()
            }
        }
        
    }
    
}


