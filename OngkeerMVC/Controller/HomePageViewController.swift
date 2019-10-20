//
//  HomePageViewController.swift
//  OngkeerMVC
//
//  Created by Nanda Mochammad on 19/10/19.
//  Copyright © 2019 Nanda Mochammad. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController, UITextFieldDelegate {
    
    let textFieldDest = UITextField()
    let textFieldOri = UITextField()
    let textFieldWeight = UITextField()
    let labelWeight = UILabel()
    let textFieldDelivery = UITextField()
    let pickerDelivery = UIPickerView()
    
    let labelTotal = UILabel()
    let labelCurrency = UILabel()
    let textFieldTotal = UITextField()
    
    let checkPriceButton = UIButton()
    
    var choosenOri = [String:Any]()
    var choosenDest = [String:Any]()
    
    let deliverMethod = ["JNE", "POS", "TIKI"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        createLayout()
    }
    
    @objc func viewTapped(){
        textFieldWeight.endEditing(true)
    }
    
    func createLayout(){
        
        textFieldDest.placeholder = "Where is the destination?"
        textFieldDest.borderStyle = .roundedRect
        textFieldDest.tag = 0
        textFieldDest.delegate = self

        self.view.addSubview(textFieldDest)
        
        textFieldDest.translatesAutoresizingMaskIntoConstraints = false
        DestinationTFConstraint(of: textFieldDest, to: self.view!.layoutMarginsGuide)
        
        textFieldOri.placeholder = "Where is the origin?"
        textFieldOri.borderStyle = .roundedRect
        textFieldOri.tag = 1
        textFieldOri.delegate = self
        
        self.view.addSubview(textFieldOri)
        
        textFieldOri.translatesAutoresizingMaskIntoConstraints = false
        OriTFConstraint(of: textFieldOri, to: textFieldDest)
        
        textFieldWeight.placeholder = "0"
        textFieldWeight.borderStyle = .roundedRect
        textFieldWeight.tag = 2
        textFieldWeight.delegate = self
        textFieldWeight.keyboardType = .numberPad
        
        self.view.addSubview(textFieldWeight)
        textFieldWeight.translatesAutoresizingMaskIntoConstraints = false
        WeigthTFConstraint()
        
        labelWeight.text = "Kg (Kilogram)"
        labelWeight.textColor = UIColor.black
        
        self.view.addSubview(labelWeight)
        labelWeight.translatesAutoresizingMaskIntoConstraints = false
        labelKGConstraint()
        
        textFieldDelivery.placeholder = "Choose Deliver Method"
        textFieldDelivery.borderStyle = .roundedRect
        textFieldDelivery.tag = 3
        textFieldDelivery.delegate = self
        
        self.view.addSubview(textFieldDelivery)
        textFieldDelivery.translatesAutoresizingMaskIntoConstraints = false
        deliverTFConstraint()
        
        checkPriceButton.setTitle("Check Price", for: .normal)
        checkPriceButton.tintColor = UIColor.white
        checkPriceButton.backgroundColor = UIColor.blue
        checkPriceButton.layer.cornerRadius = 5
        checkPriceButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(checkPriceButton)
        
        checkPriceButton.translatesAutoresizingMaskIntoConstraints = false
        buttonConstraint(of: checkPriceButton, to: self.view)
        
        pickerDelivery.isHidden = true
        pickerDelivery.dataSource = self
        pickerDelivery.delegate = self
//        pickerDelivery.frame = CGRectMake(100, 100, 100, 162)
        pickerDelivery.backgroundColor = UIColor.white
        pickerDelivery.layer.borderColor = UIColor.white.cgColor
        pickerDelivery.layer.borderWidth = 1
        
        pickerDelivery.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pickerDelivery)

        pickerDelivery.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pickerDelivery.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pickerDelivery.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        labelTotal.text = "Total"
        labelTotal.textColor = UIColor.black
        
        self.view.addSubview(labelTotal)
        labelTotal.translatesAutoresizingMaskIntoConstraints = false
        
        labelTotalConstraint()
        
        textFieldTotal.placeholder = "Rp 0"
        textFieldTotal.borderStyle = .roundedRect
        textFieldTotal.isEnabled = false
        
        self.view.addSubview(textFieldTotal)
        textFieldTotal.translatesAutoresizingMaskIntoConstraints = false
        totalTFConstraint()
        
        
    }
    
    @objc func buttonAction(sender: UIButton){
        print("Button is Tapped")
        if textFieldWeight.text == "" || textFieldDelivery.text == "" || textFieldOri.text == "" || textFieldDest.text == ""{
            let alert = UIAlertController(title: "Attention", message: "Please Fill the Data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated:  true)
        }else{
            let weight : Int? = Int(textFieldWeight.text!)! * 1000
            
            DataManager.shared.requestCost(origin: choosenOri["city_id"] as! String,
                                           destination: choosenDest["city_id"] as! String,
                                           weight: "\(weight ?? 1000)", courier: textFieldDelivery.text!) { (result) in
                                            
                                            DispatchQueue.main.async {
                                                self.textFieldTotal.text = result
                                            }
            }
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
                
        if textField.tag == 0 || textField.tag == 1{
            textField.endEditing(true)

            let worker = SearchProvinceVC()
            let destNavigation = UINavigationController(rootViewController: worker)
            worker.delegate = self
            
            if textField.tag == 0 {
                worker.sender = 0
            }else { worker.sender = 1}
            
            self.present(destNavigation, animated: true, completion: nil)
        }else if textField.tag == 3{
            textField.endEditing(true)
            pickerDelivery.isHidden = false
        }
        
    }

}

extension HomePageViewController: UpdateLayoutDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Ongkeer"
        self.view.backgroundColor = UIColor.white
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return deliverMethod[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textFieldDelivery.text = deliverMethod[row]
        pickerDelivery.isHidden = true
    }
    
    func updateLayout(tag: String, city: String, province: String, postalcode: String, city_id: String){
        print("Check Delegate")
        if tag == "0"{
            textFieldDest.text = "\(city), \(province)"
            choosenDest["city"] = city
            choosenDest["province"] = province
            choosenDest["postalcolde"] = postalcode
            choosenDest["city_id"] = city_id
        }else{
            textFieldOri.text = "\(city), \(province)"
            choosenOri["city"] = city
            choosenOri["province"] = province
            choosenOri["postalcolde"] = postalcode
            choosenOri["city_id"] = city_id

        }
    }
}

