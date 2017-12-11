//
//  CBWebServiceHelper.swift
//  CityBikesApp
//
//  Created by venkatesh on 07/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit
import SystemConfiguration

typealias completionHandler = (_ status: Bool, _ responseData: Data?, _ responseDetailedString: String?) -> Void
class CBWebServiceHelper: NSObject {

    private static var sharedCBWebServiceHelper: CBWebServiceHelper = {
        let serviceHelper = CBWebServiceHelper()
        return serviceHelper
    }()
    
    class func shared() -> CBWebServiceHelper {
        return sharedCBWebServiceHelper
    }
    
    func sendRequest(toWebServer serviceUrlStr: String,viewController:UIViewController, with responceHandler: @escaping completionHandler) {
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        
        let urlString = serviceUrlStr
        
        print("get wallet balance url string is \(urlString)")
        //let url = NSURL(string: urlString as String)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = NSURL(string:urlString)! as URL
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        let isReachable: Bool = flags.contains(.reachable)
        
        if(isReachable == true) {
            
            let dataTask = session.dataTask(with: request as URLRequest) {
                ( data: Data?, response: URLResponse?, error: Error?) -> Void in
                // Check HTTP Response for successful GET request
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        responceHandler(false, nil, nil)
                        self.showAlertWith(title: "Service Alert", message: "error: not a valid http response", viewController: viewController)
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 200:
                    
                    let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                    //print("response is \(String(describing: response))")s
                    do {
                        let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: .allowFragments)
                        responceHandler(true,data!, response! as String)
                        print("Response: \(getResponse)")
                        // }
                    } catch {
                        
                        self.showAlertWith(title: "Service Alert", message: "error serializing JSON: \(error)", viewController: viewController)
                        responceHandler(false, nil, nil)

                    }
                    
                    break
                default:
                    self.showAlertWith(title: "Service Alert", message: " GET request got response \(httpResponse.statusCode)", viewController: viewController)
                    responceHandler(false, nil, nil)
                }
            }
            dataTask.resume()
        }else{
            print("Network not awailable")
        }
    }
    
    func showAlertWith(title:String, message:String,viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
}
