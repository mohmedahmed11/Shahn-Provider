//
//  DriverLoadsViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/11/23.
//

import UIKit
import SwiftyJSON
import SafariServices
import CoreLocation

class DriverLoadsViewController: UIViewController {

    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var charges: [JSON] = []
    var filtredCharges: [JSON] = []
    
    let locationManager = CLLocationManager()
    
    var presenter: DriverPresenter?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = DriverPresenter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        setupLocationManager()
        setupSegments()
        if let location = locationManager.location {
            presenter?.updateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.optionsSegment.selectedSegmentIndex = 0
        presenter?.getLoads(driverId: UserDefaults.standard.integer(forKey: "userIsIn"))
    }
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func setupSegments() {
        let seperatorImage = UIImage(named: "line")
        optionsSegment.setDividerImage(seperatorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "BahijJanna", size: 16) ?? .systemFont(ofSize: 16)]
        optionsSegment.setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @IBAction func optionChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.filtredCharges = charges
        }else {
            
            self.filtredCharges = charges.filter({ $0["status"].intValue == sender.selectedSegmentIndex - 1})
        }
        
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension DriverLoadsViewController: LoadsDelegate {
    func didReciveLoads(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                if !data["data"].arrayValue.isEmpty {
                    self.charges = data["data"].arrayValue
                    self.filtredCharges = self.charges
                    self.tableView.backgroundView = nil
                } else {
                    self.addNoData()
                }
            }else {
                self.addNoData()
            }
            self.tableView.reloadData()
        case .failure(let error):
            self.faildLoading(icon: UIImage(named: "reload"), content: "حدث خطأ اعد المحاولة")
            print(error)
        }
    }
    
    func addNoData() {
        let error = noDataFoundNip()
        error.frame.size.height = 200
        error.content.text = "لاتوجد شحنات"
        self.tableView.backgroundView = error
    }
    
    func faildLoading(icon: UIImage?, content: String) {
        let error = noUserDataNotLoadedNip(nil, content)
        error.frame = self.tabBarController?.tabBar.frame ?? .zero
        error.reloadData = {
            self.presenter?.getLoads(driverId: UserDefaults.standard.integer(forKey: "userIsIn"))
            error.removeFromSuperview()
        }
        self.tabBarController?.view.addSubview(error)
    }
}

extension DriverLoadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredCharges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChargesTableViewCell
        cell.setUI(with: filtredCharges[indexPath.row])
        cell.chargeId.text = "#\(indexPath.row + 1)"
        cell.invoiceDetails = {
            self.openFile(with: self.charges[indexPath.row]["invoice"].stringValue)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func openFile(with url: String) {
        if let url = URL(string: "\(Glubal.filesBaseurl.path)\(url)"){
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}
