//
//  MyProfileTableVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/3.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit




class MyProfileTableVC: UITableViewController{
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        navigationItem.leftBarButtonItem = editButtonItem
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        

        
        
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        navigationItem.titleView?.tintColor = UIColor.colorFromRGB(0x7b43d1)
        
       

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        print("segue.identifier..\(segue.identifier)")
//        if segue.identifier == "showDetail" {
//            // if let indexPath = //tableView.indexPathForSelectedRow {
//            let object = rArr[(sender as! UIButton).tag ]
//            let controller = segue.destination  as! DetailViewController
//
//            controller.detailItem = object
//            //                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//            //                controller.navigationItem.leftItemsSupplementBackButton = true
//
//        }
//        if segue.identifier == "manage" {
//            // if let indexPath = //tableView.indexPathForSelectedRow {
//            let object = rArr[(sender as! UIButton).tag ]
//            let controller = segue.destination  as! ManageController
//
//            controller.detailId = object.id
//            controller.rs_title = object.restaurantName
//        }
        
    }
    
    // MARK: - Table View
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
           return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! ProfileCell
        
        cell.iconText?.font = UIFont.iconfont(size: 20)
        if(indexPath.row == 0)
        {
            cell.iconText?.text = "\u{e620}"
        }
        else if(indexPath.row == 1)
        {
            cell.iconText?.text = "\u{e600}"
        }
        else if(indexPath.row == 2)
        {
            cell.iconText?.text = "\u{e616}"
        }
//        else if(indexPath.row == 3)
//        {
//            cell.iconText?.text = "\u{e686}"
//        }
//        else if(indexPath.row == 4)
//        {
//            cell.iconText?.text = "\u{e611}"
//        }
//        else if(indexPath.row == 5)
//        {
//            cell.iconText?.text = "\u{e641}"
//        }
//        cell.iconText?.text = String(indexPath.row)

//        let object = rArr[indexPath.row]
//        cell.nameLable?.text = object.restaurantName
//        cell.detailLable?.text = object.des
//        cell.editBtn?.tag = indexPath.row
//        cell.magageBtn?.tag = indexPath.row
//        cell.picImage?.image = UIImage()
//        if(object.imageLink != nil)
//        {
//            cell.picImage?.image(fromUrl: object.imageLink!)
//        }
//         print(indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    
    
    
}





