//
//  SchemeView.swift
//  ParkingSpace
//
//  Created by AikOganisyan on 22.07.2020.
//  Copyright © 2020 Altarix. All rights reserved.
//

import UIKit

protocol SchemeViewDelegate: class {
    
}

protocol SchemeViewDataSource: class {
    func shemeViewScheme() -> ParkingSchemeModel?
}

final class SchemeView: UIView {
    
    let viewModel = SchemeViewModel()
    weak var delegate: SchemeViewDelegate?
    weak var dataSource: SchemeViewDataSource?
    
    private var parkingPlaces = [ParkingPlaceView]()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 1
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    } ()
    
    private let rotatedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    
    private let zoommedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    
    private var oldRotation: CGFloat = 0
    private let rotationGestureRecognizer = UIRotationGestureRecognizer()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    //MARK:- Жизненный цикл
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupSetting()
        setupViews()
    }
    
    private func setupSetting() {
        scrollView.delegate = self
        viewModel.delegate = self
        scrollView.addGestureRecognizer(rotationGestureRecognizer)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.numberOfTapsRequired = 2
        rotationGestureRecognizer.delegate = self
        rotationGestureRecognizer.addTarget(self, action: #selector(handleRotationGesture(_:)))
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(_:)))
    }
    
    private func setupViews() {
        self.addSubview(scrollView)
        scrollView.addSubview(zoommedView)
        zoommedView.addSubview(rotatedView)
        layoutScrollView()
    }
    
    private func layoutScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    //MARK:- Действия
    
    func reloadData() {
        guard let dataSource = dataSource, let shemeModel = dataSource.shemeViewScheme() else { return }
        viewModel.updateScheme(schemeModel: shemeModel)
        
    }
    
    //MARK:- Отрисовка элементов схемы
    
    private func drawParkings() {
        let parkings = viewModel.parkings
        for parking in parkings {
            
            let rect = CGRect(
                x: parking.origin.x,
                y: parking.origin.y ,
                width: parking.size.width,
                height: parking.size.height
            )
            let placeViewModel = ParkingPlaceViewModel(parking: parking)
            let placeView = ParkingPlaceView(frame: rect)
            placeView.configure(wtih: placeViewModel)
            placeView.backgroundColor = .lightGold
            
            let angle = parking.angle
            let radians: CGFloat = .pi * angle / 180
            placeView.transform = CGAffineTransform(rotationAngle: radians)
            rotatedView.addSubview(placeView)
            parkingPlaces.append(placeView)
        }
    }
    
    private func drawLines() {
        let lines = viewModel.lines
        lines.forEach{ rotatedView.layer.addSublayer($0) }
    }
    
    //MARK:- Обработка жестов
    
    @objc private func handleRotationGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
        guard rotationGestureRecognizer === gestureRecognizer else { return }
        let value = oldRotation + gestureRecognizer.rotation
        rotatedView.transform = CGAffineTransform(rotationAngle: value)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            scrollView.isScrollEnabled = false
        } else if gestureRecognizer.state == .ended {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = rotatedView.frame.size
            calcZoomScale()
            oldRotation = value
            return
        }
    }
    
    @objc private func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer === tapGestureRecognizer else { return }
        let scale = scrollView.zoomScale * 2
        scrollView.setZoomScale(scale, animated: true)
    }
    
    //MARK:- Настройки элементов
    
    private func calcZoomScale() {
        let updatedSize = rotatedView.frame.size
        viewModel.calcZoomScale(to: updatedSize)
    }
    
    private func layoutRotatedView(with size: CGSize) {
        // Центрируем схему если высота меньше высоты экрана или задаем незначительное смещение в противном случае
        var originY:CGFloat = 0
        if scrollView.frame.height > size.height {
            originY = scrollView.frame.height/2 - size.height/2
        } else {
            originY = 50
        }
        let origin = CGPoint(x: 0, y: originY)
        zoommedView.frame = CGRect(origin: origin, size: size)
        rotatedView.frame = CGRect(origin: .zero, size: size)
    }
    
}

//MARK:- SchemeViewModelDelegate

extension SchemeView: SchemeViewModelDelegate {
    
    func layoutScheme(with size: CGSize) {
        layoutRotatedView(with: size)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        drawParkings()
        drawLines()
    }
    
    func setScrollMinScale(_ scale: CGFloat) {
        scrollView.minimumZoomScale = scale
    }
    
    func setScrollViewContentSize(_ size: CGSize) {
        scrollView.contentSize = size
    }
}

//MARK:- UIScrollViewDelegate

extension SchemeView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoommedView
    }
    
}

//MARK:- UIGestureRecognizerDelegate

extension SchemeView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Позволяем одновременно зуммить и вращать
        return true
    }
}
