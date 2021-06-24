//
//  FourthViewController.swift
//  projectHomeWork
//
//  Created by Владислав Вишняков on 22.06.2021.
//

import UIKit
import RealmSwift

class FourthViewController: UIViewController, UITableViewDelegate {
    
    let city = UILabel()
    let currentWeather = UILabel()
    let network = Networking()
    
    var filtreddata: [ListForecast] = [ListForecast]()
    
    
    var savedForecastDate: Results<ForecastRealm>!
    
    
    
    
    @IBOutlet weak var tableViewVisual: UITableView!
    
    func getDataFromeRealm() {
            var savedDataWeather: Results<RealmWeather>!
            savedDataWeather = try! Realm().objects(RealmWeather.self)
        savedForecastDate = try! Realm().objects(ForecastRealm.self)
            for el in savedDataWeather {
                self.city.text = String("in \(el.name)")
                self.currentWeather.text = String("\(el.temp)°")
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlMain = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=Moscow&units=metric&appid=90f8ee67bd11a69a3cad7a0b467cf053")
        updatedate(url: urlMain!)
        tableViewVisual.delegate = self
        tableViewVisual.dataSource = self
        
        network.getDataWeather(url: API.URLCurrent, params: API.URLToken) { [weak self] complition in
            
            DispatchQueue.main.async {
                self?.city.text = String("in \(complition.name)")
                self?.currentWeather.text = String("\(complition.main!.temp)°")
            }
        }
        
        city.frame = CGRect(x: 50, y: 120, width: 300, height: 200)
        city.font = UIFont.boldSystemFont(ofSize: 45)
        city.textAlignment = .center
        
        currentWeather.frame = CGRect(x: 100, y: 190, width: 400, height: 200)
        currentWeather.numberOfLines = 0
        currentWeather.font = UIFont.boldSystemFont(ofSize: 100)
        
        getDataFromeRealm()
        
        view.backgroundColor = .white
        view.addSubview(city)
        view.addSubview(currentWeather)
    }
    
    func updatedate(url: URL) {
        network.getForecasturl(url: url) { [self] complition in
            if complition.cod == "404" {
                DispatchQueue.main.async {
                    print("404 error internet")
                }
            } else {
                self.filtreddata = complition.list!.filter { ($0.dtTxt.contains("12:00:00"))
                }
                
                DispatchQueue.main.async { [self] in
                    self.tableViewVisual.reloadData()
                }
            }
        }
    }
}

extension FourthViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MyTableViewCell
        
        
        let text = savedForecastDate[indexPath.section].dtTxt[indexPath.row]
        let temp = savedForecastDate[indexPath.section].temp[indexPath.row]
        let newText = text.replacingOccurrences(of: "12:00:00", with: "", options: .literal, range: nil)
        
        cell.dateLabel.text = String("\(newText)")
        cell.tempLabel.text = String("\(temp)°")
        return cell
    }
}


