//
//  WooCommand.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/26.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


func sendWooUpdateStocksCmd(id:Int , stocks:Int)
{
    let url: URL = URL(string: "https://wifi.h2popo.com/wp-json/wc/v2/products/\(id)?consumer_key=ck_7db681ac326401f87ec0a9ce564e45e2ef678f06&consumer_secret=cs_322de70d9956c27899eee79e97dedb6a403e8781&stock_quantity=\(stocks)")!
    var request: URLRequest = URLRequest(url: url)
    request.httpMethod = "POST"
    let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if(error == nil){
            var dict:NSDictionary? = nil
            do {
                dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? NSDictionary
            } catch {
                
            }
        }
    }
    dataTask.resume()
}
