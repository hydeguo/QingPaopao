//
//  BlogCells.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/9.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel?
    @IBOutlet weak var starLabel: UILabel?
    @IBOutlet weak var commentLabel: UILabel?
    
    
    var postIdentifier:Int = 0
    var imageRequestedForIdentifier:Int = 0
    
    func configureWithPostDictionary (_ post:BlogPostItem) {
        
        postIdentifier = Int(post.id)
        let title = post.title
        self.titleLabel!.text = title//String(htmlEncodedString: title!)
        
        self.dateLabel!.text = nil;
        
        if let dateStringFull = post.date {
            // date is in the format "2016-01-29T01:45:33+02:00",
//            let dateString = String(dateStringFull[dateStringFull.startIndex..<dateStringFull.index(dateStringFull.startIndex, offsetBy: 19)])

            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"//"MMM dd,yyyy,hh:mm:ss"
            
            let time = dateFormatterGet.date(from: dateStringFull)!//2017-08-28T08:24:37.783Z
            let timeText = dateFormatter.string(from: time)
            
            self.dateLabel!.text = timeText
        }
        
        self.featuredImageView!.image = nil;
        self.featuredImageView.image(fromUrl: post.featured_image ?? "")
        
        self.authorLabel.text = post.author?.name
        self.authorImageView.image(fromUrl: post.author?.avatar_URL ?? "")
        
        self.likeLabel?.text = String(post.likes)
        self.starLabel?.text = String(post.stars)
        self.commentLabel?.text = String(post.comments)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePostData), name: NSNotification.Name(rawValue: "updatePostData"), object: nil)
    }
    
    @objc func updatePostData(_ notice:Notification){
        
        if  let star:Int = (notice as NSNotification).userInfo!["star"] as? Int,let id:Int = (notice as NSNotification).userInfo!["id"] as? Int,let starNum = self.starLabel?.text
        {
            if postIdentifier == id
            {
                DispatchQueue.main.async(execute: {
                    self.starLabel?.text = String((Int(starNum) ?? 0) + star)
                })
            }
        }
        if  let like:Int = (notice as NSNotification).userInfo!["like"] as? Int,let id:Int = (notice as NSNotification).userInfo!["id"] as? Int,let likeNum = self.likeLabel?.text
        {
            if postIdentifier == id
            {
                DispatchQueue.main.async(execute: {
                    self.likeLabel?.text = String((Int(likeNum) ?? 0 ) + like)
                })
            }
        }
        if  let like:Int = (notice as NSNotification).userInfo!["comment"] as? Int,let id:Int = (notice as NSNotification).userInfo!["id"] as? Int,let commentNum = self.commentLabel?.text
        {
            if postIdentifier == id
            {
                DispatchQueue.main.async(execute: {
                    self.likeLabel?.text = String((Int(commentNum) ?? 0 ) + like)
                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class LoadingTableViewCell: UITableViewCell {
    
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var authorImageView: UIImageView?
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var commentBtn: UIButton?
    @IBOutlet weak var commentLabel: UILabel?
    
    var comment:BlogComment?
    
    func configure (_ comment:BlogComment) {
        
        self.comment = comment
        
        self.dateLabel?.text = "";
        
        if let dateStringFull = comment.date {
            // date is in the format "2016-01-29T01:45:33+02:00",
//            let dateString = String(dateStringFull[dateStringFull.startIndex..<dateStringFull.index(dateStringFull.startIndex, offsetBy: 19)])
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
            
            let time = dateFormatterGet.date(from: dateStringFull)!//2017-08-28T08:24:37.783Z
            let timeText = dateFormatter.string(from: time)
            
            self.dateLabel?.text = timeText
        }
        
        self.authorLabel?.text = comment.author_name
        self.authorImageView?.image(fromUrl: comment.avatar_URL ?? "")
        self.commentLabel?.text = comment.content?.htmlToString
        
        self.likeBtn?.isSelected = comment.myLike
    }
    
    @IBAction func onReply()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "replyToComment"), object: self, userInfo: ["comment":comment ?? -1])
    }
    @IBAction func onLike()
    {
        if (comment == nil) {
            return
        }
        if likeBtn?.isSelected == true
        {
            self.likeBtn?.isSelected = false
            _ = Wolf.request(type: MyAPI.unLikeBlogComment(id: comment?.id ?? 0), completion: { (info: BaseReponse?, msg, code) in
                 if code == "0" {
                    
                }
            }) { (error) in}
        }
        else
        {
            self.likeBtn?.isSelected = true
            _ = Wolf.request(type: MyAPI.likeBlogComment(id: comment?.id ?? 0), completion: { (info: BaseReponse?, msg, code) in
                 if code == "0" {
                    
                }
            }) { (error) in}
        }
    }
}


class SubCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel?
    
    func configure (_ comment:BlogComment) {
        let commentText = "\(comment.author_name ?? ""):\(comment.content?.htmlToString ?? "")"
        setNameMsg(commentText,highLight: comment.author_name ?? "")
        
    }
    
    func setNameMsg(_ msg:String , highLight:String){
     
        let index_s = msg.range(of: highLight)
        let intValue = msg.distance(from: msg.startIndex, to: index_s!.lowerBound)
        let myMutableString = NSMutableAttributedString(string: msg, attributes: [:])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: main_color, range: NSRange(location:intValue,length:highLight.count))
        self.commentLabel?.attributedText = myMutableString
        
    }
    
}
class BaseBlogCell: UITableViewCell {
   
}

class TitleBlogCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel?
    
    func configure (_ post:BlogPostItem) {
        title?.text = post.title
    }
    
}
class AuthorBlogCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var readLabel: UILabel?
    @IBOutlet weak var authorImageView: UIImageView?
    @IBOutlet weak var likeBtn: UIButton?
    var postData:BlogPostItem?
    
    func configure (_ post:BlogPostItem) {
        
        postData = post
        if let dateStringFull = post.date {

            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
            
            let time = dateFormatterGet.date(from: dateStringFull)!//2017-08-28T08:24:37.783Z
            let timeText = dateFormatter.string(from: time)
            
            self.dateLabel?.text = timeText
        }
        readLabel?.text = "阅读 \(post.read)";
        authorLabel?.text = post.author?.name;
        authorImageView?.image(fromUrl: post.author?.avatar_URL ?? "");
        
        
        self.likeBtn?.isHidden = true
        _ = Wolf.request(type: MyAPI.getFollowList(userId: (postData?.author?.id)!), completion: { (res: BlogFollows?, msg, code) in
            self.likeBtn?.isHidden = false
            if (res != nil)  {
                self.likeBtn?.isSelected = res!.follow.contains(myClientVo!._id)
            }else{
                self.likeBtn?.isSelected = false
            }
        }) { (error) in}
    }
    
    @IBAction func onLike(_ btn:UIButton)
    {
   
        if let _userId = postData?.author?.id {
            if likeBtn?.isSelected == true
            {
                self.likeBtn?.isSelected = false
                _ = Wolf.request(type: MyAPI.unFollowAothur(userId: _userId ), completion: { (res: BaseReponse?, msg, code) in
                    if code == "0" {
                    }
                }) { (error) in}
            }
            else
            {
                self.likeBtn?.isSelected = true
                _ = Wolf.request(type: MyAPI.followAothur(userId: _userId), completion: { (res: BaseReponse?, msg, code) in
                    if code == "0" {
                    }
                }) { (error) in}
            }
        }
    }
    
}
class PostBtnCell: UITableViewCell {
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    
    var postData :BlogPostItem?
    
