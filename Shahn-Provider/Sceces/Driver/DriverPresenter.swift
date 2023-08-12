//
//  DriverPresenter.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/11/23.
//

import Foundation
import SwiftyJSON
import ProgressHUD

protocol DriverLoadsDelegate {
    func didReciveLoads(with result: Result<JSON, Error>)
    func didStatusChanged(with result: Result<JSON, Error>)
}

protocol SupoortViewDelegate {
    func didReciveSubProviders(with result: Result<JSON, Error>)
}

class DriverPresenter {
    var driverLoadsViewController: DriverLoadsDelegate?
    var supportView: SupoortViewDelegate?
    
    convenience init(_ viewController: DriverLoadsDelegate) {
        self.init()
        self.driverLoadsViewController = viewController
    }
    
    convenience init(_ viewController: SupoortViewDelegate) {
        self.init()
        self.supportView = viewController
    }
    
    
    
    func updateLocation(lat: Double, lon: Double) {
        startProgress()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.drivers.path)", method: .post, parameters: ["lat": "\(lat)", "lon": "\(lon)", "driver_id": UserDefaults.standard.string(forKey: "userIsIn")!, "action": "update_location"],  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
        }
    }
    
    func changeLoadStatus(orderId: Int, loadId: Int, OfferId: Int, driverId: Int) {
        guard let request = Glubal.loadStatus(chargeId: loadId, deliverId: OfferId, orderId: orderId, driverId: driverId).getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.driverLoadsViewController?.didStatusChanged(with: .success(data))
            case .failure(let error):
                self.driverLoadsViewController?.didStatusChanged(with: .failure(error))
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
                self.driverLoadsViewController?.didReciveLoads(with: .success(data))
            case .failure(let error):
                self.driverLoadsViewController?.didReciveLoads(with: .failure(error))
            }
        }
    }
    
    func loadSubProviders(action: String = "all_drivers") {
        guard let request = Glubal.getSubProviders(userId: UserDefaults.standard.integer(forKey: "userIsIn"), action: action).getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.supportView?.didReciveSubProviders(with: .success(data))
            case .failure(let error):
                self.supportView?.didReciveSubProviders(with: .failure(error))
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
                self.supportView?.didReciveSubProviders(with: .success(data))
            case .failure(let error):
                self.supportView?.didReciveSubProviders(with: .failure(error))
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
