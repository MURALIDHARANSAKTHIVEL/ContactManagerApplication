//
//  CoreDataManager.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import CoreData
///Create for Generic Manager
public class CoreDataManager {
    static let shared = CoreDataManager.init()
    let context = AppDelegate().persistentContainer.viewContext
    /// T - Cusotm entity
    func fetchAllData<T: NSManagedObject>(_ entity: T.Type) -> [T]? {
        
        let fetchRequest = T.fetchRequest()
        let data = try? context.fetch(fetchRequest) as? [T]
        return data
    }
    /// Insert the Data into Core data
    func insertData<T>(model: T, at: Int16 = 0) {
        if let item = model as? Contactdetails { /// Based on T - Model will unwraped
            let datamodel = Contacts(context: context)
            datamodel.address = item.address
            datamodel.id = Int16(item.id ?? 0)
            datamodel.name = item.name
            datamodel.phone = item.phone
            datamodel.photo = item.photo
            datamodel.company = item.company
            datamodel.zip = item.zip
            datamodel.age = Int16(item.age ?? 0)
            datamodel.address = item.address
            datamodel.country = item.country
            datamodel.email = item.email
            datamodel.website = item.website
            datamodel.sortId = at
            datamodel.profile = imageload(from: item.photo ?? "")
            /// Store Image to BinaryData
            ///Save into DB
            saveData()
        }
    }
    
    func updateSortList( key: String = "", isupward: Bool = false, startIndex: Int, endIndex: Int) {
        let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
            let sort = NSSortDescriptor(key: "sortId", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            let pred = NSPredicate(format: "sortId >= %@ AND sortId <= %@", String(startIndex), String(endIndex))
            fetchRequest.predicate = pred
        let data = try! context.fetch(fetchRequest)
        if data.count > 0 {
            var i =  isupward ? 0 : 1
            if isupward {
                let endDataIndex = data[0].sortId
                data[data.count - 1].sortId = endDataIndex
            } else {
                let endDataIndex = data[data.count - 1].sortId
                data[0].sortId = endDataIndex
            }
            while i <= data.count - 1 {
                if isupward && i == data.count - 1 {
                    break
                }
                data[i].sortId = isupward ? data[i].sortId + 1 : data[i].sortId - 1
                i = i + 1
            }
        }
        saveData()
    }
    
    /// Filter  the Data based on  query
    func fetchFilterData<T: NSManagedObject>(_ entity: T.Type, query: String, key: String = "" )-> [T]? {
       
        let fetchRequest = T.fetchRequest()
      // if key != "" {
            let sort = NSSortDescriptor(key: "sortId", ascending: true)
            fetchRequest.sortDescriptors = [sort]
        //}
        if query != "" {
            let pred = NSPredicate(format: query)
            fetchRequest.predicate = pred
        }
        let data = try? context.fetch(fetchRequest) as? [T]
        return data
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
    func saveData() {
        ///Save into DB
        try! context.save()
        
    }
    func delete<T>(model: T) {
        if let deletemodel = model as? Contacts {
            let sortId = deletemodel.sortId
            context.delete(deletemodel)
            saveData()
            let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
                let sort = NSSortDescriptor(key: "sortId", ascending: true)
                fetchRequest.sortDescriptors = [sort]
                let pred = NSPredicate(format: "sortId >= %@", String(sortId))
                fetchRequest.predicate = pred
            let data = try! context.fetch(fetchRequest)
            if data.count > 0 {
                var  i = 0
                while i  < data.count {
                    data[i].sortId = sortId + Int16(i)
                     i = i + 1
                }
            }
           saveData()
        }
    }
}
