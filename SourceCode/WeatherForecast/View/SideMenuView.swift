//
//  SideMenuView.swift
//  WeatherForecast
//
//  Created by 김광수 on 2020/07/26.
//  Copyright © 2020 Giftbot. All rights reserved.
//

import UIKit

class SideMenuView: UIView {
  
  // MARK: - Properties
  var weatherForecastVC: WeatherForecastVC? 
  let loginButton: UIButton = {
    let button = UIButton()
    
//    let configuration = UIImage.SymbolConfiguration.init(pointSize: 20, weight: .medium)
//
//    let symbol = UIImage(systemName: "person.circle", withConfiguration: configuration)
//
//    let imageAttachment = NSTextAttachment(image: symbol!)
//
//    var attributes = [NSAttributedString.Key: AnyObject]()
//    attributes[.foregroundColor] = UIColor.white
//    attributes[.font] = UIFont.systemFont(ofSize: 20)
//
//
//    let fullString = NSMutableAttributedString()
//    fullString.append(NSAttributedString(attachment: imageAttachment))
//    fullString.append(NSAttributedString(string: " "))
//    fullString.append(NSAttributedString(string: "로그인", attributes: attributes))
//
//    button.setAttributedTitle(fullString, for: .normal)
    button.setTitle("로그인", for: .normal)
    button.setTitleColor(.white, for: .normal)

    
    return button
  }()
  
  lazy var closeButton: UIButton = {
    let button = UIButton()
    
    let configuration =  UIImage.SymbolConfiguration.init(pointSize: 40, weight: .medium)
    let xmarkImage = UIImage(systemName: "xmark",withConfiguration: configuration)!
    
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.imageView?.tintColor = .white
    
    button.addTarget(self, action: #selector(tabCloseButton), for: .touchUpInside)
    return button
  }()
  
  let separateView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray
    return view
  }()
  
  let tableView: UITableView = {
    let tview = UITableView(frame: .zero, style: .grouped)
    return tview
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  
    backgroundColor = UIColor(red: 0.1093225107, green: 0.1337122917, blue: 0.1550391316, alpha: 1)
  
    
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  
    
    self.layoutMargins = .init(top: 10, left: -8, bottom: 10, right: 18)
    
    [ loginButton, separateView, tableView].forEach{
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
    
    [closeButton].forEach{
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      loginButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      
      closeButton.leadingAnchor.constraint(equalTo: loginButton.trailingAnchor),
      closeButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      closeButton.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
      closeButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor, multiplier: 0.1),
      closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
      
      separateView.topAnchor.constraint(equalTo: loginButton.bottomAnchor,constant: 10),
      separateView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      separateView.heightAnchor.constraint(equalToConstant: 2),
      
    ])
  
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - handler
  
  @objc func tabCloseButton() {
    print("tab cancelbutton in view")
    weatherForecastVC!.tabShowSideMenu()
    
  }
  
  
}

extension SideMenuView: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      return 5
    } else if section == 1{
      return 5
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.backgroundColor = .red
    
    return cell
  }
  
}
