//
//  contactmodel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
/// Response model
public class Contact: Codable {
    let name: String?
    let phone: String?
    let address: String?
    let zip: String?
    let country: String?
    let id: Int?
    let company: String?
    let photo: String?
    let age: Int?
    let email: String?
    let website: String?
}
/// Request
public struct ContactRequest: Codable {
    var offset: String = "0"
}
