//
//  ProtocolClass.swift
//  OngkeerMVC
//
//  Created by Nanda Mochammad on 19/10/19.
//  Copyright © 2019 Nanda Mochammad. All rights reserved.
//

import Foundation

protocol UpdateLayoutDelegate: AnyObject {
    func updateLayout(tag: String, city: String, province: String, postalcode: String)
}
