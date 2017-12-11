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
    var listArr:[Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.title = "CityBikes"
        getBikeList()
    }
    
    func getBikeList(){
        let serviceHelper = CBWebServiceHelper.shared()
         serviceHelper.sendRequest(toWebServer:"http://api.citybik.es/v2/networks?fields=id,name,company,location", viewController:self) {(_status, data, response) in
            do {
                if(_status == true){
                let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as! [String: AnyObject];
                    self.listArr = (getResponse["networks"] as? [Any])!
                    DispatchQueue.main.async {
                        self.bikeListTableView.reloadData()
                    }
                }
               
            } catch {
                print("error serializing JSON: \(error)")
            }
            
        }
    }
    
    // MARK:- TableView Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return listArr.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BikeListTableViewCell") as! BikeListTableViewCell
        
        let dataDict = self.listArr[indexPath.row] as AnyObject

        // getting company Name
        let companyNameStr = getComapanyName(dict: dataDict as! NSDictionary)
        
        // getting location
        let locationDict = dataDict["location"] as! NSDictionary
        let locationStr = NSString(format:"%@,%@",(locationDict["city"]as? String)!,(locationDict["country"]as? String)!)
        
       cell.bikeTitleLabel.text = dataDict["name"] as? String
        cell.companyLabel.text = "Company: \(companyNameStr)"
        cell.locationLabel.text = "Location:\(locationStr)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DetailViewController") {
            if self.bikeListTableView.indexPathForSelectedRow != nil {
                let controller = segue.destination as! DetailViewController
                let dataDict = self.listArr[(self.bikeListTableView.indexPathForSelectedRow?.row)!] as AnyObject
                controller.bikeIdStr = "Test"
                controller.companyNameStr = getComapanyName(dict: dataDict as! NSDictionary) as String
                let locationDict = dataDict["location"] as! NSDictionary
                let locationStr = NSString(format:"%@,%@",(locationDict["city"]as? String)!,(locationDict["country"]as? String)!)
                controller.locationStr = locationStr as String
                controller.bikeNameStr =  (dataDict["name"] as? String)!
            }
        }
        
    }
    
    // MARK:- getting company Name
    func getComapanyName(dict:NSDictionary) -> NSString {
        var companyNameStr = ""
        let companyList = dict["company"] as AnyObject
        if(companyList.isKind(of:NSString.self)) {
            companyNameStr =  (companyList as! NSString) as String
        }else{
            if ((companyList as? NSArray) != nil) {
                companyNameStr =  (companyList as! NSArray).componentsJoined(by: ",")
            }
        }
        return companyNameStr as NSString
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

