//
//  UserManager.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
public class UserManager {
    static let shared: UserManager = UserManager()
    var contactDetails: [Contactdetails]? {
        let details = CoreDataManager.shared.fetchFilterData(Contacts.self, query: "", key: "")
        var list = [Contactdetails]()
        for item  in details ?? [] {
            let listItem = Contactdetails.init(name: item.name, phone: item.phone, address: item.address, zip: item.zip, country: item.country, id: item.id, company: item.company, photo: item.photo, age: item.age, email: item.email, website: item.website, sortId: item.sortId, profile: item.profile)
            list.append(listItem)
        }
        return list
    }
    var contacts: [Contacts]? = CoreDataManager.shared.fetchFilterData(Contacts.self, query: "", key: "")
    
    var contactList: [ContactUIModel] {
        return groupItem(list: contactDetails ?? [])
    }
    /// Order the Data fecth from Contacts List
    private func groupItem(list: [Contactdetails]) -> [ContactUIModel] {
        var contactdataList: [ContactUIModel] = []
        let nameDataList = list.map({$0.name?.prefix(1).components(separatedBy: " ").first})
        var uniqueDataList = [String?]()
        /// Remove  the duplicate
        for firstletter in nameDataList {
            if !uniqueDataList.contains(firstletter) {
                uniqueDataList.append(firstletter)
            }
        }
        let sortingOrder = UserDefaults.standard.string(forKey: "DescContactOrder") ?? ""
        let type = SortOrderType.init(rawValue: sortingOrder)
        /// based order value sordering
        uniqueDataList = uniqueDataList.sorted(by: { (item1, item2) -> Bool in
            return type == .ZToA ? item1 ?? "" > item2 ?? ""  :  item1 ?? "" < item2 ?? "" })
        for uniqueLetter in uniqueDataList {
            let groupItems = list.filter({$0.name?.prefix(1).components(separatedBy: " ").first == uniqueLetter})
            contactdataList.append(.init(title: uniqueLetter, contactList: groupItems))
        }
        return contactdataList
    }
}
