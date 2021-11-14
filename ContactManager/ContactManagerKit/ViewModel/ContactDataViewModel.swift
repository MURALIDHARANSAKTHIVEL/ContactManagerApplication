//
//  ContactDataViewModel.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
import CoreData
public class  ContactDataViewModel {
    var apiRepository: APIRepository
    var cancelSet: Set<AnyCancellable> = Set()
    let coreDataManager = CoreDataManager.shared
    static let userManager = UserManager.shared
    var group = DispatchGroup() /// Dispath
    ///Notified once data get from Server
    let fetchContactListSubject = PassthroughSubject<Bool, Never>()
    public var fetchContactListPublisher: AnyPublisher<Bool, Never> {
        fetchContactListSubject.eraseToAnyPublisher()
    }
    public init(apiRepository: APIRepository) {
        self.apiRepository = apiRepository
        observer()
    }
    var contactList: [Contact] = []
    public func observer() {
        apiRepository.contactPublisher.sink(receiveCompletion: {_ in}, receiveValue: {
            result in
            self.contactList.append(contentsOf: result)
            self.group.leave()
        }).store(in: &cancelSet)
    }
    public func fetchList() {
        var i = 0
        while i < 5 { /// n-0 -n-49 so iterate to 5 future purpose we can customize
            group.enter()
            let offset = i * 10
            apiRepository.fetchContactList(offSet: "\(offset)")
            i = i + 1
        }
        ///Once all API completed its notified
        group.notify(queue: .main) {
            self.sortedContacts()
            self.fetchContactListSubject.send(true)
        }
    }
    ///Insert the data to CoerData
    private func sortedContacts() {
        for contact in contactList {
            coreDataManager.insertData(model: contact)
        }
    }
}
