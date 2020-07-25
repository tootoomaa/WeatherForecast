//
//  TableHeaderView.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/25.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit

class MainTableHeaderView: UIView {
  
  // MARK: - Properties
  let kelbin: Double = 273.15
  
  var currnetWeatherData: CurrnetWeatherDataModel? {
    didSet {
      guard let data = currnetWeatherData else { return }
      guard let getTopTemp = data.topTemp,
        let getBottomTemp = data.bottomTemp else { return }
      // 켈빈 -> 화씨
      let currentTemp = data.currentTemp - kelbin
      let topTemp = getTopTemp - kelbin
      let bottomTemp = getBottomTemp - kelbin
      
      if let imageName = data.weatherImageName {
        weatherIconImageView.image = UIImage(named: imageName )
      }
      
      weatherStringtLabel.text = data.weatherDescription
      topBottomDegreeLabel.text = "⤓ \(bottomTemp)° ⤒ \(topTemp)°"
      degreeLabel.text = "\(floor(currentTemp*10)/10)°"
    }
  }
  
  let weatherIconImageView: UIImageView = {
     let imageView = UIImageView()
     imageView.image = UIImage(named: "01d")
     imageView.contentMode = .scaleAspectFit
     return imageView
   }()
   
   let weatherStringtLabel: UILabel = {
       let label = UILabel()
       label.text = "맑음"
       label.font = .systemFont(ofSize: 20)
       label.textColor = .white
       return label
     }()
   
   let topBottomDegreeLabel: UILabel = {
     let label = UILabel()
     label.text = "⤓ 13.0° ⤒ 23.0°"
     label.textColor = .white
     return label
   }()
   
   let degreeLabel: UILabel = {
     let label = UILabel()
     label.text = "28°"
     label.font = .systemFont(ofSize: 100, weight: .ultraLight)
     label.textColor = .white
     return label
   }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .none
    
    [weatherIconImageView, topBottomDegreeLabel, degreeLabel ].forEach{
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }
    
    [weatherStringtLabel].forEach{
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 실제 화면과 역순으로 정렬
    NSLayoutConstraint.activate([
      
      degreeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
      
      topBottomDegreeLabel.bottomAnchor.constraint(equalTo: degreeLabel.topAnchor),
      
      weatherIconImageView.bottomAnchor.constraint(equalTo: topBottomDegreeLabel.topAnchor, constant: -5),
      weatherIconImageView.heightAnchor.constraint(equalToConstant: 40),
      weatherIconImageView.widthAnchor.constraint(equalToConstant: 40),
      
      weatherStringtLabel.leadingAnchor.constraint(equalTo: weatherIconImageView.trailingAnchor),
      weatherStringtLabel.centerYAnchor.constraint(equalTo: weatherIconImageView.centerYAnchor)
      
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
