//
//  DetailViewController.swift
//  CityBikesApp
//
//  Created by Rabish_Kumar on 08/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    var bikeIdStr:String = ""
    var companyNameStr:String = ""
    var locationStr:String = ""
    var bikeNameStr:String = ""
    var dataDict:AnyObject = [:] as AnyObject
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bikeNameStr as String
        self.companyNameLabel.text = "Company: \(companyNameStr)"
        self.locationLabel.text = "Location: \(locationStr)"
        setupUserTrackingButtonAndScaleView()
        registerAnnotationViewClasses()
        loadDataForMapRegionAndBikes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCompassButton()
    }
    // Create a location manager to trigger user tracking
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()
    
    func setupCompassButton() {
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compass)
        mapView.showsCompass = true
    }
    func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
    }
    func registerAnnotationViewClasses() {
        mapView.register(BikeView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    func loadDataForMapRegionAndBikes() {
        
        let serviceUrl = "http://api.citybik.es/v2/networks/\(bikeIdStr)"
        let serviceHelper = CBWebServiceHelper.shared()
        serviceHelper.sendRequest(toWebServer:serviceUrl, viewController:self) {(_status, data, response) in
            do {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                if(_status == true){
                    let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)  as! [String: AnyObject];
                    print("!!!!\(getResponse)")
                    self.dataDict = getResponse["network"] as AnyObject
                    if let locationDict = self.dataDict["location"] as? NSDictionary {
                        let latitude = locationDict["latitude"] as! NSNumber
                        let longitude = locationDict["longitude"] as! NSNumber
                        let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude:longitude.doubleValue)
                        let span = MKCoordinateSpanMake(0.1, 0.1)
                         DispatchQueue.main.async {
                            self.mapView.region = MKCoordinateRegionMake(coordinate, span)
                            }
                    }
                     DispatchQueue.main.async {
                        if let mapView = self.mapView {
                            if let bikes = self.dataDict["stations"] as? [[String : AnyObject]] {
                                mapView.addAnnotations(Bike.bikes(fromDictionaries: bikes))
                            }
                        }
                    }
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation selected")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let userLocation = self.mapView.userLocation
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(userLocation)
    }
    
    deinit {
        self.mapView.delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
