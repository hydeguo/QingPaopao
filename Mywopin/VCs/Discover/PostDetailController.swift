//
//  PostDetailController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/9.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import UIKit



class PostDetailController: UITableViewController,UIWebViewDelegate{
    

    var webCell:WebViewCell?
    
    var postContent:Dictionary<String, AnyObject> = [:]
    var commentList:[CommentItem] = []
    
    var detailItem: PostItem? {
        didSet {
            self.updatePost()
        }
    }
    var _identifier:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.separatorInset = UIEdgeInsets.zero;
        tableView.layoutMargins = UIEdgeInsets.zero;
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        

    }
    

    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //        self.webView.scrollView.minimumZoomScale = 1.0
        //        self.webView.scrollView.maximumZoomScale = 5.0
        //        self.webView.stringByEvaluatingJavaScript(from: "document.querySelector('meta[name=viewport]').setAttribute('content', 'user-scalable = 1;', false); ")
    }
    
    @objc func onReturn()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updatePost() {
        if let postDesc = self.detailItem  {
            
            _identifier = postDesc.ID
            Log( postDesc.ID  )
            WordPressWebServices.sharedInstance.postByIdentifier(postDesc.ID, completionHandler: { (postContent, error) -> Void in
                if postContent != nil {
                    
                    self.postContent = postContent!
                    DispatchQueue.main.async(execute: {
                        if let titleString = self.postContent["title"] as? String {
                            self.navigationItem.title = titleString//String(htmlEncodedString: titleString);
                        }
                        self.tableView.reloadData()
                    })
                }
            })
//            WordPressWebServices.sharedInstance.commentsByPost(id: _identifier, page: 1, number: 20) { (comments, err) in
//                if let _comments = comments {
//                    self.commentList = []
//                    var subComments:[CommentItem] = []
//                    for c in _comments
//                    {
//                        if  c.parent == nil
//                        {
//                            self.commentList.append(c)
//                        }
//                        else
//                        {
//                            subComments.append(c)
//                        }
//                    }
//                    
//                    b:for sc in subComments.reversed()
//                    {
//                        if  let _p = sc.parent
//                        {
//                            for i in 0..<self.commentList.count
//                            {
//                                if self.commentList[i].ID == _p.ID
//                                {
//                                    self.commentList.insert(sc, at: i)
//                                    continue b
//                                }
//                            }
//                        }
//                    }
//                    DispatchQueue.main.async(execute: {
//                        self.tableView.reloadData()
//                    })
//                }
//            }
        }
    }
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count + 4
    }
    
//    override func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        if indexPath.row == 0
//        {
//            return SCREEN_HEIGHT
//        }
//        else if indexPath.row == 1
//        {
//
//            return 63
//        }
//        else if indexPath.row == 2
//        {
//            return 44
//        }
//        else if indexPath.row == 3
//        {
//            return 8
//        }
//        else
//        {
//            return UITableViewAutomaticDimension
//        }
//
//
//    }
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
            if self.postContent["content"] != nil && webCell == nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "webCell", for: indexPath) as! WebViewCell
                cell.configure(content: self.postContent["content"] as? String)
                cell.webView.delegate = self
                webCell = cell
            }
            return webCell ?? tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "separateCell", for: indexPath)
            return cell
        }
        else
        {
            let commentData = self.commentList[indexPath.row - 4]
            if commentData.parent != nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "subComment", for: indexPath) as! SubCommentTableViewCell
                let comment = commentList[indexPath.row]
                cell.configure(comment);
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
                let comment = commentList[indexPath.row]
                cell.configure(comment);
                return cell
            }
        }
        
    }
    
}



