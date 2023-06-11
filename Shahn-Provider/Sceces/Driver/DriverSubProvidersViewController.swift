//
//  DriverSubProvidersViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/12/23.
//


import UIKit
import SwiftyJSON

class DriverSubProvidersViewController: UIViewController {
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var providers = [JSON]()
    var filtredProviders = [JSON]()
    
    var presenter: SubProvidersPresenter?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = SubProvidersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        setupSegments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.optionsSegment.selectedSegmentIndex = 0
        presenter?.loadSubProviders(action: "support_services")
    }
    
    func setupSegments() {
        let seperatorImage = UIImage(named: "line")
        optionsSegment.setDividerImage(seperatorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "BahijJanna", size: 16) ?? .systemFont(ofSize: 16)]
        optionsSegment.setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @IBAction func optionChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.filtredProviders = providers
        }else {
            
            self.filtredProviders = providers.filter({ $0["service_type"].intValue == sender.selectedSegmentIndex - 1})
        }
        
        tableView.reloadData()
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
        }else if segue.identifier == "editProvider" {
            let vc = segue.destination as! AddSubProviderViewController
            vc.isForUpdate = true
            vc.provider = sender as? JSON
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension DriverSubProvidersViewController: SubProvidersViewDelegate {
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
    
    func didDeleteProvider(with result: Result<JSON, Error>) {}
    
    func addNoData() {
        let error = noDataFoundNip()
        error.frame.size.height = 200
        error.content.text = "لايوجد مزودى خدمات"
        self.tableView.backgroundView = error
    }
    
    func faildLoading(icon: UIImage?, content: String) {
        let error = noUserDataNotLoadedNip(nil, content)
        error.frame = self.tabBarController?.tabBar.frame ?? .zero
        error.reloadData = {
            self.presenter?.loadSubProviders(action: "support_services")
            error.removeFromSuperview()
        }
        self.tabBarController?.view.addSubview(error)
    }
}

extension DriverSubProvidersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DSubProviderTableViewCell
        cell.setUI(with: filtredProviders[indexPath.row])
        cell.call = {
            
        }
        cell.whatsapp = {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
