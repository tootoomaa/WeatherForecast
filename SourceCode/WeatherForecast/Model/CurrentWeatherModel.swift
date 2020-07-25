//
//  CurrentDataModel.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/22.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import Foundation

class CurrnetWeatherDataModel {
  
  let weatherImageName: String!
  let weatherDescription: String!
  let topTemp: Double!
  let bottomTemp: Double!
  let currentTemp: Double!
  let time: Int!
  
  init( weatherImageName: String, weatherDescription: String, topTemp: Double, bottomTemp: Double, currentTemp: Double, time: Int) {
    self.weatherImageName = weatherImageName
    self.weatherDescription = weatherDescription
    self.topTemp = topTemp
    self.bottomTemp = bottomTemp
    self.currentTemp = currentTemp
    self.time = time
  }
  
}
