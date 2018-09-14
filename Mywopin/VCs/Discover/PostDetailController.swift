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



class PostDetailController: UITableViewController,UIWebViewDelegate,UITextFieldDelegate{
    
    @IBOutlet var keyboardView:UIView?
    @IBOutlet var enterText:UITextField?
    
    let relayViewHeight:CGFloat = 50.0
    var webCell:WebViewCell?
    
    var postContent:BlogPostDetail?
    var commentList:[BlogComment] = []
    
    var detailItem: BlogPostItem? {
        didSet {
            self.updatePost()
        }
    }
    var _identifier:Int = 0
    var toCommentId:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.separatorInset = UIEdgeInsets.zero;
        tableView.layoutMargins = UIEdgeInsets.zero;
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        enterText?.delegate = self
        
        KeyboardAvoiding.avoidingView = self.view//logoView
        
        if let keyboardV = keyboardView
        {
            keyboardV.frame = CGRect(x: 0, y: 0, width: view.width, height: relayViewHeight)
            keyboardV.x = 0
            keyboardV.y = view.height - relayViewHeight - (self.navigationController?.navigationBar.frame.size.height ?? 0)  - UIApplication.shared.statusBarFrame.height
            self.view.addSubview(keyboardV)
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
        
    }
    
    @objc func onWebLoaded()
    {
        self.tableView.reloadData();
    }
    
    @objc func replyToComment(_ notice:Notification)
    {
        if let comment:BlogComment=(notice as NSNotification).userInfo!["comment"] as? BlogComment
        {
          enterText?.text = "@\(comment.author_name ?? "" )"
            toCommentId = comment.id
        }
        else
        {
            enterText?.text = ""
            toCommentId = -1
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
            
            if let titleString = self.detailItem?.title {
                self.navigationItem.title = titleString//String(htmlEncodedString: titleString);
            }
            
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
                                self.commentList.insert(sc, at: i)
                                continue b
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }) { (error) in}
        }
    }
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count + 4
    }
    
    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0
        {
            return webCell?.webHeight ?? 100
        }
        else if indexPath.row == 1
        {

            return 63
        }
        else if indexPath.row == 2
        {
            return 8
        }
        else if indexPath.row == 3
        {
            return 44
        }
        else
        {
            return UITableViewAutomaticDimension
        }


    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            if  webCell == nil //&& self.postContent?.content != nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "webCell", for: indexPath) as! WebViewCell
                cell.configure(content: self.detailItem?.content)
                self.webCell = cell
            }
            return webCell ?? tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath) as! PostBtnCell
            if let _data = detailItem
            {
                cell.configure(_data)
            }
            return cell
        }
        else if indexPath.row == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
            return cell
        }
        else
        {
            let commentData = self.commentList[indexPath.row - 4]
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



