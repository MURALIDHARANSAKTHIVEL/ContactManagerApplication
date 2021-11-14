//
//  UserManager.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
public class UserManager {
    static let shared: UserManager = UserManager()
    var contacts: [Contacts]? = CoreDataManager.shared.fetchAllData(Contacts.self)
    var contactList: [ContactUIModel] {
        return groupItem(list: contacts ?? [])
    }
    /// Order the Data fecth from Contacts List
    private func groupItem(list: [Contacts]) -> [ContactUIModel] {
        var contactdataList: [ContactUIModel] = []
        let nameDataList = list.map({$0.name?.prefix(1).components(separatedBy: " ").first})
        var uniqueDataList = [String?]()
        /// Remove  the duplicate
        for firstletter in nameDataList {
            if !uniqueDataList.contains(firstletter) {
                uniqueDataList.append(firstletter)
            }
        }
        let sortingOrder = UserDefaults.standard.bool(forKey: "DescContactOrder") /// based order value sordering
        uniqueDataList = uniqueDataList.sorted(by: { (item1, item2) -> Bool in
            return sortingOrder ? item1 ?? "" > item2 ?? ""  :  item1 ?? "" < item2 ?? "" })
        for uniqueLetter in uniqueDataList {
            let groupItems = list.filter({$0.name?.prefix(1).components(separatedBy: " ").first == uniqueLetter})
            contactdataList.append(.init(title: uniqueLetter, contactList: groupItems))
        }
        return contactdataList
    }
}
