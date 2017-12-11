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
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var bikeListTableView: UITableView!
    @IBOutlet weak var bikeListSearchBar: UISearchBar!
    var listArr:[Any] = []
    var searchActive : Bool = false
    var filteredArr:[AnyObject] = []
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
        return searchActive == true ? filteredArr.count: listArr.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BikeListTableViewCell") as! BikeListTableViewCell
        
        let dataDict = searchActive == true ? self.filteredArr[indexPath.row] as AnyObject : self.listArr[indexPath.row] as AnyObject

        // getting company Name
        let companyNameStr = getComapanyName(dict: dataDict as! NSDictionary)
        
        // getting location
        let locationDict = dataDict["location"] as! NSDictionary
        let locationStr = NSString(format:"%@,%@",(locationDict["city"]as? String)!,(locationDict["country"]as? String)!)
        
        cell.bikeTitleLabel.text = dataDict["name"] as? String
        cell.companyLabel.text = "Company: \(companyNameStr)"
        cell.locationLabel.text = "Location: \(locationStr)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DetailViewController") {
            if self.bikeListTableView.indexPathForSelectedRow != nil {
                let controller = segue.destination as! DetailViewController
                let dataDict = searchActive == true ? self.filteredArr[(self.bikeListTableView.indexPathForSelectedRow?.row)!] as AnyObject : self.listArr[(self.bikeListTableView.indexPathForSelectedRow?.row)!] as AnyObject
                controller.bikeIdStr = (dataDict["id"] as? String)!
                controller.companyNameStr = getComapanyName(dict: dataDict as! NSDictionary) as String
                let locationDict = dataDict["location"] as! NSDictionary
                let locationStr = NSString(format:"%@,%@",(locationDict["city"]as? String)!,(locationDict["country"]as? String)!)
                controller.locationStr = locationStr as String
                controller.bikeNameStr =  (dataDict["name"] as? String)!
            }
        }
        
    }
    
    // MARK:- UISearchBar Delegate Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        self.bikeListTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        self.bikeListTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        self.bikeListTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredArr = listArr.filter({(data) -> Bool in
            let dataDict = data as AnyObject
            let nameStr:NSString = (dataDict["name"] as? String)! as NSString
            let companyNameStr:NSString = getComapanyName(dict: dataDict as! NSDictionary) as NSString
            let range1 = nameStr.range(of:searchText, options:.caseInsensitive)
            let range2 = companyNameStr.range(of:searchText, options:.caseInsensitive)
            return ((range1.location != NSNotFound) || (range2.location != NSNotFound))
        }) as [AnyObject]
//        if(filtered.count == 0){
//            searchActive = false;
//        } else {
            searchActive = true;
       // }
        if searchBar.text?.count == 0{
            searchActive = false;
        }
        self.bikeListTableView.reloadData()
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

