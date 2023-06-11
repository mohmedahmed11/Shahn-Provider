//
//  DriverPresenter.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/11/23.
//

import Foundation
import SwiftyJSON
import ProgressHUD


class DriverPresenter {
    var ordersViewController: OrdersListDelegate?
    var pricingViewController: PricingOffersStatusDelegate?
    var addLoadViewController: AddLoadDelegate?
    var LoadsViewController: LoadsDelegate?
    var detailsViewController: DetailsDelegate?
    
    convenience init(_ viewController: OrdersListDelegate) {
        self.init()
        self.ordersViewController = viewController
    }
    
    
    convenience init(_ viewController: PricingOffersStatusDelegate) {
        self.init()
        self.pricingViewController = viewController
    }
    
    convenience init(_ viewController: AddLoadDelegate) {
        self.init()
        self.addLoadViewController = viewController
    }
    
    convenience init(_ viewController: LoadsDelegate) {
        self.init()
        self.LoadsViewController = viewController
    }
    
    convenience init(_ viewController: DetailsDelegate) {
        self.init()
        self.detailsViewController = viewController
    }
    
    func getOrders() {
        guard let request = Glubal.getOrders(userId: UserDefaults.standard.integer(forKey: "userIsIn")).getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.ordersViewController?.didReciveOrders(with: .success(data))
            case .failure(let error):
                self.ordersViewController?.didReciveOrders(with: .failure(error))
            }
        }
    }
    
    func changeOfferStatus(orderId: Int, providerId: Int, status: Int) {
        guard let request = Glubal.offersStatus.getRequest(parameters: ["provider_id": "\(providerId)", "order_id": "\(orderId)", "status": "\(status)"]) else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.detailsViewController?.didStatusChanged(with: .success(data))
            case .failure(let error):
                self.detailsViewController?.didStatusChanged(with: .failure(error))
            }
        }
    }
    
    func pricingOffer(with parameters: [String: String]) {
        startProgress()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.offersStatus.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.pricingViewController?.didStatusChanged(with: .success(data))
            case .failure(let error):
                self.pricingViewController?.didStatusChanged(with: .failure(error))
            }
        }
    }
    
    func getLoads(driverId: Int) {
        guard let request = Glubal.getDriverLoads(driverId: driverId).getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.LoadsViewController?.didReciveLoads(with: .success(data))
            case .failure(let error):
                self.LoadsViewController?.didReciveLoads(with: .failure(error))
            }
        }
    }
    
    func addLoad(with parameters: [String: String]) {
        startProgress()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.addLoad.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.addLoadViewController?.didAddLoad(with: .success(data))
            case .failure(let error):
                self.addLoadViewController?.didAddLoad(with: .failure(error))
            }
        }
    }
    
    func getSubProviders() {
        guard let request = Glubal.getSubProviders(userId: UserDefaults.standard.integer(forKey: "userIsIn"), action: "drivers").getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.addLoadViewController?.didReciveDrivers(with: .success(data))
            case .failure(let error):
                self.addLoadViewController?.didReciveDrivers(with: .failure(error))
            }
        }
    }
    
    func orderLoadsCount(offerId: Int, count: Int) {
        startProgress()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.offersStatus.path)", method: .post, parameters: ["offer_id": offerId, "total_delivery": "\(count)", "action": "total_delivery"],  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.detailsViewController?.didAddLoadsCount(with: .success(data))
            case .failure(let error):
                self.detailsViewController?.didAddLoadsCount(with: .failure(error))
            }
        }
    }
    
    func startProgress() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorBackground = .clear
        ProgressHUD.show(interaction: false)
    }
    
    func stopProgress() {
        ProgressHUD.dismiss()
    }
    
}