extension HomePageViewController{
    func DestinationTFConstraint(of origin: UITextField, to destination: UILayoutGuide){
        NSLayoutConstraint(item: origin,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: destination.self,
                           attribute: .top,
                           multiplier: 1,
                           constant: 20).isActive = true
    }
    
    func OriTFConstraint(of origin: UIView, to destination: UIView){
        NSLayoutConstraint(item: origin,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: destination.self,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 20).isActive = true
    }
    
    
    func buttonConstraint(of origin: UIButton, to destination: UIView){
        NSLayoutConstraint(item: origin,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: destination,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: destination,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -20).isActive = true

        NSLayoutConstraint(item: origin,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: destination,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -40).isActive = true
    }
    
    func WeigthTFConstraint(){
        NSLayoutConstraint(item: textFieldWeight,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: textFieldWeight,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: textFieldOri,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 20).isActive = true
        
        NSLayoutConstraint(item: textFieldWeight,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 100).isActive = true
    }
    
    func labelKGConstraint(){
        NSLayoutConstraint(item: labelWeight,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: textFieldWeight,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: labelWeight,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: textFieldOri,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 25).isActive = true
    }
    
    func deliverTFConstraint(){
        NSLayoutConstraint(item: textFieldDelivery,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: textFieldDelivery,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -20).isActive = true

        NSLayoutConstraint(item: textFieldDelivery,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: labelWeight,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 20).isActive = true
    }
    
    func labelTotalConstraint(){
        NSLayoutConstraint(item: labelTotal,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: labelTotal,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: textFieldDelivery,
                           attribute: .top,
                           multiplier: 1,
                           constant: 200).isActive = true
    }
    
    func totalTFConstraint(){
        NSLayoutConstraint(item: textFieldTotal,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 20).isActive = true

        NSLayoutConstraint(item: textFieldTotal,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -20).isActive = true

        NSLayoutConstraint(item: textFieldTotal,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: labelTotal,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 20).isActive = true
    }
}

