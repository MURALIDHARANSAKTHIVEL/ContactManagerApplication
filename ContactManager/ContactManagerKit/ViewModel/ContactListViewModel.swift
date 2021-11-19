//
//  ContactListViewModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
import UIKit
import MobileCoreServices
public enum SortOrderType: String {
    case AToZ
    case ZToA
    case ReOrder
}
public class ContactListViewModel {
    var contactList = UserManager.shared.contactList /// To get date Usermanger
    var ungroupedContactList = UserManager.shared.contacts /// Usage:- reorder Shorting
    var filterContactList: [Contacts]? = []
    var searchIsActive: Bool = false
   static let sortOrderValue = UserDefaults.standard.string(forKey: "DescContactOrder")
    var sortOrderType: SortOrderType = .init(rawValue:  ContactListViewModel.sortOrderValue ?? "ReOrder" ) ?? .ReOrder {
        didSet {
            UserDefaults.standard.set( sortOrderType.rawValue, forKey: "DescContactOrder")
            self.searchIsActive = false
            if sortOrderType == .ReOrder {
                ungroupedContactList = UserManager.shared.contacts
            } else {
                contactList = UserManager.shared.contactList
            }
        }
    }
    var secondCount: Int {
        if searchIsActive || sortOrderType == .ReOrder {
            return 1
        }
        return contactList.count
    }
    func rowCount(section: Int) -> Int {
        if searchIsActive == true {
            return filterContactList?.count ?? 0
        } else if sortOrderType == .ReOrder {
            return ungroupedContactList?.count ?? 0
        }
        return contactList[section].contactList!.count
    }
    subscript(section: Int) -> ContactUIModel? {
        return contactList[section]
    }
    subscript(indexPath: IndexPath) -> Contacts? {
        if searchIsActive == true {
            return filterContactList![indexPath.row]
        } else if sortOrderType == .ReOrder {
            return ungroupedContactList![indexPath.row]
        }
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
        filterContactList =  ungroupedContactList?.filter { $0.name?.range(of: searchText, options: .caseInsensitive) != nil || $0.company?.range(of: searchText, options: .caseInsensitive) != nil }
    }
    /// The method for adding a new item to the table view's data model.
    public func addItem(_ model: Contacts, at index: Int) {
        ungroupedContactList?.insert(model, at: index)
    }
    /// The traditional method for rearranging rows in a table view.
    public func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let sourcePriorityModel = ungroupedContactList![sourceIndex]
        ungroupedContactList?.remove(at: sourceIndex)
        ungroupedContactList?.insert(sourcePriorityModel, at: destinationIndex)
        self.reorder(at: sourceIndex, to: destinationIndex)
    }
    private func reorder(at sourceIndex: Int, to destinationIndex: Int) {
        let contacts = UserManager.shared.contacts
        for (index ,item) in (ungroupedContactList ?? []).enumerated() {
            let groupItem = item as Contacts
            let contactItem = contacts?.filter { $0 == groupItem}.first
            contactItem?.sortId = Int16(index)
        }
        self.sortedOrder()
    }
    public func sortedOrder() { /// save the shorted order in core data
    try! CoreDataManager.shared.context.save()
    }
}
//MARK: - Drag and drag helper method
extension ContactListViewModel {
    /**
     A helper function that serves as an interface to the data mode, called
     by the `tableView(_:itemsForBeginning:at:)` method.
     */
    public func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard sortOrderType == .ReOrder && searchIsActive == false else {
            return []
        }
        let model = ungroupedContactList?[indexPath.row]
        
        let data = model?.name?.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
}
