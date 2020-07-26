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
  
  // MARK: - Properties
  let locationManager = CLLocationManager()
  let lastLocation = CLLocationCoordinate2D()
  
  var forecastData: [ForecastWeatherDataModel] = []
  
  let mainTableHeaderView = MainTableHeaderView()
  
  // 네비게이션 바의 회전을 위한 커스텀 뷰 적용
  let customBarView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
  
  // 스크롤 되는 값의 변화에 따른 임시 값 저장 (위/아래 스크롤 구분)
  var tempValue: CGFloat = 0
  
  // 배경 화면의 이미지에 블러 효과를 주기 위한 변수 0 ~ 0.9
  var blurAlphaPoint: CGFloat = 0 {
    didSet { blurEffectView.alpha = blurAlphaPoint }
  }
  
  // SideMenu 관련 Properties
  
  // 왼쪽 상단 버튼 클릭시 보여지는 사용자 프로필 뷰
  var sideMenuView = SideMenuView()
  var isShowDetailView: Bool = false
  
  // 위아래 스크롤 시 블러 처리
  let blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .systemMaterialDark)
    let view = UIVisualEffectView(effect: blurEffect)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.alpha = 0
    return view
  }()
  
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
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
    
    locationManager.delegate = self
    
    checkAutorizationStatus()
    
    guard let location = locationManager.location?.coordinate else { return }
    getCurrentWeatherData(location: location)
    getForecastWeatherData(location: location)
    
    configureAutoLayout()
  }
  
  private func configureNavigationBar() {
    self.navigationItem.titleView = titleLabel

    // right Bar Button [ reloadData ]
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
    let reloadImage = UIImage(systemName: "arrow.clockwise", withConfiguration: imageConfigure)
    
    customBarView.backgroundColor = .none
    
    let customBarButton = UIButton()
    customBarButton.setImage(reloadImage, for: .normal)
    customBarButton.backgroundColor = .none
    customBarButton.frame = customBarView.frame
    customBarButton.tintColor = .white
    
    customBarButton.autoresizesSubviews = true
    customBarButton.autoresizingMask = [.flexibleWidth , .flexibleHeight]
    customBarButton.addTarget(self, action: #selector(tabReloadButton(_:)), for: .touchUpInside)
    customBarView.addSubview(customBarButton)
    
    let reloadBarButton = UIBarButtonItem.init(customView: customBarView)
    
    // right Bar button [ plus ]
    
    let plusImage = UIImage(systemName: "plus", withConfiguration: imageConfigure)
    let addCityButton = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(tabAddCityButton))
    
    addCityButton.tintColor = .white
    
    // add right button
    navigationItem.setRightBarButtonItems([reloadBarButton, addCityButton], animated: true)
    
    // left Bar Button
    
    let detailMenuImage = UIImage(systemName: "line.horizontal.3", withConfiguration: imageConfigure)
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: detailMenuImage,
      style: .plain,
      target: self,
      action: #selector(tabShowSideMenu)
    )
    navigationItem.leftBarButtonItem?.tintColor = .white
  }
  
  private func configureAutoLayout() {
    
    [mainImageView, blurEffectView].forEach{
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20).isActive = true
      $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    [tableView].forEach{
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    mainImageView.addSubview(blurEffectView)
    blurEffectView.frame = mainImageView.frame
    
    [sideMenuView].forEach{
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      sideMenuView.topAnchor.constraint(equalTo: view.topAnchor),
      sideMenuView.trailingAnchor.constraint(equalTo: view.leadingAnchor),
      sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      sideMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
    ])
    
    sideMenuView.closeButton.addTarget(self, action: #selector(tabShowSideMenu), for: .touchUpInside)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // 블러 처리를 위한 변경 값
    if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 600 {
      blurAlphaPoint = scrollView.contentOffset.y * 1.5 / 1000 // 0 ~ 900
    }
    
    // 배경화면 이동을 위한 변경 값
    if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 500 {
      
      if tempValue > scrollView.contentOffset.y  {
        mainImageView.center.x -= scrollView.contentOffset.y / 1000
        blurEffectView.center.x -= scrollView.contentOffset.y / 1000
      } else {
        mainImageView.center.x += scrollView.contentOffset.y / 2000
        blurEffectView.center.x += scrollView.contentOffset.y / 2000
      }
      tempValue = scrollView.contentOffset.y
    }
  }
  
  // statusBar Hidden
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  // MARK: - Network Handler
  func getCurrentWeatherData(location: CLLocationCoordinate2D) {
    NetworkServcies.fetchCurrentWeatherDataByLocation(location: location) { (currentWeatherData) in
      DispatchQueue.main.async {
        if let time = currentWeatherData.time {
          let mydate = DateFormatter()
          mydate.locale = Locale(identifier: "ko_kr")
          mydate.dateFormat = "a HH:mm"
          
          let lastUpddatTime = mydate.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
          
          self.titleLabel.text = "Seoul\n\(lastUpddatTime)"
        }
        
        self.mainTableHeaderView.currnetWeatherData = currentWeatherData
      }
    }
  }
  
  func getForecastWeatherData(location: CLLocationCoordinate2D) {
    print("remove Start")
    forecastData.removeAll()
    print("remove Finish")
    NetworkServcies.fetchForecastWeatherData(location: location) { (forecastWeatherDataModel) in
      DispatchQueue.main.async {
        print("Append Start")
        self.forecastData.append(forecastWeatherDataModel)
        print("Append finish")
        print("reload Start")
        self.tableView.reloadData()
        print("reload Start")
      }
    }
  }
  
  // MARK: - Handler
  
  @objc func tabReloadButton(_ sender: UIButton) {
    
    UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
      })
      UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
      })
      UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
      })
      UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
      })
    }) { (finish) in
      if finish {
        guard let location = self.locationManager.location?.coordinate else { return }
        self.getCurrentWeatherData(location: location)
        self.getForecastWeatherData(location: location)
      }
    }
  }
  
  @objc func tabShowSideMenu() {
    if isShowDetailView {
      // 프로필 디테일뷰가 이미 보여진 경우 ( 보임 -> 숨김 )
      
      UIView.animate(withDuration: 0.5) {
        // view 자체를 옮기며 오토 레이아웃이 재대로 동작을 안하는듯
        // view 위에 올라가 있는 대상만 이동 위치를 변경하는 에니메이션 적용
//        self.topBlurAlphaPoint = 0
        guard let naviBar = self.navigationController?.navigationBar else { return }
        [naviBar, self.mainImageView, self.tableView, self.sideMenuView].forEach {
          $0?.center.x = ($0?.center.x)! - self.view.frame.width*0.7
        }
      }
    } else {
      // 프로필 디테일뷰가 닫혀있는 경우 ( 숨김 -> 보임 )
      UIView.animate(withDuration: 0.5) {
//        self.topBlurAlphaPoint = 0.9
        guard let naviBar = self.navigationController?.navigationBar else { return }
        [naviBar, self.mainImageView, self.tableView, self.sideMenuView].forEach {
          $0?.center.x = ($0?.center.x)! + self.view.frame.width*0.7
        }
      }
    }
    isShowDetailView.toggle()
  }
  
  @objc func tabAddCityButton() {
    print("tabAddCityButton")
    let findCityVC = FindCityVC()
    findCityVC.locationManager = locationManager
    navigationController?.pushViewController(findCityVC, animated: true)
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
    return forecastData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MainTableViewCell.identifier,
      for: indexPath
      ) as? MainTableViewCell else { fatalError() }
    
    cell.currnetWeatherData = forecastData[indexPath.row]
    
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

// MARK: - CLLocationManagerDelegate
extension WeatherForecastVC: CLLocationManagerDelegate {
  func checkAutorizationStatus() {
    
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted, .denied : break
    case .authorizedWhenInUse:
      fallthrough
    case .authorizedAlways:
      startUpdatingLocation()
    @unknown default: fatalError()
    }
  }
  
  func startUpdatingLocation() {
    let status = CLLocationManager.authorizationStatus()
    guard status == .authorizedAlways || status == .authorizedWhenInUse,
      CLLocationManager.locationServicesEnabled() else { return }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가장 정확하게 측정
    locationManager.distanceFilter = 1000.0 // 1km
    locationManager.startUpdatingLocation()
  }
}
