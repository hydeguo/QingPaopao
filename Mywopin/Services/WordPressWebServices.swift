//
//  WordPressWebServices.swift
//  WordPress-API
//
//  Created by Pierre Marty on 11/02/2015.
//  Copyright (c) 2015 Pierre Marty. All rights reserved.
//

// WordPress REST API documentation:  https://developer.wordpress.com/docs/api/


import Foundation
import UIKit

class WordPressWebServices {
    
    // your site url here !
    static let siteURL = "https://public-api.wordpress.com/rest/v1.1/sites/wifi.h2popo.com"
    
    static let sharedInstance = WordPressWebServices(url:siteURL)   // singleton instanciation
    
    fileprivate var baseURL:String?;
    
    convenience init(url: String) {
        self.init()
        self.baseURL = url
    }
    
    func postByIdentifier (_ identifier:Int, completionHandler:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void) {
        let requestURL = baseURL! + "/posts/\(identifier)?fields=date,title,content"
        let url = URL(string: requestURL)!
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(nil, error as NSError?);
                return;
            }
            var jsonError: NSError?
            var jsonResult:Any?
            do {
                jsonResult = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonResult = nil
            } catch {
                fatalError()
            }
            completionHandler(jsonResult as? Dictionary<String, AnyObject>, jsonError);
        })
        
        dataTask.resume()
    }
    
    // page parameter is one based [1..[
    func lastPosts (page:Int, number:Int, completionHandler:@escaping ([PostItem]?, NSError?) -> Void) {
        let requestURL = baseURL! + "/posts/?page=\(page)&number=\(number)&fields=ID,title,date,featured_image"
        let url = URL(string: requestURL)!
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(nil, error as NSError?);
                return;
            }
            var jsonError: NSError?
            var jsonResult:Any?
            do {
                jsonResult = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonResult = nil
            } catch {
                fatalError()
            }
            var articles:[PostItem] = []
            
            if let resultDictionary = jsonResult as? Dictionary<String, AnyObject>,
                let posts = resultDictionary["posts"] as? [Dictionary<String, AnyObject>] {
                    for post in posts {
                        if let _ID = post["ID"] as? Int,
                            let _title = post["title"] as? String,
                            let _date = post["date"] as? String ,
                            let _featured_image = post["featured_image"] as? String   {
                                articles.append(PostItem(ID: _ID, title: _title, date: _date, featured_image: _featured_image))
                        }
                    }
            }
            completionHandler(articles, jsonError);
        })
        
        dataTask.resume()
    }
    
    
    func loadImage (_ url: String, completionHandler:@escaping (UIImage?, NSError?) -> Void) {
        let url = URL(string: url)!
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error == nil {
                let image = UIImage(data:data!);
                completionHandler(image, nil);
            }
            else {
                completionHandler(nil, error as NSError?);
            }
        })
        
        dataTask.resume()
    }
    
}