    func configure (_ comment:BlogPostItem) {
        self.postData = comment
        likeBtn.isSelected = comment.myLike
        starBtn.isSelected = comment.myStar
        likeLabel.text = String(comment.likes)
        commentLabel.text = String(comment.comments)
    }
    @IBAction func onCollect(_ btn:UIButton)
    {
        if (postData == nil) {
            return
        }
        
        if starBtn.isSelected == true
        {
            self.postData?.stars -= 1
            self.starBtn.isSelected = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePostData"), object: self, userInfo: ["star":-1,"id":postData?.id ?? 0])
            _ = Wolf.request(type: MyAPI.unCollectBlogPost(id: postData?.id ?? 0), completion: { (info: BaseReponse?, msg, code) in
                if code == "0" {
                }
            }) { (error) in}
        }
        else
        {
            self.postData?.stars += 1
            self.starBtn.isSelected = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePostData"), object: self, userInfo: ["star":1,"id":postData?.id ?? 0])
            _ = Wolf.request(type: MyAPI.doCollectBlogPost(id: postData?.id ?? 0), completion: { (info: BaseReponse?, msg, code) in
                if code == "0" {
                }
            }) { (error) in}
        }
        
    }
    @IBAction func onLike(_ btn:UIButton)
    {
        if (postData == nil) {
            return
        }
        
        if likeBtn.isSelected == true
        {
            self.likeBtn.isSelected = false
            self.postData?.likes -= 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePostData"), object: self, userInfo: ["like":-1,"id":postData?.id ?? 0])
            _ = Wolf.request(type: MyAPI.unLikeBlogPost(id: postData?.id ?? 0), completion: { (res: BaseReponse?, msg, code) in
                if code == "0" {
                    self.likeLabel.text = String(self.postData?.likes ?? 0 )
                }
            }) { (error) in}
        }
        else
        {
            self.likeBtn.isSelected = true
            self.postData?.likes += 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePostData"), object: self, userInfo: ["like":1,"id":postData?.id ?? 0])
            _ = Wolf.request(type: MyAPI.doLikeBlogPost(id: postData?.id ?? 0), completion: { (res: BaseReponse?, msg, code) in
                if code == "0" {
                    self.likeLabel.text = String(self.postData?.likes ?? 0 )
                }
            }) { (error) in}
        }
    }
    @IBAction func onComment(_ btn:UIButton)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "replyToComment"), object: self, userInfo: ["comment":-1])
    }
    @IBAction func onShare(_ btn:UIButton)
    {
        let shareParams: NSMutableDictionary = NSMutableDictionary()
        shareParams.ssdkSetupShareParams(byText: "氢泡泡", images: postData?.featured_image ?? "", url: URL.init(string: postData?.URL ?? ""), title: postData?.title ?? "", type: SSDKContentType.auto)
        
        ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParams) { (state, type, info, entity, error, end) in
            
            if state == SSDKResponseState.success {
                Log("分享成功")
            } else {
                Log("分享失败")
            }
        }
        
    }
}
class WebViewCell: UITableViewCell ,UIWebViewDelegate{
    
    @IBOutlet  var webView: UIWebView!
    var webHeight:CGFloat = 100
    
    func configure(content:String?) {
        if let contentString = content {
            
            let htmls = """
            <html> \n\
            <head> \n\
            <style type="text/css"> \n\
            //body {font-size:15px;}\n\
            img{\n\
            //border: 4px solid #fff;\n\
            border-radius: 10px;\n\
            }\n\
            </style> \n\
            </head> \n\
            <body>\
            \(contentString)
            <script type='text/javascript'>\
            var $img = document.getElementsByTagName('img');\n\
            for(var p in  $img){\n\
            $img[p].style.width = '100%';\n\
            $img[p].style.height ='auto';\n\
            $img[p].sizes="(max-width: 100px) 600w, 100px";\n\
            }\
            </script>\
            </body>\
            </html>
            """
//            Log(contentString)
            self.webView.delegate = self
            self.webView.backgroundColor = UIColor.clear
            self.webView.isOpaque = false
            self.webView.dataDetectorTypes = UIDataDetectorTypes.init(rawValue: 0)
            self.webView.scrollView.isScrollEnabled = false
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.scrollView.showsHorizontalScrollIndicator = false
            self.webView.isUserInteractionEnabled = false
            
            self.webView.loadHTMLString(htmls, baseURL: nil)
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async(execute: {
            webView.sizeToFit()
            let height = webView.bounds.size.height
            self.webHeight = height
            webView.frame = CGRect.init(x: 10, y: 0, width: SCREEN_WIDTH - 20, height: height)
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "webLoaded"), object: self, userInfo: nil)
        })
    }
}
