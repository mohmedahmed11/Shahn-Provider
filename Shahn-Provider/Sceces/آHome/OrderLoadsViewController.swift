//
//  OrderLoadsViewController.swift
//  Shahn
//
//  Created by Mohamed Ahmed on 4/14/23.
//

import UIKit
import SwiftyJSON
import SafariServices
import Alamofire
import ProgressHUD

class OrderLoadsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var charges: [JSON] = []
    var drivers: [JSON] = []
    var order: JSON!
    var code = 0000
    var chargeId = 0
    var serialNumber = 0
    
    var presenter: OrdersPresenter?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = OrdersPresenter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.getLoads(id: order["offer_id"].intValue)
        presenter?.getSubProviders()
    }
    
    @IBAction func addLoad() {
        if order["total_delivery"].intValue > charges.count {
            self.performSegue(withIdentifier: "addLoad", sender: nil)
        }else {
            AlertHelper.showAlert(message: "عفواً عدد الشحنات مكتمل")
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "addLoad" {
            let vc = segue.destination as! AddLoadViewController
            vc.order = order
        }else if segue.identifier == "openLocation" {
            let vc = segue.destination as! ShowAddressViewController
            vc.locationJSON = sender as? JSON
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension OrderLoadsViewController: LoadsDelegate {
    func didReciveLoads(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                if !data["data"].arrayValue.isEmpty {
                    self.charges = data["data"].arrayValue
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
    
    func didAddDriverToLoad(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.presenter?.getLoads(id: order["offer_id"].intValue)
            }else {
                AlertHelper.showAlert(message: "عفوا اعد المحاولة")
            }
        case .failure:
            AlertHelper.showAlert(message: "عفوا اعد المحاولة")
        }
    }
    
    func didReciveDrivers(with result: Result<SwiftyJSON.JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.drivers = data["data"].arrayValue
            }
        case .failure(let u):
            print(u.localizedDescription)
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
            self.presenter?.getOrders()
            error.removeFromSuperview()
        }
        self.tabBarController?.view.addSubview(error)
    }
}

extension OrderLoadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChargesTableViewCell
        cell.setUI(with: charges[indexPath.row])
        cell.driver.text = charges[indexPath.row]["driver"].string
        if charges[indexPath.row]["status"].intValue != 0 {
            cell.driverStack.isHidden = false
            cell.addDriverStack.isHidden = true
        }else {
            cell.driverStack.isHidden = true
            cell.addDriverStack.isHidden = false
            cell.invoiceBtn.isHidden = true
        }
        cell.invoiceDetails = {
            self.openFile(with: self.charges[indexPath.row]["invoice"].stringValue)
        }
        cell.fallowDriver = {
            self.performSegue(withIdentifier: "openLocation", sender: JSON(["lat": self.charges[indexPath.row]["lat"].doubleValue ,"lon": self.charges[indexPath.row]["lon"].doubleValue]))
        }
        cell.addDriver = {
            AlertHelper.showActionSheet(message: "إختر السائق", actions: self.drivers.map({$0["name"].stringValue})) { index in
                self.chargeId = self.charges[indexPath.row]["id"].intValue
                self.serialNumber = self.charges[indexPath.row]["number"].intValue
                self.sendData(driver: self.drivers[index!], id: self.charges[indexPath.row]["id"].intValue)
            }
        }
        return cell
    }
    
    func sendData(driver: JSON, id: Int) {
        self.code = Int.random(in: 1111 ... 9999)
        self.chargeId = id
        presenter?.addLoad(with: ["id": "\(id)", "order_id": order["id"].stringValue, "offer_id": order["offer_id"].stringValue,"driver_id": driver["id"].stringValue,"code": "\(code)", "action": "add_driver"])
    }
    
    func sendSMS() {
        let message = "شحنة رقم \(chargeId)# \n الرمز المتسلسل للشحنة \(serialNumber) \n رمز الشحنة \(code)"
        let parameters:Parameters = ["message": message.utf8,"phone": "966\(order["user"]["contact"])"]
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.sms.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
        }
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
