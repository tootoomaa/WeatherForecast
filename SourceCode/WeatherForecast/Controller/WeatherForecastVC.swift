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
  
  lazy var locationManager: CLLocationManager = {
    var manager = CLLocationManager()
    manager.delegate = self
    return manager
  }()
  
  var lastLocation = CLLocationCoordinate2D()
  
  var forecastData: [ForecastWeatherDataModel] = []
  
  let networkService = NetworkServcies()
  
  let mainTableHeaderView = MainTableHeaderView()
  
  var locationAuthorizaionAccept: Bool = false
  
  // 여러개의 도시를 보여주기 위한 스크롤뷰
  let scrollView: UIScrollView = {
    let scrollView = UIScrollView(frame: .zero)
    scrollView.isPagingEnabled = true
    return scrollView
  }()
  
  // 네비게이션 바의 회전을 위한 커스텀 뷰 적용
  let customBarView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
  
  // 스크롤 되는 값의 변화에 따른 임시 값 저장 (위/아래 스크롤 구분)
  var tempValue: CGFloat = 0
  
  // 배경 화면의 이미지에 블러 효과를 주기 위한 변수 0 ~ 0.9
  var blurAlphaPoint: CGFloat = 0 {
    didSet { blurEffectView.alpha = blurAlphaPoint }
  }
  
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
  
  let titleTimeDateFormatter: DateFormatter = {
    let mydate = DateFormatter()
    mydate.locale = Locale(identifier: "ko_kr")
    mydate.dateFormat = "a HH:mm"
    return mydate
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
    
    checkAutorizationStatus()
    
    fetchWeatherData()
    
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
    
    // add right button
    navigationItem.setRightBarButtonItems([reloadBarButton], animated: true)
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
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // 블러 처리를 위한 변경 값
    if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 600 {
      blurAlphaPoint = scrollView.contentOffset.y * 1.5 / 1000 // 0 ~ 900
    }
    
    // 배경화면 이동을 위한 변경 값
    if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 500 {
      
      if tempValue > scrollView.contentOffset.y  {
        // 스크롤이 아래로 이동할 떄
        mainImageView.center.x -= scrollView.contentOffset.y / 1000
        blurEffectView.center.x -= scrollView.contentOffset.y / 1000
      } else {
        // 스크롤이 위로 이동할 때
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
    networkService.fetchCurrentWeatherDataByLocation(location: location) { (currentWeatherData) in
      DispatchQueue.main.async {
        
        // 현재 위치를 기반으로 도시 이름을 가져오는 함수
        self.geocode(latitude: location.latitude, longitude: location.longitude) { (placemark, error) in
          if let error = error {
            print("error",error.localizedDescription)
            return
          }
          // 옵셔널 처리를 위한 guard 문
          guard let place = placemark?.first else { return }
          guard let cityName = place.administrativeArea else { return }
          
          // a HH:mm 으로 Date 포멧
          if let time = currentWeatherData.time {
            let lastUpddatTime = self.titleTimeDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
            // 도시 이름과 상단의 최종 시간
            self.titleLabel.text = "\(cityName)\n\(lastUpddatTime)"
          }
          self.mainTableHeaderView.currnetWeatherData = currentWeatherData
        }
      }
    }
  }
  
  func getForecastWeatherData(location: CLLocationCoordinate2D) {
    forecastData.removeAll()
    networkService.fetchForecastWeatherData(location: location) { (forecastWeatherDataModel) in
      DispatchQueue.main.async {
        self.forecastData.append(forecastWeatherDataModel)
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: - Handler
  
  private func fetchWeatherData() {
    if let location = locationManager.location?.coordinate {
      getCurrentWeatherData(location: location)
      getForecastWeatherData(location: location)
    } else {
      print("데이터 없음")
    }
  }
  
  @objc func tabReloadButton(_ sender: UIButton) {
    
    let imageString = ["cloudy","lightning","rainy","sunny"].randomElement()!
    // 메인 이미지에 대한 에니메이션
    UIView.transition(with: self.mainImageView,
                      duration: 0.3,
                      options: .transitionCrossDissolve,
                      animations: {
                        self.mainImageView.image = UIImage(named: imageString)})
    // 버튼과 테이블에 대한 에니메이션
    UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
        self.tableView.alpha = 0
      })
      UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
        
        self.tableView.center.x += self.view.frame.width
      })
      UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
        self.tableView.alpha = 1
        self.tableView.center.x -= self.view.frame.width
      })
      UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
        self.customBarView.transform = self.customBarView.transform.rotated(by: CGFloat(Double.pi / 2))
      })
    }) { (finish) in
      if finish {
        // 에니메이션 종료 후 데이터 갱신
        guard let location = self.locationManager.location?.coordinate else { return }
        self.getCurrentWeatherData(location: location)
        self.getForecastWeatherData(location: location)
      }
    }
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
    case .authorizedWhenInUse:  // 앱 사용중 허용
      fallthrough
    case .authorizedAlways:     // 항상 허용
      startUpdatingLocation()
    @unknown default: fatalError()
    }
  }
  
  func startUpdatingLocation() {
    // 권한 확인
    let status = CLLocationManager.authorizationStatus()
    guard status == .authorizedAlways || status == .authorizedWhenInUse,
      CLLocationManager.locationServicesEnabled() else { return }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가장 정확하게 측정
    locationManager.distanceFilter = 1000.0 // 1km
    locationManager.startUpdatingLocation()
    fetchWeatherData()
  }
  
  // 사용자가 최초로 권한은 수정한 뒤 해당 권한을 통해 최초 날씨 데이터 불러옴
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    fetchWeatherData()
  }
  
  func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
      guard let placemark = placemark, error == nil else {
        completion(nil, error)
        return
      }
      completion(placemark, nil)
    }
  }
}
