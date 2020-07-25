//
//  File.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/25.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import Foundation

class ForecastWeatherDataModel {
  
  let weatherImageName: String!
  let currentTemp: Double!
  let time: Int!
  
  init( weatherImageName: String, currentTemp: Double, time: Int) {
    self.weatherImageName = weatherImageName
    self.currentTemp = currentTemp
    self.time = time
  }
  
}
