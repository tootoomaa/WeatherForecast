//
//  MainTableViewCell.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/25.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
  
  // MARK: - Properties
  static let identifier = "CustomCell"
  
  let kelbin: Double = 273.15
  
  var currnetWeatherData: ForecastWeatherDataModel? {
    didSet {
      guard let data = currnetWeatherData else { return }
      // 켈빈 -> 화씨
      
      if let time = data.time,
        let imageName = data.weatherImageName {
        weatherIconImageView.image = UIImage(named: imageName)
        
        let time = Date(timeIntervalSince1970: TimeInterval(time))
        let dayString = self.dayFormatter.string(from: time)
        let timeString = self.hourMinutesFormatter.string(from: time)
        let monthDayString = self.monthDayFormatter.string(from: time)
        
        dataLabel.text = "\(monthDayString) \(dayString)"
        timeDataLabel.text = "\(timeString)"
      }
      degreeLabel.text = "\(Int(data.currentTemp - kelbin))°"
    }
  }
  
  let hourMinutesFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_kr")
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
  
  let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_kr")
    formatter.dateFormat = "EEEEEE"
    return formatter
  }()
  
  let monthDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_kr")
    formatter.dateFormat = "M.dd"
    return formatter
  }()
  
  let dataLabel: UILabel = {
    let label = UILabel()
    label.text = "5.29 월"
    label.font = .systemFont(ofSize: 15)
    label.textColor = .systemGray5
    return label
  }()
  
  let timeDataLabel: UILabel = {
    let label = UILabel()
    label.text = "13:00"
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .white
    return label
  }()
  
  let weatherIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "01d")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  let degreeLabel: UILabel = {
    let label = UILabel()
    label.text = "28°"
    label.font = .systemFont(ofSize: 35, weight: .thin)
    label.textColor = .white
    return label
  }()
  
  let separateView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  // MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = .none
    
    let mydate = DateFormatter()
    mydate.locale = Locale(identifier: "ko_kr")
    mydate.dateFormat = "HH:mm"
    
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.dateFormat = "EEEEEE"
    
    self.layoutMargins = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: -10)
    let marginGuide = self.layoutMarginsGuide
    [dataLabel, timeDataLabel, weatherIconImageView, degreeLabel, separateView].forEach{
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      
      degreeLabel.topAnchor.constraint(equalTo: topAnchor),
      degreeLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor),
      degreeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      dataLabel.bottomAnchor.constraint(equalTo: degreeLabel.centerYAnchor),
      dataLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor),
      
      timeDataLabel.topAnchor.constraint(equalTo: degreeLabel.centerYAnchor),
      timeDataLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor),
      
      weatherIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20),
      weatherIconImageView.centerYAnchor.constraint(equalTo: degreeLabel.centerYAnchor),
      weatherIconImageView.heightAnchor.constraint(equalToConstant: 50),
      weatherIconImageView.widthAnchor.constraint(equalToConstant: 50),
      
      separateView.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor),
      separateView.leadingAnchor.constraint(equalTo: weatherIconImageView.leadingAnchor),
      separateView.widthAnchor.constraint(equalTo: weatherIconImageView.widthAnchor),
      separateView.heightAnchor.constraint(equalToConstant: 1),
      
      
    ])
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
