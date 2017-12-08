//
//  ViewController.swift
//  CityBikesApp
//
//  Created by venkatesh on 07/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit

class BikeListTableViewCell: UITableViewCell {
    @IBOutlet weak var bikeTitleLabel:UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
}
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var bikeListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.title = "CityBikes"
        getBikeList()
    }
    
    func getBikeList(){
        let serviceHelper = CBWebServiceHelper.shared()
        serviceHelper.sendRequest(toWebServer:"http://api.citybik.es/v2/networks?fields=id,name,company,location") {(_status, data, response) in
            do {
                let getResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments)  as! [String: Any];
                print("Response: \(getResponse)")
                // }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
        }
    }

    // MARK:- TableView Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BikeListTableViewCell") as! BikeListTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

