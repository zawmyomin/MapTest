//
//  ViewController.swift
//  Test
//
//  Created by Justin Zaw on 22/04/2020.
//  Copyright © 2020 Justin Zaw. All rights reserved.
//

import UIKit
import GoogleSignIn
import CoreLocation
import GoogleMaps

class ViewController: UITableViewController {
    
    let locationManager = CLLocationManager()
    var location:[Location] = []
    var goeLocation:[Geolocation] = []
    let defaults = UserDefaults.standard
    let cellId = "cellId"
    
    let locationUrl = "https://www.haulio.io/joblist.json"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        requestCurrentLocation()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.showsVerticalScrollIndicator = false
        tableView.register(JobTableCell.self, forCellReuseIdentifier: cellId)
        
        
    }
    
    func requestCurrentLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
     
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        checkLoginStatus()
        getDataList(locationUrl)
        
    
    }
    
    func getDataList(_ url:String){
        APIClient.shared.getDatalist(url: url) { (response, status) in
            if status == 200 {
                let json = response[]
//                print("JSON>>",json)
                self.location = Location.createListLocation(json: json) as! [Location]
                self.tableView.reloadData()
            }
            
        }
    }
    
    func checkLoginStatus(){
        
        let login = defaults.bool(forKey: "loginStatus")
        if login == false {
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func setupNavigationBar(){
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationItem.title = "HAULIO"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "signOut"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 67).isActive = true
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    @objc func logOut(){
        signOut()
    }
    
    func signOut(){
        GIDSignIn.sharedInstance()?.signOut()
        defaults.removeObject(forKey: "loginStatus")
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Jobs Available"
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        let lbl: UILabel = UILabel.init(frame: CGRect(x: 10, y: 10, width: 150, height: 25))
        lbl.text = "Jobs Available"
        lbl.textColor = UIColor.white
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        vw.addSubview(lbl)
        return vw
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! JobTableCell
        
        let name:String = location[indexPath.row].company!
        let number:Int = location[indexPath.row].job_id!
        let jobNumber:String = String(number)
        let address:String = location[indexPath.row].address!
        
        let geoDic = location[indexPath.row].geolocation
        
        var laValue:NSNumber?
        var loValue:NSNumber?
        
        if geoDic != nil {
            let longValue = geoDic!["longitude"]
            let lon:NSNumber = longValue as! NSNumber
            
            let latValue = geoDic!["latitude"]
            let lat:NSNumber = latValue as! NSNumber
            
            laValue = lat
            loValue = lon
            
        }
        cell.selectionStyle = .none
        cell.lblJobNumber.text = "Job Number : \(number)"
        cell.lblAddress.text = "Address : \(address)"
        cell.lblCompany.text = "Comapny Name : \(name)"
        
        cell.getData(jobNumber: jobNumber, address: address, lat: laValue!, lon: loValue!, name: name)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    

}

extension ViewController : JobNumberDelegate{
    func passData(name: String, number: String, lat: NSNumber?, long: NSNumber?, address: String) {
        navigationItem.title = ""
        let vc = MapVC()
        vc.getJobInfo(number: number, address: address, lat: lat!, lon: long!, name: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//           print("locations = \(locValue.latitude) \(locValue.longitude)")
//        lblLocation.text = "latitude = \(locValue.latitude), longitude = \(locValue.longitude)"
    }
}

