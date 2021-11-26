//
//  contactmodel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
/// Response model
public struct Contactdetails: Codable {
    var name: String?
    var phone: String?
    var address: String?
    var zip: String?
    var country: String?
    var id: Int16?
    var company: String?
    var photo: String? {
        didSet {
            profile = imageload(from: photo ?? "")
        }
    }
    var age: Int16?
    var email: String?
    var website: String?
    var profile: Data?
    var sortId: Int16?
    public init() {}
    init(name: String?, phone: String?, address: String?, zip: String?, country: String?, id: Int16?, company: String?, photo: String?, age: Int16?, email: String?, website: String?, sortId: Int16?, profile: Data?) {
        self.name = name
        self.phone = phone
        self.address = address
        self.zip = zip
        self.country = country
        self.id = id
        self.company = company
        self.photo = photo
        self.age = age
        self.email = email
        self.website = website
        self.sortId = sortId
        self.profile = profile
    }
}
///Fetch the Image from URL convert to Data
func imageload(from url: String)-> Data {
    let url = URL(string: url)!
    
    // Fetch Image Data
    if let data = try? Data(contentsOf: url) {
        // Create Image and Update Image View
        return data
    }
    return Data()
}
/// Request
public struct ContactRequest: Codable {
    var offset: String = "0"
}

