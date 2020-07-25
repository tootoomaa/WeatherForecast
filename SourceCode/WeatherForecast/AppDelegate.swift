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
    
    let navigationController = UINavigationController(rootViewController: weatherForecastVC)
    let naviBar = navigationController.navigationBar
    naviBar.setBackgroundImage(UIImage(), for: .default)
    naviBar.shadowImage = UIImage()
    naviBar.backgroundColor = .clear
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    
    return true
  }
}
