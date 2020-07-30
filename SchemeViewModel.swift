//
//  SchemeViewModel.swift
//  ParkingSpace
//
//  Created by AikOganisyan on 24.07.2020.
//  Copyright © 2020 Altarix. All rights reserved.
//

import UIKit

protocol SchemeViewModelDelegate: class {
    func layoutScheme(with size: CGSize)
    func setScrollMinScale(_ scale: CGFloat)
    func setScrollViewContentSize(_ size: CGSize)
}

final class SchemeViewModel {
    
    var delegate: SchemeViewModelDelegate?
    
    //MARK:- Отображение
    
    var parkings: [ParkingSchemeModel.Parking] {
        return schemeModel.parkingPlaces
    }
    
    var lines: [CAShapeLayer] {
        var lines: [CAShapeLayer] = []
        for lineObject in schemeModel.lines {
            if lineObject.points.count > 0 {
                var line = lineObject
                let path = UIBezierPath()
                let startPoint = line.points.removeFirst()
                path.move(to: startPoint)
                for point in line.points {
                    path.addLine(to: point)
                }
                let lineShape = CAShapeLayer()
                lineShape.path = path.cgPath
                let color: UIColor = DefaultsStore.isDarkModeEnabled ? .lightGrayAnother : UIColor(hex: 0xB4B4B4)
                lineShape.strokeColor = color.cgColor
                lineShape.fillColor = nil
                lineShape.lineWidth = 5
                lines.append(lineShape)
            }
        }
        return lines
    }
    
    //MARK:- Внутренние свойства
    
    private let widthOffset: CGFloat = 60
    private let heightOffset: CGFloat = 60
    private let parkingPlaceSize = CGSize(width: 34, height: 60)
    private var schemeRect: CGRect = .zero
    private var schemeModel: ParkingSchemeModel!
    
    // MARK:- Настройки схемы
    
    func updateScheme(schemeModel: ParkingSchemeModel) {
        self.schemeModel = schemeModel
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.recalculateCoordinates()
            DispatchQueue.main.async {
                let schemeSize = self.schemeRect.size
                self.calcZoomScale(to: schemeSize)
                self.delegate?.layoutScheme(with: schemeSize)
            }
        }
    }
    
    func calcZoomScale(to shemeSize: CGSize) {
        var scale: CGFloat = 1.0
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if shemeSize.width > screenWidth {
            scale = screenWidth / shemeSize.width
        } else {
            if shemeSize.width > shemeSize.height {
                scale = screenWidth / shemeSize.width
            } else {
                scale = screenHeight / shemeSize.height
            }
        }
        
        
        delegate?.setScrollMinScale(scale)
        delegate?.setScrollViewContentSize(shemeSize)
    }
    
    private func recalcSchemeRect() {
        guard let schemeModel = schemeModel, schemeModel.parkingPlaces.count != 0 else { return }
        let firstPlace = schemeModel.parkingPlaces[0]
        var minX: CGFloat = firstPlace.origin.x
        var minY: CGFloat = firstPlace.origin.y
        var maxX: CGFloat = firstPlace.origin.x + firstPlace.size.width
        var maxY: CGFloat = firstPlace.origin.y + firstPlace.size.height
        
        //Находим минимальные и максимальные координаты, для того чтобы обрезать схему (допустим если координаты начинаются не с (0.0))
        schemeModel.parkingPlaces.forEach { place in
            if place.origin.x < minX {
                minX = place.origin.x
            }
            if place.origin.y < minY {
                minY = place.origin.y
            }
            //Прибавляем ширину/высоту прямоугольника, т.к. мы здесь оперируем ориджинами (координата верхнего левого угла)
            if place.origin.x > maxX {
                maxX = place.origin.x + place.size.width
            }
            if place.origin.y > maxY {
                maxY = place.origin.y + place.size.height
            }
        }
        
        schemeModel.lines.forEach { line in
            line.points.forEach { point in
                if point.x < minX {
                    minX = point.x
                }
                if point.y < minY {
                    minY = point.y
                }
                if point.x > maxX {
                    maxX = point.x
                }
                if point.y > maxY {
                    maxY = point.y
                }
            }
        }
        
        //Размеры итогового обрезанного прямоугольника с ориджином в точке в левом верхнем углу
        //Увеличиваем площадь схемы для боллее красивой визуализации
        let width = maxX - minX + widthOffset
        let height = maxY - minY + heightOffset
        let rectOrigin = CGPoint(x: minX, y: minY)
        let rectSize = CGSize(width: width, height: height)
        let rect = CGRect(origin: rectOrigin, size: rectSize)
        schemeRect = rect
    }
    
    private func recalculateCoordinates() {
        //Вычитаем половину отступа для того, чтобы на схеме поместились все элементы (в дальнейшем происходит перерасчет координат)
        //Смещение по ширине равно величине среза слева(фактически min координата x), плюс добавляем некоторое значение, чтобы добавить небольшое пространство с краёв
        //Смещение по высоте равно величине среза сверху(фактически min координата y), плюс добавляем некоторое значение, чтобы добавить небольшое пространство с краёв
        recalcSchemeRect()
        let cuttedLeftOffset = schemeRect.origin.x - widthOffset/2
        let cuttedTopOffset = schemeRect.origin.y - heightOffset/2

        for (index, _) in schemeModel.parkingPlaces.enumerated() {
            schemeModel.parkingPlaces[index].origin.x -= cuttedLeftOffset
            schemeModel.parkingPlaces[index].origin.y -= cuttedTopOffset
        }
        //Для каждой линии нужно сместить координаты каждой точки
        for (index, _) in schemeModel.lines.enumerated() {
            //Изменяем координаты каждой точки, входящей в линию
            for (indexOfPoint, _) in schemeModel.lines[index].points.enumerated() {
                schemeModel.lines[index].points[indexOfPoint].x -= cuttedLeftOffset
                schemeModel.lines[index].points[indexOfPoint].y -= cuttedTopOffset
            }
        }
    }
    
}
