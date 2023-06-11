//
//  SubProvidersPresenter.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/11/23.
//

import Foundation
import SwiftyJSON
import ProgressHUD

protocol SubProvidersViewDelegate {
    func didReciveSubProviders(with result: Result<JSON, Error>)
    func didDeleteProvider(with result: Result<JSON, Error>)
}

protocol AddSubProviderViewDelegate {
    func didCreateProvider(with result: Result<JSON, Error>)
}

class SubProvidersPresenter {
    
    var subProvidersViewController: SubProvidersViewDelegate?
    var addProviderViewController: AddSubProviderViewDelegate?
    
    init(_ subProvidersViewController: SubProvidersViewDelegate? = nil) {
        self.subProvidersViewController = subProvidersViewController
    }
    
    convenience init(_ viewController: AddSubProviderViewDelegate) {
        self.init()
        self.addProviderViewController = viewController
    }
    
    func loadSubProviders() {
        guard let request = Glubal.getSubProviders(userId: UserDefaults.standard.integer(forKey: "userIsIn"), action: "support_services").getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.subProvidersViewController?.didReciveSubProviders(with: .success(data))
            case .failure(let error):
                self.subProvidersViewController?.didReciveSubProviders(with: .failure(error))
            }
        }
    }
    
    func deleteSubProvider(id: Int) {
        guard let request = Glubal.deleteSubProvider(providerId: id, action: "delete").getRequest() else {return}
        startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.subProvidersViewController?.didDeleteProvider(with: .success(data))
            case .failure(let error):
                self.subProvidersViewController?.didDeleteProvider(with: .failure(error))
            }
        }
    }
    
    func createSubProvider(with parameters: [String: String]) {
        startProgress()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.createProvider.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                self.addProviderViewController?.didCreateProvider(with: .success(data))
            case .failure(let error):
                self.addProviderViewController?.didCreateProvider(with: .failure(error))
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
