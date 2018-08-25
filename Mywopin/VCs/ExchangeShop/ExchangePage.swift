//
//  ExchangePage.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/23.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ExchangePage: UIViewController ,UIScrollViewDelegate{
    
    
    @IBOutlet var pageC:UIView!
    
    var scrollSize: CGFloat = 300
    var numberOfPage: Int = 0
    var mainImages:[String] = []
    
    let scrollView = UIScrollView()
    let pageControl1 = FlexiblePageControl()
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Wolf.requestBase(type: WooAPI.getExchangeCategory, completion: { (category: ExchangeCategory?, msg, code) in
            if(code == "0")
            {
                if let _category = category
                {
                    self.mainImages = _category.description.components(separatedBy: ";")
                    self.numberOfPage = self.mainImages.count
                    self.createImages()
                }
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
       
    }
    
    
    func createImages()
    {
        scrollSize = SCREEN_WIDTH
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollSize, height: pageC.height)
        //        scrollView.center = pageC.center
        
        scrollView.contentSize = CGSize(width: scrollSize * CGFloat(numberOfPage), height: pageC.height)
        scrollView.isPagingEnabled = true
        
        pageControl1.center = CGPoint(x: scrollView.center.x, y: scrollView.frame.maxY - 16)
        pageControl1.numberOfPages = numberOfPage
        
        
        for index in  0..<numberOfPage {
            let view = UIImageView(frame: CGRect(x: CGFloat(index) * scrollSize, y: 0, width: scrollSize, height: pageC.height))
            view.image(fromUrl: mainImages[index])
            scrollView.addSubview(view)
        }
        
        pageC.addSubview(scrollView)
        pageC.addSubview(pageControl1)
        
        timer = setInterval(interval: 4) {
            if(self.pageControl1.currentPage < self.numberOfPage - 1){
                self.pageControl1.currentPage += 1
                //                self.scrollView.contentOffset = CGPoint(x:self.scrollView.frame.size.width * CGFloat( self.pageControl1.currentPage), y:0);
                DispatchQueue.main.async() {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.scrollView.contentOffset.x = self.scrollView.frame.size.width * CGFloat( self.pageControl1.currentPage)
                    }, completion: nil)
                }
            }
            else{
                self.pageControl1.currentPage = 0
                self.scrollView.contentOffset = CGPoint(x:self.scrollView.frame.size.width * CGFloat(self.pageControl1.currentPage), y:0);
            }
        }
    }

    @IBAction func closeAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}

