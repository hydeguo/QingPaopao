//
//  PostDetailController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/9.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import UIKit
import IHKeyboardAvoiding
import PKHUD



class PostDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate,UITextFieldDelegate{
    
    @IBOutlet var keyboardView:UIView?
    @IBOutlet var enterText:UITextField?
    @IBOutlet var tableView:UITableView?
    
    let relayViewHeight:CGFloat = 50.0
    var webCell:WebViewCell?
    var btnCell:PostBtnCell?
    var authorCell:AuthorBlogCell?
    
    var postContent:BlogPostDetail?
    var commentList:[BlogComment] = []
    
    var detailItem: BlogPostItem? {
        didSet {
            self.updatePost()
        }
    }
    var _identifier:Int = 0
    var toCommentId:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorInset = UIEdgeInsets.zero;
        tableView?.layoutMargins = UIEdgeInsets.zero;
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView?.estimatedRowHeight = 200
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        enterText?.delegate = self
        
        KeyboardAvoiding.avoidingView = self.view//logoView
        
        
        var blog_history = [Int]()
        if let _blog_history = UserDefaults.standard.array(forKey: "blog_history")
        {
            blog_history = _blog_history as! [Int]
        }
        if let postId = detailItem?.id
        {
            blog_history.insert( postId , at: 0)
            UserDefaults.standard.set(blog_history, forKey: "blog_history")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onWebLoaded), name: NSNotification.Name(rawValue: "webLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(replyToComment), name: NSNotification.Name(rawValue: "replyToComment"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func onSend()
    {
        UIApplication.shared.keyWindow?.endEditing(true)
        if let content = enterText?.text, content.count > 0
        {
            
            HUD.show(.progress)
            _ = Wolf.request(type: MyAPI.newComment(postId: _identifier, content: content, parent: toCommentId), completion: { (postComment: BlogComment?, msg, code) in
                HUD.hide()
                if postComment != nil {
                    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                    PKHUD.sharedHUD.show()
                    PKHUD.sharedHUD.hide(afterDelay: 1.0) { success in
                        self.navigationController?.popViewController(animated: true)
                    }
                    DispatchQueue.main.async(execute: {
                        self.enterText?.text = "";
                        if(self.toCommentId == 0 ){
                            self.commentList.insert(postComment!, at: 0)
                        }else{
                            for i in 0 ..< self.commentList.count
                            {
                                if self.commentList[i].id == self.toCommentId
                                {
                                    self.commentList.insert(postComment!, at: i + 1)
                                    self.toCommentId = 0
                                    break
                                }
                            }
                        }
                        self.detailItem?.comments += 1
                        self.btnCell?.commentLabel.text = String(self.detailItem?.comments ?? 0)
                        self.tableView?.reloadData()
                    })
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePostData"), object: self, userInfo: ["data":self.detailItem as Any])
                }
            }) { (error) in}
        }
        
    }
    
    @objc func onWebLoaded()
    {
        self.tableView?.reloadData();
    }
    
    @objc func replyToComment(_ notice:Notification)
    {
        if let comment:BlogComment=(notice as NSNotification).userInfo!["comment"] as? BlogComment
        {
          enterText?.text = "@\(comment.author_name ?? "" ) "
            toCommentId = comment.id
        }
        else
        {
            enterText?.text = ""
            toCommentId = 0
        }
        self.enterText?.becomeFirstResponder()
    }
    
    @objc func onReturn()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updatePost() {
        if let postDesc = self.detailItem  {
            
            _identifier = Int(postDesc.id)
//            Log( postDesc.id  )
//            _ = Wolf.request(type: MyAPI.getBlogPost(id: _identifier), completion: { (postContent: BlogPostDetail?, msg, code) in
//                if postContent != nil {
//                    
//                    self.postContent = postContent
//                    DispatchQueue.main.async(execute: {
//                        self.tableView.reloadData()
//                    })
//                }
//            }) { (error) in}
            
//            if let titleString = self.detailItem?.title {
                self.navigationItem.title = "探索"//titleString//String(htmlEncodedString: titleString);
//            }
            
            _ = Wolf.requestList(type: MyAPI.getBlogPostComments(id: _identifier), completion: { (comments: [BlogComment]?, msg, code) in
                if let _comments = comments {
                    self.commentList = []
                    var subComments:[BlogComment] = []
                    for c in _comments
                    {
                        if  c.parent == 0
                        {
                            self.commentList.append(c)
                        }
                        else
                        {
                            subComments.append(c)
                        }
                    }
                    
                    b:for sc in subComments.reversed()
                    {
                        let _p = sc.parent
                        
                        for i in 0..<self.commentList.count
                        {
                            if self.commentList[i].id == _p
                            {
                                self.commentList.insert(sc, at: i + 1)
                                continue b
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                }
            }) { (error) in}
        }
    }
    
    
    
    
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count + 6
    }
    
     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 1
        {
            return 80
        }
        if indexPath.row == 2
        {
            return webCell?.webHeight ?? 100
        }
        else if indexPath.row == 3
        {

            return 63
        }
        else if indexPath.row == 4
        {
            return 8
        }
        else if indexPath.row == 5
        {
            return 44
        }
        else
        {
            return UITableViewAutomaticDimension
        }


    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(relayViewHeight)
    }
//
//    // todo reload height
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//
//        selectedIndex = indexPath
//        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//
//    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleBlogCell
            cell.configure(self.detailItem!)
            return cell
        }
        else if indexPath.row == 1
        {
            if authorCell == nil{
                let cell = tableView.dequeueReusableCell(withIdentifier: "authorCell", for: indexPath) as! AuthorBlogCell
                cell.configure(self.detailItem!)
                authorCell = cell
            }
            return authorCell!
        }
        else if indexPath.row == 2
        {
            if  webCell == nil //&& self.postContent?.content != nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "webCell", for: indexPath) as! WebViewCell
                cell.configure(content: self.detailItem?.content)
                self.webCell = cell
            }
            return webCell ?? tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
        }
        else if indexPath.row == 3
        {
            if btnCell == nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath) as! PostBtnCell
                if let _data = detailItem
                {
                    cell.configure(_data)
                }
                self.btnCell = cell
            }
            return btnCell!
        }
        else if indexPath.row == 4
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 5
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
            return cell
        }
        else
        {
            let commentData = self.commentList[indexPath.row - 6]
            if commentData.parent != 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "subComment", for: indexPath) as! SubCommentTableViewCell
                let comment = commentData
                cell.configure(comment);
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
                let comment = commentData
                cell.configure(comment);
                return cell
            }
        }
        
    }
    
}



