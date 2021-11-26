//
//  APIRepository.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
public class APIRepository {
    internal let apiGateWay: APINetworking = GatewayAPI()
    internal var cancelableSet: Set<AnyCancellable> = Set()
    /// Publisher call back take place when publish data from Server
    internal let contactSubject = PassthroughSubject<[Contactdetails], Never>()
    var contactPublisher: AnyPublisher<[Contactdetails], Never> {
        contactSubject.eraseToAnyPublisher()
    }
    /// Parameter - offset String
    /// Take place return from API Call
    func fetchContactList(offSet: String) {
        let publisher: AnyPublisher<[Contactdetails], Error> = apiGateWay.fetchContactList(offset: offSet)
        publisher.sink(receiveCompletion: {_ in}, receiveValue: {
            [weak self] in
            self?.contactSubject.send($0)
        }).store(in: &cancelableSet)
    }
}
