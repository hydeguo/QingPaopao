//
//  BlogMsgCells.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/11/10.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import UserNotifications


class CommentMsgCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var commentLabel: UILabel?
    @IBOutlet weak var authorImageView: UIImageView?
    @IBOutlet weak var postTitle: UILabel?
    @IBOutlet weak var postImageView: UIImageView?
    
    
    @IBOutlet weak var readLabel: UILabel?
    @IBOutlet weak var commentCountLabel: UILabel?
    
    @IBOutlet weak var replyBtn: UIButton?
    @IBOutlet weak var deleteBtn: UIButton?

    func configure (_ comment:BlogComment) {
        self.dateLabel?.text = "";
        
        if let dateStringFull = comment.date {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
            
            let time = dateFormatterGet.date(from: dateStringFull)!//2017-08-28T08:24:37.783Z
            let timeText = dateFormatter.string(from: time)
            
            self.dateLabel?.text = timeText
        }
        
        replyBtn?.layer.cornerRadius = 13;
        replyBtn?.layer.masksToBounds = true;
        replyBtn?.layer.borderColor = UIColor.darkGray.cgColor
        replyBtn?.layer.borderWidth = 1;
        
        deleteBtn?.layer.cornerRadius = 13;
        deleteBtn?.layer.masksToBounds = true;
        deleteBtn?.layer.borderColor = UIColor.darkGray.cgColor
        deleteBtn?.layer.borderWidth = 1;
        
        self.authorLabel?.text = comment.author_name
        self.authorImageView?.image(fromUrl: comment.avatar_URL ?? "")
        self.commentLabel?.text = comment.content?.htmlToString
        
        
    }
    
    func configurePost (_ post:BlogPostItem) {
    
        postTitle?.text = post.title
        postImageView?.image(fromUrl: post.featured_image ?? "")
        
        readLabel?.text = Language.getString("阅读 \(post.read)")
        commentCountLabel?.text = Language.getString("评论 \(post.comments)")
    }
}

class ReplyCommentMsgCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel?
    
    func configure (_ comment:BlogComment) {

        self.commentLabel?.text = comment.content?.htmlToString
        
    }
    
}

class NewCommentMsgCell: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var authorImageView: UIImageView?
    @IBOutlet weak var contentLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var postImageView: UIImageView?
    
    func configure (_ comment:NewCommentMsg) {

        
        self.authorLabel?.text = comment.author_name
        self.authorImageView?.image(fromUrl: comment.avatar_URL ?? "" )
        self.contentLabel?.text = comment.content?.htmlToString
        self.postImageView?.image(fromUrl: comment.postThumbnail ?? "" )
        
        self.dateLabel?.text = "";
        
        if let dateStringFull = comment.date {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
            
            let time = dateFormatterGet.date(from: dateStringFull)!//2017-08-28T08:24:37.783Z
            let timeText = dateFormatter.string(from: time)
            
            self.dateLabel?.text = timeText
        }
    }
}

class MsgBarCell: UITableViewCell {
    
    @IBOutlet weak var commentBtn: UIButton?
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var colectionBtn: UIButton?
    
    @IBOutlet weak var commentNum: UILabel?
    @IBOutlet weak var likeNum: UILabel?
    @IBOutlet weak var colectionNum: UILabel?
    
    func configure (_ voData:BlogMsgData?) {
        if let vo = voData
        {
            commentNum?.isHidden = vo.newComment.count == 0
            likeNum?.isHidden = true
            colectionNum?.isHidden = true
            
            commentNum?.text = String(vo.newComment.count)
            
        }
        else
        {
            commentNum?.isHidden = true
            likeNum?.isHidden = true
            colectionNum?.isHidden = true
        }
    }
    
}

class DrinkNoticeCell: UITableViewCell {
    
    @IBOutlet weak var btn: UISwitch?
    
    @IBAction func clickBtn(_ mySwitch:UISwitch){
        let value = mySwitch.isOn
        switchNotice = value
        UserDefaults.standard.set(switchNotice, forKey: "\(idStr) notice")
        if(switchNotice){
            NoticeController().createLocalNotice()
        }else{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
}

class SysMsgCell: UITableViewCell {
    
//    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var postTitle: UILabel?
    @IBOutlet weak var SubTitle: UILabel?
    @IBOutlet weak var postImageView: UIImageView?
    
    func configure (_ vo:BlogPostItem) {
        
        postTitle?.text = vo.title
        SubTitle?.attributedText = NSAttributedString(html: vo.content ?? "")
        
        if let url = vo.featured_image
        {
            postImageView?.image(fromUrl: url)
        }
        else
        {
            postImageView?.image = UIImage()
        }
    }
}

extension NSAttributedString {
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            // not sure which is more reliable: String.Encoding.utf16 or String.Encoding.unicode
            return nil
        }
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}
