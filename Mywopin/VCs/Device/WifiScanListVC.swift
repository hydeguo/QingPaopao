//
//  WifiScanListVC.swift
//  Mywopin
//
//  Created by Emil on 1/8/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import Alamofire

#if targetEnvironment(simulator)
class WifiScanListVC: UIViewController {}
#else
class WifiScanListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var essids = [String]()
    var timer:Timer?
    
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
        wifiTableViewController?.selectedSSIDFlag = true
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
    override func viewWillAppear(_ animated: Bool) {
        timer?.invalidate()
        timer = setInterval(interval: 6, block: refreshList)
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    func refreshList(){
        let header    = [ "scan" : "1" ]
        Alamofire.request(wopinWifiURL,headers:header).responseString { response in
            print(response)
            
            if let jsonString = response.result.value {
                
                self.essids.removeAll()
                let subarr = jsonString.components(separatedBy: ",\n")
                
                for r in subarr {
                    do {
                        let itemStr = r.removeSpacesAndNewlines()
                        let ra = try JSONDecoder().decode(WifiScanResult.self, from: itemStr.data(using: .utf8)!)
                        if let essid = ra.essid
                        {
                            self.essids.append(essid)
                        }
                    } catch {
                        
                    }
                }
                self.essids.append("手动输入")
                self.tableView.reloadData()
            }
        }
    }

}
#endif
