//
//  InfosViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit

class InfosViewController: UIViewController ,UISearchResultsUpdating,UISearchBarDelegate{
    

    

//    @IBOutlet var topView:UIView!
    @IBOutlet var hotPostBtn:UIButton!
    @IBOutlet var newPostBtn:UIButton!
    @IBOutlet var myPostBtn:UIButton!
    var tabelListVC:PostListViewController!
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createGradientLayer(view: self.topView)
        
        hotPostBtn.isSelected = true
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        selectType(nil)
        tabelListVC.searchText = searchController.searchBar.text ?? ""
        tabelListVC.changeMode(mode: .search)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PostListViewController,
            segue.identifier == "EmbedSegue" {
            self.tabelListVC = vc
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
//    @IBAction func postNew()
//    {
//        let controller: EditorViewController = EditorViewController(wordPressMode: true)
//
////        if let filename = filename {
////            let sampleHTML = getSampleHTML(fromHTMLFileNamed: filename)
////
////            controller = EditorDemoController(withSampleHTML: sampleHTML, wordPressMode: wordPressMode)
////        } else {
////            controller = EditorDemoController(wordPressMode: wordPressMode)
////        }
//
////        navigationController?.pushViewController(controller, animated: true)
//    }
    

    @IBAction func selectType(_ btn:UIButton?)
    {
        hotPostBtn.isSelected = false
        newPostBtn.isSelected = false
        myPostBtn.isSelected = false
        btn?.isSelected = true
        if(hotPostBtn == btn){
            tabelListVC.changeMode(mode: .hot)
        }else if (newPostBtn == btn){
            tabelListVC.changeMode(mode: .new)
        }else if (myPostBtn == btn){
            tabelListVC.changeMode(mode: .my)
        }
    }
}

