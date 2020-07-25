//
//  WeatherForecastVC.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/25.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherForecastVC: UIViewController {
  
  let locationManager = CLLocationManager()
  
  let mainTableHeaderView = MainTableHeaderView()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Souel\n 오후 20:20"
    label.textAlignment = .center
    label.textColor = .white
    label.numberOfLines = 2
    return label
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
    tableView.backgroundColor = .none
    return tableView
  }()
  
  let mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "sunny")
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = titleLabel
    
    
    
    [mainImageView,tableView].forEach{
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
  
    NSLayoutConstraint.activate([
      
      
    ])

  }
  
  // statusBar Hidden
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}

// MARK: - UITableViewDataSource
extension WeatherForecastVC: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return mainTableHeaderView
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    30
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MainTableViewCell.identifier,
      for: indexPath
      ) as? MainTableViewCell else { fatalError() }
    
    return cell
  }
  
}

// MARK: - UITableViewDelegate
extension WeatherForecastVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let naviBarHeight = self.navigationController?.navigationBar.frame.height else { return view.frame.height}
    return view.frame.height - naviBarHeight*2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }
}
