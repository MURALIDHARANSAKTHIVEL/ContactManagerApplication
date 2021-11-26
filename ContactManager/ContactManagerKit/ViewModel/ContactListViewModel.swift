//
//  ContactListViewModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import Foundation
import UIKit
import MobileCoreServices
import CoreData
public enum SortOrderType: String {
    case AToZ
    case ZToA
    case ReOrder
}

public class ContactListViewModel {
    var contactList = UserManager.shared.contactList /// To get date Usermanger
    var ungroupedContactList = UserManager.shared.contactDetails /// Usage:- reorder Shorting
    var filterContactList: [Contactdetails]? = []
    var searchIsActive: Bool = false
    static let sortOrderValue = UserDefaults.standard.string(forKey: "DescContactOrder")
    var sortOrderType: SortOrderType = .init(rawValue:  ContactListViewModel.sortOrderValue ?? "ReOrder" ) ?? .ReOrder {
        didSet {
            UserDefaults.standard.set( sortOrderType.rawValue, forKey: "DescContactOrder")
            self.searchIsActive = false
            if sortOrderType == .ReOrder {
                ungroupedContactList = UserManager.shared.contactDetails
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
    subscript(indexPath: IndexPath) -> Contactdetails? {
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
        //ungroupedContactList?.insert(model, at: index)
    }
    /// The traditional method for rearranging rows in a table view.
    public func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        /// We can use "sortBYSortId() or reorderData()" method to save reorder data
        /// self.sortBYSordId(at: sourceIndex, to: destinationIndex)
        self.reorderData(at: sourceIndex, to: destinationIndex)
    }
    
    ///Using Predicate from CoreData, Its will reoder
    private func reorderData(at sourceIndex: Int, to destinationIndex: Int) {
        if sourceIndex > destinationIndex {/// moving upward reorder
            CoreDataManager.shared.updateSortList(isupward: true,startIndex: destinationIndex, endIndex: sourceIndex)
        } else if destinationIndex > sourceIndex { /// moving downward reorder
            CoreDataManager.shared.updateSortList(isupward: false,startIndex: sourceIndex, endIndex: destinationIndex)
        }
        self.sortedOrder()
    }
    
    /// We can iterate btwn the source and destination to change the order of data
    private func sortBYSordId(at sourceIndex: Int, to destinationIndex: Int) {
        let contacts = CoreDataManager.shared.fetchFilterData(Contacts.self, query: "", key: "") ?? []
        if abs(sourceIndex - destinationIndex) == 1   {/// near data reorder
            let destinationsortId = ungroupedContactList?[destinationIndex].sortId ?? 0
            let sourcesortId = ungroupedContactList?[sourceIndex].sortId ?? 0
            contacts[sourceIndex].sortId = destinationsortId
            contacts[destinationIndex].sortId = sourcesortId
        } else if sourceIndex < destinationIndex { /// moving downward reorder
            let destinationsortId = ungroupedContactList?[destinationIndex].sortId ?? 0
            for row in sourceIndex + 1 ..< destinationIndex+1 {
                contacts[row].sortId = ungroupedContactList?[row - 1].sortId ?? 0
            }
            contacts[sourceIndex].sortId = destinationsortId

        } else if destinationIndex  < sourceIndex  { /// moving upward reorder
            let destinationsortId = ungroupedContactList?[destinationIndex].sortId ?? 0
            for row in destinationIndex  ..< sourceIndex {
                contacts[row].sortId = (ungroupedContactList?[row + 1].sortId)!
            }
            contacts[sourceIndex].sortId = destinationsortId

        }
        self.sortedOrder()
    }
    /// Saving the sorted order in the core database
    public func sortedOrder() {
        /// save the shorted order in core data
        if CoreDataManager.shared.context.hasChanges {
            try! CoreDataManager.shared.context.save()
            ungroupedContactList =  UserManager.shared.contactDetails
        }
        ungroupedContactList =  UserManager.shared.contactDetails
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
    public func pickSelectedContact(index: IndexPath) -> Contacts {
        let contacts = CoreDataManager.shared.fetchFilterData(Contacts.self, query: "", key: "") ?? []
        if sortOrderType == .ReOrder {
            return contacts[index.row]
        }
        /// Commmon this store to the SortId to help to fetch excat details selcted
        let details =  contactList[index.section].contactList?[index.row]
        return contacts.first(where: { $0.sortId == details?.sortId }) ?? Contacts()
    }
}
