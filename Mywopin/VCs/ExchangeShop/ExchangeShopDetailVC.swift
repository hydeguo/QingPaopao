//
//  ShopDetailVc.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/7.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class ExchangeShopDetailVC: UITableViewController ,UIWebViewDelegate{

    @IBOutlet var dropBoxViewContainer:UIView!
    @IBOutlet var detailWebView:UIWebView!
    
    @IBOutlet var detailCell:UITableViewCell!
    @IBOutlet var titleLb:UILabel!
    @IBOutlet var subTitleLb:UILabel!
    @IBOutlet var priceLb:UILabel!
    @IBOutlet var stockNumLb:UILabel!
    @IBOutlet var dateLb:UILabel!
    
    @IBOutlet var oldGoodsLb:UILabel!
    
    @IBOutlet var pageC:UIImageView!
    let scrollView = UIScrollView()
    let pageControl1 = FlexiblePageControl()
    var scrollSize: CGFloat = 300
    var numberOfPage: Int = 0
    var timer:Timer?
    
    var oldProducts:[WooGoodsItem] = []
    var webViewDict = Dictionary<Int, UIWebView>.init()
    var heightDict = Dictionary<Int, CGFloat>.init()
    let screenWidth = UIScreen.main.bounds.size.width
    let detailWebViewSection = 2
    var data:WooGoodsItem?
    var discountPrice:String = "0"
//    var oldGoods:WooGoodsItem?
    
    var activeFlag:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
