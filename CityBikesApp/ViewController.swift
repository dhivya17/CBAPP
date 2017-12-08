//
//  ViewController.swift
//  CityBikesApp
//
//  Created by venkatesh on 07/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

