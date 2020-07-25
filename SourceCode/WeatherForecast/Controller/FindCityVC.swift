//
//  FindCityVC.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/26.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit

class FindCityVC: UIViewController {
  
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
  
  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = CommonUI.mainColor
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = CommonUI.mainColor
    
    navigationItem.titleView = titlelabel
    
    searchBar.delegate = self
    
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
}

extension FindCityVC: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
  }
  
}
