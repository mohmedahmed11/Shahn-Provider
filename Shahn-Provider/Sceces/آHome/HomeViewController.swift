//
//  HomeViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/16/23.
//

import UIKit
import SwiftyJSON

class HomeViewController: UIViewController {
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
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
        setupSegments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presenter?.getOrders()
    }
    
    func setupSegments() {
        let seperatorImage = UIImage(named: "line")
        optionsSegment.setDividerImage(seperatorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "BahijJanna", size: 16) ?? .systemFont(ofSize: 16)]
        optionsSegment.setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @IBAction func optionChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.filtredOrders = orders
        }else {
            self.filtredOrders = orders.filter({ $0["status"].intValue == sender.selectedSegmentIndex - 1 })
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
