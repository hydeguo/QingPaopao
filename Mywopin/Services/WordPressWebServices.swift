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
    static let apiURL = "https://public-api.wordpress.com/rest/v1.1/sites/wifi.h2popo.com"
    static let siteURL = "https://wifi.h2popo.com"
    
    static let sharedInstance = WordPressWebServices(url:apiURL)   // singleton instanciation
    
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
        let requestURL = baseURL! + "/posts/?page=\(page)&number=\(number)&fields=ID,title,date,featured_image,author"
        let url = URL(string: requestURL)!
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(nil, error as NSError?);
                return;
            }
            do {
                let data:PostList = try JSONDecoder().decode(PostList.self, from: data!)
                completionHandler(data.posts, nil);
            } catch let error as NSError {
                completionHandler(nil, error);
            } catch {
                fatalError()
            }
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
    
    
//    func postNew (completionHandler:@escaping (String?, NSError?) -> Void) {
//        let requestURL = WordPressWebServices.siteURL + "/wp-admin/post-new.php"
//        let url = URL(string: requestURL)!
//        let urlSession = URLSession.shared
//
//        let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
//            if error != nil {
//                completionHandler("", error as NSError?);
//                return;
//            }
//
//            completionHandler(String(data: data!, encoding:String.Encoding.utf8),nil);
//        })
//
//        dataTask.resume()
//    }
    
    func postNew (completionHandler:@escaping (String?, NSError?) -> Void) {
        let requestURL = WordPressWebServices.siteURL + "/wp-login.php"
        let endpointUrl = URL(string: requestURL)
        
        let params = "log=hyde&pwd=101010&redirect_to=/wp-admin/post-new.php"
        let postString = params
        var request = URLRequest(url: endpointUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(nil, error as NSError?);
                return;
            }
            let httpStr = String(data: data!, encoding:String.Encoding.utf8)
            Log(httpStr)
            completionHandler(httpStr,nil);
        })
        task.resume()
    }
    
    func loginWP (id:String, completionHandler:@escaping (Bool, NSError?) -> Void) {
        let requestURL = WordPressWebServices.siteURL + "/wp-login.php"
        let endpointUrl = URL(string: requestURL)
        
        let params = "log=hyde&pwd=101010&redirect_to=''&testcookie=1"
        let postString = params
        
        var request = URLRequest(url: endpointUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(false, error as NSError?);
                return;
            }
            completionHandler(true,nil);
        })
        task.resume()
    }
}





