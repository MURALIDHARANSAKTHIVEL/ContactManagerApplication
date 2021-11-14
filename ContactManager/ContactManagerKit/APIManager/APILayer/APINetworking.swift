//
//  APINetworking.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
/// Protocal implemented  GatewayAPI
public protocol APINetworking {
    func fetchContactList(offset: String) -> AnyPublisher<[Contact], Error>
}
