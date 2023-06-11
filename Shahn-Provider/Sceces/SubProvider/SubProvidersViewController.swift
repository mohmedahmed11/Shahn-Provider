//
//  SubProvidersViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit
import SwiftyJSON

class SubProvidersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var providers = [JSON]()
    
    var presenter: SubProvidersPresenter?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = SubProvidersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.loadSubProviders()
    }
    
    @IBAction func addProvider() {
        self.performSegue(withIdentifier: "addProvider", sender: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // segue for open location of provider
        if segue.identifier == "openLocation" {
            let vc = segue.destination as! PicAddressViewController
            vc.locationJSON = sender as? JSON
            vc.IsForPicing = false
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension SubProvidersViewController: SubProvidersViewDelegate {
    func didReciveSubProviders(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.providers = data["data"].arrayValue
                if !self.providers.isEmpty {
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
    
    func didDeleteProvider(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.presenter?.loadSubProviders()
            }else {
                AlertHelper.showAlert(message: "عفواً لم يتم الحذف")
            }
            self.tableView.reloadData()
        case .failure(let error):
            AlertHelper.showAlert(message: "حدث خطأ اعد المحاولة")
            print(error)
        }
    }
    
    func addNoData() {
        let error = noDataFoundNip()
        error.frame.size.height = 200
        error.content.text = "لايوجد مزود خدمة مسجل"
        self.tableView.backgroundView = error
    }
    
    func faildLoading(icon: UIImage?, content: String) {
        let error = noUserDataNotLoadedNip(nil, content)
        error.frame = self.tabBarController?.tabBar.frame ?? .zero
        error.reloadData = {
            self.presenter?.loadSubProviders()
            error.removeFromSuperview()
        }
        self.tabBarController?.view.addSubview(error)
    }
}

extension SubProvidersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProviderTableViewCell
        cell.setUI(with: providers[indexPath.row])
        cell.openEditView = {
            self.performSegue(withIdentifier: "editProvider", sender: self.providers[indexPath.row])
        }
        cell.deleteProvider = {
            AlertHelper.showOkCancel(message: "هل ترغب في حذف مزود الخدمة") {
                self.presenter?.deleteSubProvider(id: self.providers[indexPath.row]["id"].intValue)
            }
        }
        cell.openLocatoinView = {
            self.performSegue(withIdentifier: "openLocation", sender: self.providers[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
