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
    
    func configureWithPostDictionary (_ post:PostItem) {
        
        postIdentifier = post.ID
        let title = post.title
        self.titleLabel!.text = title//String(htmlEncodedString: title!)
        
        self.dateLabel!.text = nil;
        
        if let dateStringFull = post.date {
            // date is in the format "2016-01-29T01:45:33+02:00",
            let dateString = String(dateStringFull[dateStringFull.startIndex..<dateStringFull.index(dateStringFull.startIndex, offsetBy: 19)])
            
            let parsingDateFormatter = DateFormatter()        // TODO: a static var
            parsingDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = parsingDateFormatter.date(from: dateString)
            
            let printingDateFormatter = DateFormatter()       // TODO: a static var
            printingDateFormatter.dateStyle = .long
            printingDateFormatter.timeStyle = .none
            
            self.dateLabel!.text = printingDateFormatter.string(from: date!)
        }
        
        self.featuredImageView!.image = nil;
        self.featuredImageView.image(fromUrl: post.featured_image ?? "")
        
        self.authorLabel.text = post.author?.nice_name
        self.authorImageView.image(fromUrl: post.author?.avatar_URL ?? "")
        
        
        _ = Wolf.request(type: MyAPI.getBlogPostData(id: postIdentifier), completion: { (postData: BaseBlogPost?, msg, code) in
            if(code == "0" )
            {
                self.likeLabel?.text = String(postData?.likes?.count ?? 0)
                self.starLabel?.text = String(postData?.collect?.count ?? 0)
                self.commentLabel?.text = String(postData?.comments ?? 0)
            }
            else
            {
                self.likeLabel?.text = "0"
                self.starLabel?.text = "0"
                self.commentLabel?.text = "0"
            }
        }) { (error) in
        }
        
    }
    
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var commentBtn: UIButton?
    @IBOutlet weak var commentLabel: UILabel?
    
    var commentIdentifier:Int = 0
    
    func configure (_ comment:CommentItem) {
        
        commentIdentifier = comment.ID
        
        self.dateLabel!.text = "";
        
        if let dateStringFull = comment.date {
            // date is in the format "2016-01-29T01:45:33+02:00",
            let dateString = String(dateStringFull[dateStringFull.startIndex..<dateStringFull.index(dateStringFull.startIndex, offsetBy: 19)])
            
            let parsingDateFormatter = DateFormatter()        // TODO: a static var
            parsingDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = parsingDateFormatter.date(from: dateString)
            
            let printingDateFormatter = DateFormatter()       // TODO: a static var
            printingDateFormatter.dateStyle = .long
            printingDateFormatter.timeStyle = .none
            
            self.dateLabel!.text = printingDateFormatter.string(from: date!)
        }
        
        self.authorLabel.text = comment.author?.nice_name
        self.authorImageView.image(fromUrl: comment.author?.avatar_URL ?? "")
        self.commentLabel?.text = comment.content ?? ""
        
        _ = Wolf.request(type: MyAPI.getBlogCommentData(id: commentIdentifier), completion: { (info: BaseBlogComment?, msg, code) in
            if let commentData = info
            {
                if commentData.likes?.contains(myClientVo!._id) == true
                {
                    DispatchQueue.main.async(execute: {
                        self.likeBtn?.isSelected = true
                    })
                }
            }
        }) { (error) in
        }
    }
}


class SubCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel?
    
    
    func configure (_ comment:CommentItem) {
        commentLabel?.text = comment.content ?? ""
    }
    
}
class BaseBlogCell: UITableViewCell {
   
}
class PostBtnCell: UITableViewCell {
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    
    @IBAction func onCollect(_ btn:UIButton)
    {
        
    }
    @IBAction func onLike(_ btn:UIButton)
    {
        
    }
    @IBAction func onComment(_ btn:UIButton)
    {
        
    }
    @IBAction func onShare(_ btn:UIButton)
    {
        
    }
}
class WebViewCell: UITableViewCell ,UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    
    
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
            Log(height)
            webView.frame = CGRect.init(x: 10, y: 0, width: SCREEN_WIDTH - 20, height: height)
        })
    }
}
