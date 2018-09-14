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
        
    }
    
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
            _ = Wolf.request(type: MyAPI.likeBlogComment(id: comment?.id ?? 0), completion: { (user: User?, msg, code) in
                if user != nil {
                    myClientVo = user;
                    self.likeBtn?.isSelected = false
                }
            }) { (error) in}
        }
        else
        {
            _ = Wolf.request(type: MyAPI.unLikeBlogComment(id: comment?.id ?? 0), completion: { (user: User?, msg, code) in
                if user != nil {
                    myClientVo = user;
                    self.likeBtn?.isSelected = true
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
        PostListViewController.updateFlag = true
        if starBtn.isSelected == true
        {
            _ = Wolf.request(type: MyAPI.unCollectBlogPost(id: postData?.id ?? 0), completion: { (user: User?, msg, code) in
                if user != nil {
                    myClientVo = user;
                    self.postData?.stars -= 1
                    self.starBtn.isSelected = false
                }
            }) { (error) in}
        }
        else
        {
            _ = Wolf.request(type: MyAPI.collectBlogPost(id: postData?.id ?? 0), completion: { (user: User?, msg, code) in
                if user != nil {
                    myClientVo = user;
                    self.postData?.stars += 1
                    self.starBtn.isSelected = true
                }
            }) { (error) in}
        }
        
    }
    @IBAction func onLike(_ btn:UIButton)
    {
        if (postData == nil) {
            return
        }
        PostListViewController.updateFlag = true
        if likeBtn.isSelected == true
        {
            _ = Wolf.request(type: MyAPI.unLikeBlogPost(id: postData?.id ?? 0), completion: { (res: BaseReponse?, msg, code) in
                if code == "0" {
                    self.likeBtn.isSelected = false
                    self.postData?.likes -= 1
                    self.likeLabel.text = String(self.postData?.likes ?? 0 )
                }
            }) { (error) in}
        }
        else
        {
            _ = Wolf.request(type: MyAPI.likeBlogPost(id: postData?.id ?? 0), completion: { (res: BaseReponse?, msg, code) in
                if code == "0" {
                    self.likeBtn.isSelected = true
                    self.postData?.likes += 1
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
            Log(contentString)
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
            Log(height)
            webView.frame = CGRect.init(x: 10, y: 0, width: SCREEN_WIDTH - 20, height: height)
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "webLoaded"), object: self, userInfo: nil)
        })
    }
}
