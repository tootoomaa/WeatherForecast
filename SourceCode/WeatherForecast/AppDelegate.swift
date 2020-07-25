//
//  AppDelegate.swift
//  WeatherForecast
//
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let weatherForecastVC = WeatherForecastVC()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    window?.rootViewController = weatherForecastVC
    window?.makeKeyAndVisible()
    
    return true
  }
}
