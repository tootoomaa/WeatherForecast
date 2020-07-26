//
//  FindCityVC.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/26.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FindCityVC: UIViewController {
  
  var locationManager: CLLocationManager?
  var matchingItems:[MKMapItem] = []
  var mapView: MKMapView? = nil
  
  let searchBar: UISearchBar = {
    let sView = UISearchBar()
    sView.barTintColor = CommonUI.mainColor
    sView.searchTextField.backgroundColor = .white
    sView.searchTextField.textColor = CommonUI.mainColor
    sView.searchTextField.placeholder = "찾을 도시 검색.."
    sView.showsCancelButton = true
    return sView
  }()
  
  let titlelabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 20)
    label.text = "새로운 위치 추가"
    label.textColor = .white
    return label
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = CommonUI.mainColor
    tableView.dataSource = self
    tableView.delegate = self
    return tableView
  }()
  
  
  // MARK: - Init
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureMainUI()
    
    configureAutoLayout()
    
    guard let locationManager = locationManager else {
      return print("Get Location Manager Fail")
    }
    
    searchCityInfomation(searchText: "서울")
    
  }
  
  private func configureMainUI() {
    
    view.backgroundColor = CommonUI.mainColor
    
    navigationItem.titleView = titlelabel
    
    searchBar.delegate = self
  }
  
  private func configureAutoLayout() {
    let safeLayout = view.safeAreaLayoutGuide

    [ searchBar, tableView ].forEach{
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor).isActive = true
      $0.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor).isActive = true
    }
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: safeLayout.topAnchor),
      
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor),
    ])
  }
  
  func searchCityInfomation(searchText: String) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchText
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
      if let error = error {
        print("error",error.localizedDescription)
        return
      } else {
        guard let responseMapItem = response?.mapItems else { return }
        self.matchingItems = responseMapItem
        self.tableView.reloadData()
      }
    }
  }
  
  
}

extension FindCityVC: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print(searchText)
    // 텍스트를 통해서 주소 검색
    searchCityInfomation(searchText: searchText)
  }
  
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    print("return")
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    matchingItems.removeAll()
    tableView.reloadData()
  }
  
}

// MARK: - UITableViewDataSource
extension FindCityVC: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    
    let item = matchingItems[indexPath.row].placemark
    
    if let cityName = item.name,
      let title = item.title,
      let countryCode = item.countryCode {
      
      //let cityCoordinate = item.coordinate
      
      cell.textLabel?.text = cityName
      cell.detailTextLabel?.text = "\(title)"
    }
    
    // cell 텍스트 및 배경색 설정
    cell.textLabel?.textColor = .white
    cell.detailTextLabel?.textColor = .white
    cell.backgroundColor = CommonUI.mainColor
    
    return cell
  }
}

// MARK: - contentsUITableViewDelegate
extension FindCityVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print(matchingItems[indexPath.row].placemark.coordinate)
    
  }
  
  
  
}
