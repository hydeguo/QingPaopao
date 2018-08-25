//
//  InfosViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit

class InfosViewController: UIViewController {

    @IBOutlet var topView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer(view: self.topView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

