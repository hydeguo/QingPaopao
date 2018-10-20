//
//  WifiScanListVC.swift
//  Mywopin
//
//  Created by Emil on 1/8/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
class WifiScanListVC: UIViewController {}
#else
class WifiScanListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var essids = [String]()
    
    private var names: [String] = (50...99).map { String($0) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return essids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = essids[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) 
        print(currentCell?.textLabel!.text ?? "")
        let ssidStr = indexPath?.row == essids.count - 1 ? "" : currentCell?.textLabel!.text
        wifiTableViewController?.selectedSSID.text = ssidStr
        self.dismiss(animated: true, completion: nil)
    }
    
    var wifiTableViewController : WifiTableViewController?
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func scanAgain(_ sender: Any) {
        essids.removeAll()
        self.dismiss(animated: true) {
            self.wifiTableViewController?.scanNearbyWifi(isPresent : true)
        }
        ///essids = (self.wifiTableViewController?.essids)!
    }
    
    @IBAction func finish(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.tableView.reloadData()
        }
        
        
    }

}
#endif
