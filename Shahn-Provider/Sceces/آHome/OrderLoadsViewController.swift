//
//  OrderLoadsViewController.swift
//  Shahn
//
//  Created by Mohamed Ahmed on 4/14/23.
//

import UIKit
import SwiftyJSON
import SafariServices

class OrderLoadsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var charges: [JSON] = []
    var order: JSON!
    
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
            let vc = segue.destination as! PicAddressViewController
            vc.locationJSON = sender as? JSON
            vc.IsForPicing = false
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
        if charges[indexPath.row]["status"].intValue == 0 {
            cell.driverStack.isHidden = false
        }else {
            cell.driverStack.isHidden = true
        }
        cell.invoiceDetails = {
            self.openFile(with: self.charges[indexPath.row]["invoice"].stringValue)
        }
        cell.fallowDriver = {
            self.performSegue(withIdentifier: "openLocation", sender: JSON(["lat": self.charges[indexPath.row]["lat"].doubleValue ,"lon": self.charges[indexPath.row]["lon"].doubleValue]))
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