//        let returnButton = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(onReturn))
//    self.navigationController!.topViewController!.navigationItem.leftBarButtonItem =  returnButton
        
        
    }
    @objc func onReturn()
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func createImages()
    {
        guard data != nil else {
            return
        }
        
        var _subTitle = data!.short_description
        titleLb.text = data!.name
        subTitleLb.text = _subTitle.filterHTML()
        priceLb.text = "¥"+data!.price
        stockNumLb.text = "库存：\(data!.stock_quantity ?? 0)"
        if (data?.attributes.count ?? 0) > 0
        {
            discountPrice = data?.attributes[0].name ?? "0"
            oldGoodsLb.text = data?.attributes[0].options[0] ?? ""
        }
        
        if let date_from =  data?.date_on_sale_from , let date_to = data?.date_on_sale_to
        {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let time_from = dateFormatterGet.date(from: date_from)!//2017-08-28T08:24:37
            let time2 = dateFormatterGet.date(from: date_to)!//2017-08-28T08:24:37
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: Date())
            let date2 = calendar.startOfDay(for: time2)
            
            if time_from > Date()
            {
                dateLb.text = "\(dateFormatter.string(from: time_from)) 开始"
                activeFlag = false
            }
            else if Date() > time2
            {
                dateLb.text = "活动已结束"
                activeFlag = false
            }
            else
            {
                let components = calendar.dateComponents([.day], from: date1, to: date2).day!
                dateLb.text = "剩余：\(components)天"
                activeFlag = true
            }
            
            if (data!.stock_quantity ?? 0) <= 0
            {
                activeFlag = false
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "exchangeTimeOut"), object: self, userInfo: ["data":activeFlag])
        
        
        numberOfPage = data!.images.count
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
            view.image(fromUrl: data!.images[index].src)
            view.contentMode = .scaleAspectFill
            scrollView.addSubview(view)
        }
        
        pageC.image = UIImage()
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
    
    
    
    override func viewDidLayoutSubviews() {

    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            if(indexPath.row == 0){
                return 375
            }else {
                return UITableViewAutomaticDimension
            }
        }
        if indexPath.section == 1
        {
            return 100
        }
        if indexPath.section == detailWebViewSection
        {
            if let _height = heightDict[indexPath.section]  {
                return _height
            }
        }
        return 100
    }
    override func viewWillAppear(_ animated: Bool) {

        calculateWebHeight()
        
        createImages()
    
//        _ = Wolf.requestBaseList(type: WooAPI.getExchangeOldProducts, completion: { (goods: [WooGoodsItem]?, msg, code) in
//            if(code == "0")
//            {
//                Log(goods?.count)
//                if let goodsItems = goods
//                {
//                    self.oldProducts = goodsItems
//                    self.tableView.reloadData()
//
//                    var choices:[String] = [] // ["第一个选项", "第二个选项", "第三个选项", "第四个选项"]
//                    for oldGoods in goodsItems
//                    {
//                        choices.append(oldGoods.name);
//                    }
//
//                    let defaultTitle = "请选择以旧换新的产品"
//                    let rect = CGRect(x: 0, y: 0, width: self.dropBoxViewContainer.frame.width , height: self.dropBoxViewContainer.frame.height)
//                    let dropBoxView = TGDropBoxView(parentVC: self, title: defaultTitle, items: choices, frame: rect)
//                    dropBoxView.isHightWhenShowList = true
//                    dropBoxView.willShowOrHideBoxListHandler = { (isShow) in
//                        if isShow { NSLog("will show choices") }
//                        else { NSLog("will hide choices") }
//                    }
//                    dropBoxView.didShowOrHideBoxListHandler = { (isShow) in
//                        if isShow { NSLog("did show choices") }
//                        else { NSLog("did hide choices") }
//                    }
//                    dropBoxView.didSelectBoxItemHandler = { (row) in
//                        NSLog("selected No.\(row): \(dropBoxView.currentTitle())")
//                        self.oldGoods = self.oldProducts[row]
//                    }
//                    self.dropBoxViewContainer.addSubview(dropBoxView)
//
////                    dropBoxView.layer.cornerRadius = 5
//                    dropBoxView.layer.borderWidth = 1
//                    dropBoxView.layer.borderColor = UIColor.lightGray.cgColor
//
//
//                }
//            }
//            else
//            {
//                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
//            }
//        }, failure: nil)
    }

    
    // MARK: -
    func calculateWebHeight() {
        guard data != nil else {
            return
        }
//        var htmlString = data!.description
//        Log(htmlString)
//        if htmlString.contains("<img") {
//            htmlString = htmlString.replacingOccurrences(of: "<img", with: "<img style='max-width: 100%; vertical-align:middle;'")
//        }
        
        let htmlString = """
        <html> \n\
        <head> \n\
        <style type="text/css"> \n\
        //body {font-size:15px;}\n\
        img{\n\
        //border: 4px solid #fff;\n\
        }\n\
        </style> \n\
        </head> \n\
        <body>\
        \(data!.description)
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
        detailWebView.isHidden = true
        detailWebView.delegate = self
        detailWebView.backgroundColor = UIColor.clear
        detailWebView.isOpaque = false
        detailWebView.dataDetectorTypes = UIDataDetectorTypes.init(rawValue: 0)
        detailWebView.scrollView.isScrollEnabled = false
        detailWebView.scrollView.showsVerticalScrollIndicator = false
        detailWebView.scrollView.showsHorizontalScrollIndicator = false
        detailWebView.isUserInteractionEnabled = false
        detailWebView.tag = detailWebViewSection
        detailWebView.loadHTMLString(htmlString, baseURL: nil)
        webViewDict.updateValue(detailWebView, forKey: detailWebViewSection)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 使webView自适应高度
        detailWebView.isHidden = false
        webView.sizeToFit()
        let height = webView.bounds.size.height + 50
        webView.frame = CGRect.init(x: 10, y: 0, width: screenWidth - 20, height: height)
        if !heightDict.keys.contains(webView.tag) {
            heightDict.updateValue(height, forKey: webView.tag)
            
            if heightDict.count >= 1 {
                self.tableView.reloadData()
                _ = setTimeout(delay: 0.1) {
                    self.detailWebView.y = 40
                }
//                hideLoading()
            }
        }
    }

}
