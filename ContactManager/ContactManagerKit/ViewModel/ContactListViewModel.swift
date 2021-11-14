//
//  ContactListViewModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
public class ContactListViewModel {
    var contactList = UserManager.shared.contactList /// To get date Usermanger
    var ungroupedContactList = UserManager.shared.contacts /// usage: - For filter
    var filterContactList: [Contacts]? = []
    var count: Int {
        return contactList.count
    }
    func rowCount(section: Int) -> Int {
        return contactList[section].contactList!.count
    }
    subscript(section: Int) -> ContactUIModel {
        return contactList[section]
    }
    subscript(indexPath: IndexPath) -> Contacts {
        return contactList[indexPath.section].contactList![indexPath.row]
    }
    ///Mark:- searchtext = "" filterby search
    ///isActive - search or not
    ///Filter By Name or Company
    public func searchList(_ searchText: String = "", isActive: Bool = false) {
        guard isActive else {
            contactList = UserManager.shared.contactList
            return
        }
        
        filterContactList =  ungroupedContactList?.filter{ $0.name?.range(of: searchText, options: .caseInsensitive) != nil || $0.company?.range(of: searchText, options: .caseInsensitive) != nil }
    }
}
