//
//  NetworkService.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/24.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import Foundation
//import UIKit
import CoreLocation

class NetworkServcies {
  
  static private let myApi: String = "a312f4e6a3bd2a9b460d3a7075990340"
  
  // MARK: - fetch JSON data
  static func fetchCurrentWeatherDataByLocation(location: CLLocationCoordinate2D, completion: @escaping(CurrnetWeatherDataModel) -> ()) {

    //    print(location.latitude)
    //    print(location.longitude)

    let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(myApi)"

    guard let url = URL(string: urlString) else { return print("Fail to get URL in currentWeateherURL") }

    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("error", error.localizedDescription)
        return
      }

      guard let response = response as? HTTPURLResponse,
        (200..<400).contains(response.statusCode)
        else { return print("Http response Error") }

      guard let data = data else { return print("Fail to get CurrentWeather Data") }

      if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

        guard let subMainData = jsonObject["main"] as? [String: Double] else { return }
        guard let subWeatherData = jsonObject["weather"] as? [[String: Any]] else { return }

        let time = jsonObject["dt"] as! Int

        if let weatherImageName = subWeatherData[0]["icon"] as? String,
          let weatherDescription = subWeatherData[0]["main"] as? String,
          let topTemp = subMainData["temp_max"],
          let bottomTemp = subMainData["temp_min"],
          let currentTtemp = subMainData["temp"] {

          let currnetWeatherData = CurrnetWeatherDataModel.init(
            weatherImageName: weatherImageName,
            weatherDescription: weatherDescription,
            topTemp: topTemp,
            bottomTemp: bottomTemp,
            currentTemp: currentTtemp,
            time: time
          )

          completion(currnetWeatherData)
        } else {
          print("Make DataSet Fail in CurrnetWeather")
        }

      }
    }.resume()
  }
  
  static func fetchForecastWeatherData(location: CLLocationCoordinate2D, completion: @escaping(ForecastWeatherDataModel) -> ()) {

    let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(myApi)"

    guard let url = URL(string: urlString) else { return print("fail to get URL in forecast") }

    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("error", error.localizedDescription)
        return
      }

      guard let response = response as? HTTPURLResponse,
        (200..<400).contains(response.statusCode)
        else { return print("Http Error in Forecast Data")}


      guard let data = data else { return print("Fail to get Forecaset Data") }

      if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {

        // time
        guard let dailyWeatherData = jsonObject["list"] as? [[String: Any]] else { return }

        for dayWeaterData in dailyWeatherData {
          // currnet Temp
          guard let subMainData = dayWeaterData["main"] as? [String: Double] else { return }

          // icon
          guard let subWeatherData = dayWeaterData["weather"] as? [[String: Any]] else { return }

          if let time = dayWeaterData["dt"] as? Int,
            let currentTemp = subMainData["temp"],
            let weatherIcon = subWeatherData[0]["icon"] as? String {

            let weatherDate = ForecastWeatherDataModel.init(weatherImageName: weatherIcon, currentTemp: currentTemp, time: time)

            completion(weatherDate)
          } else {
            print("Make DataSet Fail in Forecast")
          }
        }
      }
    }.resume()
  }
}
