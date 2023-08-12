//
//  HomeViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/16/23.
//

import UIKit
import SwiftyJSON
import ProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginBtn: UIView!
    
    var orders = [JSON]()
    var filtredOrders = [JSON]()
    var presenter: OrdersPresenter?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = OrdersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        loginBtn.isHidden = !UserDefaults.standard.bool(forKey: "hasDriver")
        setupSegments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.optionsSegment.selectedSegmentIndex = 0
        self.presenter?.getOrders()
    }
    
    func setupSegments() {
        let seperatorImage = UIImage(named: "line")
        optionsSegment.setDividerImage(seperatorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "BahijJanna", size: 16) ?? .systemFont(ofSize: 16)]
        optionsSegment.setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @IBAction func driverLogin() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.drivers.path)", method: .post, parameters: [ "phone": UserDefaults.standard.string(forKey: "user_phone")!, "action": "login"],  decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                if data["operation"].boolValue == true {
                    AppManager.shared.authUser = User(id: data["user"]["id"].stringValue, name: data["user"]["name"].stringValue, phone: data["user"]["phone"].stringValue, contact: data["user"]["contact"].stringValue, type: "driver", image: data["user"]["image"].stringValue)
                    AppManager.shared.authUser?.action = "login"
                    AppManager.shared.authUser?.hasProvider = data["has_provider"].boolValue
                    self.saveUser()
                }else {
                    AlertHelper.showAlert(message:  "عفواً رقم الهاتف غير موجود")
                }
                
            case .failure(let error):
                AlertHelper.showAlert(message: "عفواً فشل الدخول حاول مرة أخرى")
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUser() {
        UserDefaults.standard.set(AppManager.shared.authUser!.id, forKey: "userIsIn")
        UserDefaults.standard.set(AppManager.shared.authUser!.phone, forKey: "user_phone")
        UserDefaults.standard.set(AppManager.shared.authUser!.type!, forKey: "userType")
        UserDefaults.standard.set(AppManager.shared.authUser!.hasDriver, forKey: "hasDriver")
        UserDefaults.standard.set(AppManager.shared.authUser!.hasProvider, forKey: "hasProvider")
        self.parent?.parent?.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func optionChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.filtredOrders = orders
        }else {
            if sender.selectedSegmentIndex == 4 {
                self.filtredOrders = orders.filter({ $0["offer_status"].intValue == 4 || $0["offer_status"].intValue == 5})
            }else if sender.selectedSegmentIndex == 1 {
                self.filtredOrders = orders.filter({ $0["offer_status"].intValue == 0 || $0["offer_status"].intValue == 1})
            }else {
                self.filtredOrders = orders.filter({ $0["offer_status"].intValue == sender.selectedSegmentIndex})
            }
            
        }
        
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "orderDetails" {
            let vc = segue.destination as! OrderDetailsViewController
            vc.order = sender as? JSON
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension HomeViewController: OrdersListDelegate {
    func didReciveOrders(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.orders = data["data"].arrayValue
                if !self.orders.isEmpty {
                    self.filtredOrders = orders
                    self.tableView.backgroundView = nil
                }else {
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
        error.content.text = "لايوجد طلب حتى الآن"
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderTableViewCell
        cell.setUI(with: filtredOrders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "orderDetails", sender: filtredOrders[indexPath.row])
    }
}
