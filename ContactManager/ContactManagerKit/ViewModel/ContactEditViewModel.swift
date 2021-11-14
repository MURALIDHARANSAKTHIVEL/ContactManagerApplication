//
//  ContactEditViewModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
public enum KeyValueType {
    case profile
    case phone
    case email
    case website
    case address
    case none
}
enum ProfileMode {
    case edit
    case save
    var title: String {
        switch self {
        case .edit:
            return "Edit"
        case .save:
            return "Save"
        }
    }
}
protocol StoryBoardSegueIdentifier {
    static var identifier: String {get set}
}
public class ContactEditViewModel {
    public var profilemodel: Contacts? /// selected profile model
    var keyValueModel: [KeyValueModel] = [KeyValueModel]()
    var profileIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    var count: Int {
        return keyValueModel.count
    }
    func rowCount(section: Int)-> Int{
        return keyValueModel[section].value?.count ?? 0
    }
    ///Tableview Model Create
    func makeKeyValuePair() {
        var reusableList: [String] = []
        keyValueModel = []
        let profileImageData = profilemodel?.profile
        keyValueModel.append(.init(title: "profile", value: mappingProfile(), type: .profile , profileData: profileImageData))
        keyValueModel.append(.init(title: "Phone", value: getMultipleItemPair(value: profilemodel?.phone) ?? [], type: .phone))
        keyValueModel.append(.init(title: "Email", value: getMultipleItemPair(value: profilemodel?.email) ?? [], type: .email))
        keyValueModel.append(.init(title: "Website", value: getMultipleItemPair(value: profilemodel?.website) ?? [], type: .website))
        reusableList = []
        reusableList.append(profilemodel?.address ?? "")
        keyValueModel.append(.init(title: "Address", value: reusableList, type: .address))
    }
    /// For Using Array Because If user had mulitple
    /// Email, phone , address
    /// so Joined by `,`
    /// to sepearted by `,` make the list pair
    private func getMultipleItemPair(value: String? = nil) -> [String]? {
        var reusableList: [String] = []
        if let modelValue = value {
            return modelValue.components(separatedBy: ",")
        }
        reusableList.append("")
        return reusableList
    }
    /// profile UI mapping
    private func mappingProfile() -> [String] {
        var reusableList: [String] = []
        reusableList.append(profilemodel?.name ?? "")
        reusableList.append(profilemodel?.company ?? "")
        return reusableList
    }
    /// Profile Image data Set
    func setProifleDataSource(data: Data) {
        for model in keyValueModel {
            switch model.type {
            case .profile:
                model.profileData = data
            default:
                break
            }
        }
    }
    /// Clicked Once Save click from User
    func mappingUpdatedValue() {
        for item in keyValueModel {
            switch item.type {
            case .phone:
                profilemodel?.phone = item.value?.joined(separator: ",")
            case .email:
                profilemodel?.email = item.value?.joined(separator: ",")
            case .address:
                profilemodel?.address = item.value?.joined(separator: ",")
            case .website:
                profilemodel?.website = item.value?.joined(separator: ",")
            case .profile:
                profilemodel?.profile = item.profileData
                profilemodel?.name = item.value?[0]
                profilemodel?.company = item.value?[1]
            default: break
                
            }
        }
        ///To save the edit data.
        try! CoreDataManager.shared.context.save()
    }
    ///Phone number formatter
    func phoneFormatter(phonenumber: String) -> String {
        return phonenumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "")
    }
}
