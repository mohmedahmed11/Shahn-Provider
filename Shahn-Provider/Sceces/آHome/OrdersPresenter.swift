//
//  OrdersPresenter.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/18/23.
//

import Foundation
import SwiftyJSON
import ProgressHUD

protocol OrdersListDelegate {
    func didReciveOrders(with result: Result<JSON, Error>)
}

protocol PricingOffersStatusDelegate {
    func didStatusChanged(with result: Result<JSON, Error>)
}

class OrdersPresenter {
    var ordersViewController: OrdersListDelegate?
    var pricingViewController: PricingOffersStatusDelegate?
    
    convenience init(_ viewController: OrdersListDelegate) {
        self.init()
        self.ordersViewController = viewController
    }
    
    
    convenience init(_ viewController: PricingOffersStatusDelegate) {
        self.init()
        self.pricingViewController = viewController
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
                self.pricingViewController?.didStatusChanged(with: .success(data))
            case .failure(let error):
                self.pricingViewController?.didStatusChanged(with: .failure(error))
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
    
    func startProgress() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
    }
    
    func stopProgress() {
        ProgressHUD.dismiss()
    }
    
}
