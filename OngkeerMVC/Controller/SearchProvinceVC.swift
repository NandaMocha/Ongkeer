//
//  ViewController.swift
//  OngkeerMVC
//
//  Created by Nanda Mochammad on 19/10/19.
//  Copyright © 2019 Nanda Mochammad. All rights reserved.
//

import UIKit

class SearchProvinceVC: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    lazy var searchBar:UISearchBar = UISearchBar()
    
    private var tableView : UITableView!
    
    var dataProvince = DataManager.shared.provinceCoreData
    var dataCity = DataManager.shared.cityCoreData
    
    var showDataProvince = [PROVINCE]()
    var showDataCity = [CITY]()
    var tempData = [CITY]()
    
    var searchActive = false
    weak var delegate: UpdateLayoutDelegate?
    var sender = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
                
        createLayout()
        
    }
    
    func createLayout(){
        let frame = self.view.frame
        
        tableView = UITableView(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.searchBarStyle = .default
        searchBar.placeholder = " Search City Origin . . ."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        
        self.view.addSubview(tableView)
    }
    
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tempData = showDataCity.filter({ (text) -> Bool in
            let tmp: NSString = text.city_name! as NSString
            let range = tmp.range(of: searchText, options: .caseInsensitive)
            return range.location != NSNotFound
        })
        if(tempData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "loadDataProvince"){
            DataManager.shared.requestProvince()
            DataManager.shared.requestCity()
            
            DataManager.shared.loadFromCoreData { (provinceData, cityData) in
                self.dataProvince = provinceData
                self.dataCity = cityData
                
                self.showDataProvince = self.dataProvince
                self.showDataCity = self.dataCity
            }
        }else{
            
            DataManager.shared.loadFromCoreData { (provinceData, cityData) in
                self.dataProvince = provinceData
                self.dataCity = cityData
                
                self.showDataProvince = self.dataProvince
                self.showDataCity = self.dataCity
            }
        }
    }
    
}

extension SearchProvinceVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive){
            return tempData.count
        }else{
            if showDataCity.count > 1{
                return showDataCity.count
            }else{
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TheCell")
        
        if (searchActive){
            cell.textLabel!.text = "\(tempData[indexPath.row].city_name ?? "No Data"), \(tempData[indexPath.row].province_name ?? "No Data")"
            cell.detailTextLabel!.text = "Postal Code: \(tempData[indexPath.row].postal_code ?? "No Data")"
        }else{
            cell.textLabel!.text = "\(showDataCity[indexPath.row].city_name ?? "No Data"), \(showDataCity[indexPath.row].province_name ?? "No Data")"
            cell.detailTextLabel!.text = "Postal Code: \(showDataCity[indexPath.row].postal_code ?? "No Data")"

        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("Set Delegate")
        if sender == 0{
            self.delegate?.updateLayout(tag: "0",
                                        city: "\(showDataCity[indexPath.row].city_name ?? "")",
                                        province: "\(showDataCity[indexPath.row].province_name ?? "")",
                                        postalcode: "\(showDataCity[indexPath.row].postal_code ?? "")")
        }else{
            self.delegate?.updateLayout(tag: "1",
            city: "\(showDataCity[indexPath.row].city_name ?? "")",
            province: "\(showDataCity[indexPath.row].province_name ?? "")",
            postalcode: "\(showDataCity[indexPath.row].postal_code ?? "")")
        }
        self.dismiss(animated: true) {
           
        }
        
    }
    
    
}

