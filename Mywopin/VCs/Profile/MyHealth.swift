//
//  MyHealth
//  Mywopin
//
//  Created by Hydeguo on 2018/7/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class MyHealth: UITableViewController {
    
    @IBOutlet var titleImage:UIImageView!
    @IBOutlet var heightLabel:UILabel!
    @IBOutlet var weightLabel:UILabel!
    @IBOutlet var ageLabel:UILabel!
    @IBOutlet var bloodSugar:UILabel!
    @IBOutlet var bloodLipid:UILabel!
    @IBOutlet var bloodPress:UILabel!
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        if let height = myClientVo?.profiles?.height {
            heightLabel.text = "\(height) cm"
        }
        if let weight = myClientVo?.profiles?.weight {
            weightLabel.text = "\(weight) kg"
        }
        if let age = myClientVo?.profiles?.age {
            ageLabel.text = String(Int(age))
        }
        if let blood_lipid = myClientVo?.profiles?.blood_lipid_all {
            bloodLipid.text = String(blood_lipid)
        }
        if let blood_sugar = myClientVo?.profiles?.blood_sugar_full {
            bloodSugar.text = String(blood_sugar)
        }
        if let blood_pressure = myClientVo?.profiles?.blood_pressure {
            bloodPress.text = String(blood_pressure)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
  
   
    
    @objc func save(_ sender: Any) {
        
    }
    
}
