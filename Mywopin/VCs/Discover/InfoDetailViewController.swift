//
//  InfoDetailViewController.swift
//  Mywopin
//
//  Created by GuoXiaobin on 5/6/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit



class InfoDetailViewController: UIViewController,UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    
    var postContent:Dictionary<String, AnyObject>? = [:]
    
    var detailItem: PostItem? {
        didSet {
            self.updatePost()
        }
    }
    var _identifier:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add the displayModeButtonItem in the navigation bar of the detail view controller (visible on iPad in portrait mode)
        webView.delegate = self
//        self.webView.scalesPageToFit = true
//        self.webView.contentMode = .scaleAspectFit
        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        
        //-----------------------temp----------------------
        if(_identifier == 56){
            webView.loadRequest(URLRequest(url: URL(string:"http://url.cn/5bMMFrg")!))
        }else if(_identifier == 43){
            webView.loadRequest(URLRequest(url: URL(string:"http://url.cn/5I49MBy")!))
        }else if(_identifier == 1){
            webView.loadRequest(URLRequest(url: URL(string: "http://url.cn/5WQEb6T")!))
        }else if(_identifier == 78){
            webView.loadRequest(URLRequest(url: URL(string: "http://url.cn/5EzNsV3")!))
        }else if(_identifier == 82){
            webView.loadRequest(URLRequest(url: URL(string: "http://url.cn/5f1JsDp")!))
        }
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
//            WordPressWebServices.sharedInstance.postByIdentifier(postDesc.ID, completionHandler: { (postContent, error) -> Void in
//                if postContent != nil {
//                    self.postContent = postContent
//                    DispatchQueue.main.async(execute: { // access to UI in the main thread
//                        self.updateWebView()
//                    })
//                }
//            })
            
        }
        
    }
    
    func updateWebView() {
        if let contentString = self.postContent!["content"] as? String {
          
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
            webView.loadHTMLString(htmls, baseURL: nil)
        }
        if let titleString = self.postContent!["title"] as? String {
                self.navigationItem.title = titleString//String(htmlEncodedString: titleString);
        }
        
    }
    
}



