//
//  CrowdfundingShopDetailVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/8/26.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation

class CrowdfundingShopDetailVC: UITableViewController ,UIWebViewDelegate{
    
    @IBOutlet var detailWebView:UIWebView!
    
    @IBOutlet var detailCell:UITableViewCell!
    @IBOutlet var titleLb:UILabel!
    @IBOutlet var subTitleLb:UILabel!
    @IBOutlet var priceLb:UILabel!
    @IBOutlet var selectedPriceLb:UILabel!
    @IBOutlet var selectedDisLb:UILabel!
    @IBOutlet var selectedImage:UIImageView!
    @IBOutlet var numPeopleLb:UILabel!
    @IBOutlet var remainDayLb:UILabel!
    @IBOutlet var moneyGetLb:UILabel!
    @IBOutlet var stockNumLb:UILabel!
    
    
    @IBOutlet var pageC:UIImageView!
    
    @IBOutlet var priceBtn0:UIButton!
    @IBOutlet var priceBtn1:UIButton!
    @IBOutlet var priceBtn2:UIButton!
    @IBOutlet var priceBtn3:UIButton!
    @IBOutlet var priceBtn4:UIButton!
    @IBOutlet var priceBtn5:UIButton!
    @IBOutlet var priceBtn6:UIButton!
    @IBOutlet var priceBtn7:UIButton!
    
    
    @IBOutlet var per_slider:UISlider!
    var sliderLabel: UILabel?
    
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
    
    var priceBtns = [UIButton]()
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
        
        priceBtns = [priceBtn0,priceBtn1,priceBtn2,priceBtn3,priceBtn4,priceBtn5,priceBtn6,priceBtn7]
        var index  = 0
        for priceBtn in priceBtns {
            
            if data!.attributes.count <= index
            {
                priceBtn.isHidden = true
            }
            else
            {
                priceBtn.setTitle("¥"+data!.attributes[index].name, for: .normal)
                priceBtn.setTitle("¥"+data!.attributes[index].name, for: .selected)
            }
            priceBtn.layer.cornerRadius = priceBtn.height/2;
            priceBtn.layer.masksToBounds = true;
            priceBtn.layer.borderColor = UIColor.lightGray.cgColor
            priceBtn.layer.borderWidth = 1;
            
            index += 1;
        }
        
        var _subTitle = data!.short_description
        titleLb.text = data!.name
        subTitleLb.text = _subTitle.filterHTML()
        priceLb.text = "¥"+data!.price
        
        //-------------------------------------
        
        if data!.date_on_sale_to != nil && data!.date_on_sale_to!.count > 0
        {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let time2 = dateFormatterGet.date(from: data!.date_on_sale_to!)!//2017-08-28T08:24:37
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: Date())
            let date2 = calendar.startOfDay(for: time2)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2).day!
            remainDayLb.text = "\(components)天"
        }
        
//        let timeText = dateFormatter.string(from: time)
        
        
        //-------------------------------------
        
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
    
    func createSliderUI()
    {
        if(sliderLabel != nil){
            return
        }
        if let handleView = self.per_slider.subviews.last as? UIImageView {
            let s_thumb = UIImageView(image: UIImage(named: "slider_b"))
            s_thumb.frame = CGRect(x: (handleView.bounds.width-50)/2, y: 0, width: 60, height: handleView.bounds.height)
            handleView.addSubview(s_thumb)
            
            let label = UILabel(frame: s_thumb.frame)
            label.backgroundColor = .clear
            label.textAlignment = .center
            handleView.addSubview(label)
            
            self.sliderLabel = label
            //set label font, size, color, etc.
            label.text = "50%"
        }
    }
    
    @IBAction func selectPrice(_ btn:UIButton)
    {
        for priceBtn in priceBtns {
            priceBtn.layer.borderColor = UIColor.lightGray.cgColor
            priceBtn.isSelected = false
        }
        let index = priceBtns.index(of: btn)!
        btn.isSelected = true
        btn.layer.borderColor = UIColor(red:255/255.0, green:38/255.0, blue:0/255.0, alpha: 1).cgColor
        selectedPriceLb.text = btn.titleLabel?.text
        selectedDisLb.text = data?.attributes[index].options[0] ?? ""
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            if(indexPath.row == 0){
                return 375
            }else if(indexPath.row == 1) {
                return 110
            }else if(indexPath.row == 2) {
                return 110
            }else if(indexPath.row == 3) {
                return 300
            }
        }
        if indexPath.section == 1
        {
            return 40
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
        
        selectPrice(priceBtn0)
        
        _ = Wolf.requestList(type: MyAPI.crowdfundingOrderTotalPeople(goodsId: data!.id), completion: { (info: [CrowdfundingPeople]?, msg, code) in
            if(code == "0" )
            {
                if(info != nil && info!.count>0)
                {
                    self.numPeopleLb.text = "\(Int(info![0].totalPeople!))"
                }
                else
                {
                    self.numPeopleLb.text = "0 "
                }
            }
            else
            {
                _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
        
        _ = Wolf.requestList(type: MyAPI.crowdfundingOrderTotalMoney(goodsId: data!.id), completion: { (info: [CrowdfundingMoney]?, msg, code) in
            if(code == "0" )
            {
                var totalPrice = 0
                if(info != nil && info!.count>0)
                {
                    totalPrice = Int(info![0].totalPrice!)
                }
                if(self.sliderLabel == nil){
                    self.createSliderUI()
                }
                self.moneyGetLb.text = "\(totalPrice) 元"
                let persent = Int(totalPrice * 100 / Int(self.data!.price)!)
                self.per_slider.value = Float(CGFloat(persent)/100)
                self.sliderLabel?.text = "\(persent)%"
            }
            else
            {
                _ = SweetAlert().showAlert("", subTitle: msg, style: AlertStyle.warning)
            }
        }, failure: nil)
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
        detailWebView.delegate = self
        detailWebView.backgroundColor = UIColor.clear
        detailWebView.isOpaque = false
        detailWebView.dataDetectorTypes = UIDataDetectorTypes.init(rawValue: 0)
//        detailWebView.scrollView.isScrollEnabled = false
        detailWebView.scrollView.showsVerticalScrollIndicator = false
        detailWebView.scrollView.showsHorizontalScrollIndicator = false
//        detailWebView.isUserInteractionEnabled = false
        detailWebView.tag = detailWebViewSection
        detailWebView.loadHTMLString(htmlString, baseURL: nil)
        webViewDict.updateValue(detailWebView, forKey: detailWebViewSection)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 使webView自适应高度
        webView.sizeToFit()
        var height = webView.bounds.size.height //webView.scrollView.contentSize.height//
        Log(height)
        height = max(height, SCREEN_HEIGHT * 0.8)
        webView.frame = CGRect.init(x: 10, y: 0, width: screenWidth - 20, height: height)
        if !heightDict.keys.contains(webView.tag) {
            heightDict.updateValue(height, forKey: webView.tag)
            
            if heightDict.count >= 1 {
                self.tableView.reloadData()
                //                hideLoading()
            }
        }
    }
    
}
