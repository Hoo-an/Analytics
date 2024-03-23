//
//  ViewController.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/13.
//

import UIKit

class ViewController: UIViewController, YMBAnalyticsScreenDelegate, UITableViewDataSource {
  
  var tableView: UITableView!

  let analytics = YMBAnalytics.defaultAnalyst()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    tableView.dataSource = self
    self.view.addSubview(tableView)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell_id")
    for i in 0..<10000{
      YMBAnalytics.defaultAnalyst()?.track(event: "event_test", properties: ["key1": i, "name": "test"])
    }
    
//    for i in 0..<20 {
//      createTask(name: "name.queue.\(i)")
//    }
  }

  private func createTask(name: String) {
    let concurrentQueue = DispatchQueue(label: name, attributes: .concurrent)
    concurrentQueue.async {
      for i in 0..<1000 {
        YMBAnalytics.defaultAnalyst()?.track(event: "event_test", properties: ["key1": i, "name": name])
      }
    }
    
    concurrentQueue.async {
      for i in 0..<1000 {
        YMBAnalytics.defaultAnalyst()?.track(event: "event_test", properties: ["key1": i, "name": name])
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath)
    cell.textLabel?.text = "\(indexPath.row + 1)"
    return cell
  }
  
  func screen() -> String? {
    return "main"
  }
  
  func properties() -> YMBAnalyticsProperties? {
    return ["scene": "cms_main"]
  }
  
}

