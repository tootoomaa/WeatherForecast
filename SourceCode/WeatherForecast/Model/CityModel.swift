//
//  CityModel.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/26.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import Foundation
import CoreLocation

class CityModel {
  
  let name: String!
  let address: String!
  let coordinate: CLLocationCoordinate2D!
  
  
  init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
    self.name = name
    self.address = address
    self.coordinate = coordinate
  }
  
  
}
