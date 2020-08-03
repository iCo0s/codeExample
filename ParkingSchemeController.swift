//
//  ParkingSchemeController.swift
//  ParkingSpace
//
//  Created by AikOganisyan on 13.07.2020.
//  Copyright © 2020 Altarix. All rights reserved.
//

import UIKit

class ParkingSchemeController: UIViewController {
    
    var viewModel: ParkingSchemeViewModel!
    
    private let schemeView: SchemeView = {
        let view = SchemeView()
        view.backgroundColor = .clear
        return view
    } ()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Бронирование места".localized()
        label.font = UIFont.avenirBold(ofSize: 20)
        label.textAlignment = .center
        return label
    } ()
    
    private let closeButton = UIButton()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return DefaultsStore.isDarkModeEnabled ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schemeView.delegate = self
        schemeView.dataSource = viewModel
        viewModel.delegate = self
        setupDarkMode()
        setupActions()
        viewModel.loadScheme()
        addSubviews()
        layoutHeader()
        layoutTitle()
        layoutCloseButton()
        layoutSchemeView()
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    //MARK: - UI
    
    private func addSubviews() {
        view.addSubview(schemeView)
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
    }
    
    private func layoutHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func layoutTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: closeButton.rightAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
    }
    
    private func layoutCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 18),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)
        ])
    }
    
    private func layoutSchemeView() {
        schemeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            schemeView.leftAnchor.constraint(equalTo: view.leftAnchor),
            schemeView.rightAnchor.constraint(equalTo: view.rightAnchor),
            schemeView.topAnchor.constraint(equalTo: view.topAnchor),
            schemeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK:- Действия
    
    @objc private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK:- ParkingSchemeViewModelDelegate

extension ParkingSchemeController: ParkingSchemeViewModelDelegate {
    
    func showError(_ message: String) {
        showErrorAlert(withMessage: message)
    }
    
    func layoutScheme() {
        schemeView.reloadData()
    }
    
}
