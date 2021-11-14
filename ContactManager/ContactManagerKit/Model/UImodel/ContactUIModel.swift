//
//  ContactUIModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
import UIKit
///UI Contact Model
public struct ContactUIModel {
    public var title: String?
    public var contactList: [Contacts]?
}
///Edit Profile UI Model
public class KeyValueModel {
    public var title: String?
    public var value: [String]?
    public var type: KeyValueType?
    public var profileData: Data? /// Image data model
    init(title: String, value: [String]?, type: KeyValueType? , profileData: Data? = Data()) {
        self.title = title
        self.value = value
        self.type  = type
        self.profileData = profileData
    }
}
