//
//  MapVC.swift
//  Test
//
//  Created by Justin Zaw on 23/04/2020.
//  Copyright © 2020 Justin Zaw. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SDWebImage
import GoogleSignIn
import CoreLocation


class MapVC: UIViewController{
    
    
    @IBOutlet weak var mapContainer: UIView!
    
    let defaults = UserDefaults.standard
    
    let infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let subView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let imgUser: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .white
        return img
    }()
    
    let lblName : UILabel = {
       let lbl = UILabel()
        lbl.text = "Name : Hennery"
        lbl.textAlignment = .left
        lbl.textColor = .gray
        return lbl
    }()
    
    let lblNumber : UILabel = {
       let lbl = UILabel()
        lbl.text = "Job Number : 039920"
        lbl.textAlignment = .left
        lbl.textColor = .gray
        return lbl
    }()
    
    var jobLat : NSNumber?
    var jobLong : NSNumber?
    var jobName : String?
    var jobAddress : String?
    
    //request to be use new api key for more test autocomplete search due to exceeding the quota usage limit
    let googlePlaceApiKey = "AIzaSyAZZ2B9VdITkfJgh3VwhOyMspI8Cfcuzgo"
    var googleMapsView: GMSMapView!
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    //Result
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupGoogleMap()
        setupUserInfoView()
        placesClient = GMSPlacesClient.shared()
//        getCurrentLocation()
        showCurrentPlace()
        setupResultView()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupGoogleMap()
//    }
//
   
    
    
    func getJobInfo(number:String,address:String,lat:NSNumber,lon:NSNumber,name:String){
        jobName = name
        jobAddress = address
        jobLat = lat
        jobLong = lon
        
        lblNumber.text = "Job number : \(number)" 
    }
    
    func setupResultView(){
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.tableCellBackgroundColor = .white
        resultsViewController?.tableCellSeparatorColor = .black
        resultsViewController?.primaryTextColor = .darkGray
        resultsViewController?.secondaryTextColor = .darkGray
        resultsViewController?.primaryTextHighlightColor = .darkGray
//        resultsViewController?.tableCellBackgroundColor = .clear
        resultsViewController?.view.backgroundColor = .clear
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController!.searchResultsUpdater = resultsViewController
        
        subView.addSubview((searchController?.searchBar)!)
        
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
       
    }
    
    
    
    
    func setupGoogleMap(){
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 10.0)
//        let camera = GMSCameraPosition.camera(withLatitude: 16.8409, longitude: 96.1735, zoom: 5)
        googleMapsView = GMSMapView(frame: self.mapContainer.frame,camera: camera)
        mapContainer.addSubview(googleMapsView)
        
//        let maker = GMSMarker(position: CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude))
//        let maker = GMSMarker(position: CLLocationCoordinate2D(latitude: 16.8409, longitude: 96.1735))
//        maker.title = "Yangon"
//        maker.snippet = "Myanmar (Burma)"
//        maker.map = googleMapsView
        
        let mrtmaker = GMSMarker(position: CLLocationCoordinate2D(latitude: jobLat as! CLLocationDegrees, longitude: jobLong as! CLLocationDegrees))
        mrtmaker.snippet = jobAddress
        mrtmaker.title = jobName
        mrtmaker.map = googleMapsView
        
    }
    
        
    func showCurrentPlace(){
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
          if let error = error {
            print("Current Place error: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            let place = placeLikelihoodList.likelihoods.first?.place
            
            if let place = place {
                let lat = place.coordinate.latitude
                let lon = place.coordinate.longitude

                let maker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                maker.title = place.name//"Current Location"
                maker.snippet = place.formattedAddress//"my place"
                maker.map = self.googleMapsView
                
            }
          }
        })
    }
    
    func setupNavigation(){
        navigationItem.title = "HAULIO"
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "signOut"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 67).isActive = true
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(goLogOut), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    
    @objc func goLogOut(){
        navigationController?.popViewController(animated: false)
            GIDSignIn.sharedInstance()?.signOut()
            defaults.removeObject(forKey: "loginStatus")
    }
    
    
    func setupUserInfoView(){
        var yValue : CGFloat? = 0.0
           
               if UIDevice.current.hasNotch{
                   yValue = 85.0
               }else{
                   yValue = 65.0
                 
               }
        view.addSubview(subView)
        subView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: yValue!, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 56)
        
          view.addSubview(infoView)
          infoView.layer.cornerRadius = 4
          infoView.layer.shadowOpacity = 0.2
          infoView.layer.shadowOffset = .zero
          infoView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 100)
          
          infoView.addSubview(imgUser)
          imgUser.clipsToBounds = true
          imgUser.layer.cornerRadius = 40
          imgUser.anchor(top: infoView.topAnchor, left: infoView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
          
          infoView.addSubview(lblName)
          lblName.anchor(top: infoView.topAnchor, left: imgUser.rightAnchor, bottom: nil, right: infoView.rightAnchor, paddingTop: 25, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 20)
        
          infoView.addSubview(lblNumber)
          lblNumber.anchor(top: lblName.bottomAnchor, left: imgUser.rightAnchor, bottom: nil, right: infoView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 20)
          
          
          lblName.text = defaults.string(forKey: "userName")
          let userImage = defaults.url(forKey: "userImage")
          imgUser.sd_setImage(with:userImage, completed: nil)
          
      
      }
    
   


}


// Handle the user's selection.
extension MapVC: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController!.isActive = false
    // Do something with the selected place.
//    print("Place name: \(place.name)")
//    print("Place address: \(place.formattedAddress)")
//    print("Place attributions: \(place.attributions)")
//    print("Place ID : \(place.placeID)")
    
//    let camera = GMSCameraPosition(target: place.coordinate, zoom: 15)
    let searchMaker = GMSMarker.init(position: place.coordinate)
    searchMaker.snippet = place.name
    searchMaker.title = place.formattedAddress
    searchMaker.map = googleMapsView
  }
    

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}


