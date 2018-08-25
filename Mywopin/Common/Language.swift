//
//  Language.swift
//

import UIKit

class Language: NSObject {
    static let share = Language()
    
    private let languageKey: String = "AppleLanguages"
    private let def = UserDefaults.standard
    private var appDelegate:AppDelegate?
    
    
    var appLanguage: String {
        guard let app = self.def.array(forKey: self.languageKey) else {
            return ""
        }
        return app.first as! String
    }
    
    func setLanguage(_ lag: String) {
        self.def.setValue([lag], forKey: self.languageKey)
        self.def.synchronize()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
//        appDelegate?.window?.rootViewController = storyboard.instantiateInitialViewController();
    }
    func setAppDelegate(_ app: AppDelegate) {
        appDelegate = app
    }
    
    class func getString(_ key: String) -> String {
        
        guard let path = Bundle.main.path(forResource: Language.share.appLanguage, ofType: "lproj"), let bundle = Bundle(path: path) else {
            // 回傳基本文件資料
            guard let path = Bundle.main.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) else {
                return ""
            }
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
