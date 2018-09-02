//
//  DeliverPageVc.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/2.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation

class DeliverPageViewController: UIViewController {
    
    static var url:URL?
    @IBOutlet var web:UIWebView!
    
    
    override func viewDidLoad() {
        if let _url = DeliverPageViewController.url
        {
            web.loadRequest(URLRequest(url: _url))
        }
        
    }


}
