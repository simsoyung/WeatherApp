//
//  Extension.swift
//  WeatherApp
//
//  Created by 심소영 on 6/19/24.
//

import UIKit

extension UILabel {
    
    func weatherLabel(){
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.textAlignment = .center
        self.textColor = .black
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.font = .systemFont(ofSize: 15, weight: .heavy)
    }
    
    func locationLabel(fontSize: CGFloat){
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.textAlignment = .center
        self.textColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.backgroundColor = .darkGray
        self.font = .systemFont(ofSize: fontSize, weight: .medium)
    }
    
}
