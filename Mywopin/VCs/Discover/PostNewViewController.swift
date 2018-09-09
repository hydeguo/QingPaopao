//
//  PostNewViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/5.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation



import Foundation
import UIKit



class PostNewViewController: UIViewController,UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    
    var postContent:String?
    

    var _identifier:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add the displayModeButtonItem in the navigation bar of the detail view controller (visible on iPad in portrait mode)
        webView.delegate = self
        //        self.webView.scalesPageToFit = true
        //        self.webView.contentMode = .scaleAspectFit
//        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
//        self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
//        if let postNewContent = UserDefaults.standard.value(forKey: "postNewContent") as? String
//        {
//            self.postContent = postNewContent
//            self.updateWebView()
//        }
//        else
//        {
            WordPressWebServices.sharedInstance.postNew(completionHandler: { (postContent, error) -> Void in
                if postContent != nil {
                    self.postContent = postContent
                    if postContent?.contains("密码") != true  {
                        UserDefaults.standard.set(postContent, forKey: "postNewContent")
                    }
                    DispatchQueue.main.async(execute: { // access to UI in the main thread
                        self.updateWebView()
                    })
                }
            })
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
    

    
    func updateWebView() {
        if let contentString = self.postContent {
            
//            let htmls = """
//            <html> \n\
//            <head> \n\
//            <style type="text/css"> \n\
//            //body {font-size:15px;}\n\
//            img{\n\
//            //border: 4px solid #fff;\n\
//            border-radius: 10px;\n\
//            }\n\
//            </style> \n\
//            </head> \n\
//            <body>\
//            \(contentString)
//            <script type='text/javascript'>\
//            document.getElementsByTagId('adminmenumain').style.display="none";\n\
//            document.getElementsByTagId('wpadminbar').style.display="none";\n\
//            document.getElementsByTagId('minor-publishing').style.display="none";\n\
//            document.getElementsByTagId('formatdiv').style.display="none";\n\
//            document.getElementsByTagId('categorydiv').style.display="none";\n\
//            document.getElementsByTagId('tagsdiv-post_tag').style.display="none";\n\
//            document.getElementsByTagId('sharing_meta').style.display="none";\n\
//            document.getElementsByTagId('tagsdiv-post_tag').style.display="none";\n\
//            
//            
//            </script>\
//            </body>\
//            </html>
//            """
            webView.loadHTMLString(contentString, baseURL: nil)
        }
        self.navigationItem.title = "发布"
        
    }
    
}



