//
//  DrinkHistory.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class DrinkHistory: UIViewController {
    
    @IBOutlet var partOneTitle:UILabel!
    @IBOutlet var partTwoTitle:UILabel!
    @IBOutlet var partOneLine1Title:UILabel!
    @IBOutlet var partOneLine2Title:UILabel!
    @IBOutlet var partOneLine1Value:UILabel!
    @IBOutlet var partOneLine2Value:UILabel!
    @IBOutlet var partTwoView:UIView!
    @IBOutlet var chartView1:UIView!
    @IBOutlet var chartView2:UIView!
    
    @IBOutlet var segmentedControl:UISegmentedControl!
    
    var lineChart: LineChart!
    var lineChart2: LineChart!
    
    var data_week: [CGFloat] = []
    var data_month: [CGFloat] = []
    var todayDrink: OneDayDrinks?
    var total_week:Int = 0
    var total_month:Int = 0
    var standard_week:Int = 0
    var standard_month:Int = 0
    
    //MARK: Check if user is signed in or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.segmentedControlAction(sender: segmentedControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partTwoView.isHidden = true
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        chartView1.isHidden = true
        chartView2.isHidden = true
        
        var views1: [String: AnyObject] = [:]
        
        let label1 = UILabel()
        label1.text = "    "
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.textAlignment = NSTextAlignment.center
        chartView1.addSubview(label1)
        views1["label"] = label1
        chartView1.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views1))
        chartView1.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-"+String(describing: 0)+"-[label]", options: [], metrics: nil, views: views1))
        
        lineChart = LineChart()
        lineChart.animation.enabled = false
        lineChart.area = true
        lineChart.cx.grid.count = 7
        lineChart.cy.grid.count = 7
        lineChart.cx.labels.visible = true
        lineChart.cx.labels.values = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
        lineChart.addLine([0,0,0,0,0])
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        //        lineChart.delegate = self
        self.chartView1.addSubview(lineChart)
        views1["chart"] = lineChart
        
        chartView1.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views1))
        chartView1.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==\(Int( SCREEN_HEIGHT * 1 / 3.0)))]", options: [], metrics: nil, views: views1))
        
        var views2: [String: AnyObject] = [:]
        let label2 = UILabel()
        label2.text = "    "
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.textAlignment = NSTextAlignment.center
        chartView2.addSubview(label2)
        views2["label"] = label2
        chartView2.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views2))
        chartView2.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-"+String(describing: 0)+"-[label]", options: [], metrics: nil, views: views2))
        
        
        lineChart2 = LineChart()
        lineChart2.animation.enabled = false
        lineChart2.area = true
        lineChart2.cx.grid.count = 10
        lineChart2.cy.grid.count = 7
        lineChart2.cx.labels.visible = true
        lineChart2.cx.labels.values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10","11", "12", "13", "14", "15", "16", "17", "18", "19", "20","21", "22", "23", "24", "25", "26", "27", "28", "29", "30","31"]
        lineChart2.addLine([0,0,0,0,0])
        
        lineChart2.translatesAutoresizingMaskIntoConstraints = false
        //        lineChart.delegate = self
        self.chartView2.addSubview(lineChart2)
        views2["chart"] = lineChart2

        
        chartView2.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views2))
        chartView2.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==\(Int( SCREEN_HEIGHT * 1 / 3.0)))]", options: [], metrics: nil, views: views2))
        
        
        //------get data------------
        _ = Wolf.requestList(type: MyAPI.getDrinkList, completion: { (info: [OneDayDrinks]?, msg, code) in
            if(code == "0" && info != nil)
            {
                var numOfWeek = Calendar.current.component(.weekday, from: Date())
                numOfWeek = numOfWeek==1 ? 7 : numOfWeek - 1
           
                let dateStr = self.getDayString(day:Date())
                if let oneDayDrink = self.getDateDrink(dayStr: dateStr, dataArr: info!){
                    self.todayDrink = oneDayDrink
                }
                
                self.total_week = 0
                self.standard_week = 0
                while numOfWeek > 0{
                    let day = Calendar.current.date(byAdding: .day, value: 1-numOfWeek, to: Date())
                    numOfWeek = numOfWeek - 1
                    let dateStr = self.getDayString(day:day!)
                    if let oneDayDrink = self.getDateDrink(dayStr: dateStr, dataArr: info!){
                        let drink_count = oneDayDrink.drinks?.count ?? 0
                        self.data_week.append(CGFloat(drink_count))
                        self.total_week += drink_count
                        if drink_count >= Int(oneDayDrink.target ?? 0)
                        {
                            self.standard_week += 1
                        }
                    }else{
                        self.data_week.append(0)
                    }
                }
                
                self.total_month = 0
                self.standard_month = 0
                var dayOfMonth = Calendar.current.component(.day, from: Date())

                while dayOfMonth > 0{
                    let day = Calendar.current.date(byAdding: .day, value: 1-dayOfMonth, to: Date())
                    dayOfMonth = dayOfMonth - 1
                    let dateStr = self.getDayString(day:day!)
                    if let oneDayDrink = self.getDateDrink(dayStr: dateStr, dataArr: info!){
                        let drink_count = oneDayDrink.drinks?.count ?? 0
                        self.data_month.append(CGFloat(drink_count))
                        self.total_month += drink_count
                        if drink_count >= Int(oneDayDrink.target ?? 0)
                        {
                            self.standard_month += 1
                        }
                    }else{
                        self.data_month.append(0)
                    }
                }
                while self.data_month.count < 2 // OR it will error
                {
                    self.data_month.append(0)
                }
                self.updateSelecttion()
            }
            Log(self.data_week.count)
            Log(self.data_month.count)
        }, failure: nil)
    }
    
    func getDateDrink(dayStr:String , dataArr:[OneDayDrinks])->OneDayDrinks?
    {
        for one in dataArr {
            if one.date == dayStr
            {
                return one
            }
        }
        return nil
    }
    
    func getDayString(day:Date)->String
    {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyyMMdd";
        return dateFormatter.string(from: day);
    }
    
    @objc func segmentedControlAction(sender: AnyObject) {
        updateSelecttion()
    }
    
    func updateSelecttion()
    {
        
        if(segmentedControl.selectedSegmentIndex == 0)
        {
            partOneTitle.text = Language.getString("今天喝水统计")
            partOneLine1Title.text = Language.getString("喝水量")
            partOneLine2Title.text = Language.getString("最近一次喝水时间")
            partOneLine1Value.text = "0" + Language.getString("杯")
            partOneLine2Value.text = "--"
            if let drinkData = todayDrink , let lastDrink = drinkData.drinks?.last
            {
                partOneLine1Value.text = String(drinkData.drinks!.count) + Language.getString("杯")
                partOneLine2Value.text = lastDrink.time
            }
            partTwoView.isHidden = true
        }
        else if(segmentedControl.selectedSegmentIndex == 1)
        {
            partOneTitle.text = Language.getString("本周喝水统计")
            partTwoTitle.text = Language.getString("本周喝水状况")
            partOneLine1Title.text = Language.getString("总喝水量")
            partOneLine2Title.text = Language.getString("达标天数")
            partOneLine1Value.text = String(self.total_week)  + Language.getString("杯")
            partOneLine2Value.text = String(self.standard_week)  + Language.getString("天")
            partTwoView.isHidden = false
            chartView1.isHidden = false
            chartView2.isHidden = true
            lineChart.clearAll();
            if(data_week.count == 1 ){
                data_week.append(0)
            }
            lineChart.addLine(data_week)
        }
        else if(segmentedControl.selectedSegmentIndex == 2)
        {
            partOneTitle.text = Language.getString("本月喝水统计")
            partTwoTitle.text = Language.getString("本月喝水状况")
            partOneLine1Title.text = Language.getString("总喝水量")
            partOneLine2Title.text = Language.getString("达标天数")
            partOneLine1Value.text = String(self.total_month) + Language.getString("杯")
            partOneLine2Value.text = String(self.standard_month) + Language.getString("天")
            partTwoView.isHidden = false
            chartView1.isHidden = true
            chartView2.isHidden = false
            lineChart2.clearAll();
            if(data_month.count == 1 ){
                data_month.append(0)
            }
            lineChart2.addLine(data_month)
        }
    }
    
    @objc func save(_ sender: Any) {
        
    }
    
}
