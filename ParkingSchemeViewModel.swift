//
//  ParkingSchemeViewModel.swift
//  ParkingSpace
//
//  Created by AikOganisyan on 15.07.2020.
//  Copyright © 2020 Altarix. All rights reserved.
//

import UIKit

protocol ParkingSchemeViewModelDelegate: class {
    func layoutScheme()
    func showProgress()
    func hideProgress()
    func showError(_ message: String)
}

final class ParkingSchemeViewModel {
    
    weak var delegate: ParkingSchemeViewModelDelegate?
    
    init(requestSender: RequestSender = RequestSender(), parkingId: String) {
        self.requestSender = requestSender
        self.parkingId = parkingId
    }
    
    //MARK:- Внутренние свойства
    
    private let requestSender: RequestSender
    private let parkingId: String
    private let parkingPlaceSize = CGSize(width: 34, height: 60)
    private var schemeModel: ParkingSchemeModel = ParkingSchemeModel(parkingPlaces: [], lines: [])
    private var schemeDTO: ParkingSchemeDTOModel?
    
    // MARK:- Получение схемы парковки
    
    func loadScheme() {
        delegate?.showProgress()
        self.requestSender.send(
            ParkingSchemeRequest(parkingId: parkingId),
            response: ParkingSchemeDTOModel.self,
            onError: { [weak self] (error) in
                self?.delegate?.hideProgress()
                self?.delegate?.showError(error.message)
            },
            onSuccess: { [weak self] schemeDTO in
                self?.delegate?.hideProgress()
                self?.schemeDTO = schemeDTO
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.mapSchemeDTOModel()
                    DispatchQueue.main.async {
                        self?.delegate?.layoutScheme()
                    }
                }
            }
        )
    }
    
    // MARK:- Преобразование моделей
    
    private func mapSchemeDTOModel() {
        
//        code example
    }
    
}

// MARK:- SchemeViewDataSource

extension ParkingSchemeViewModel: SchemeViewDataSource {
    
    func shemeViewScheme() -> ParkingSchemeModel? {
        return schemeModel
    }
    
}
