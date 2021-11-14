//
//  GatewayAPI.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
public class GatewayAPI: APINetworking {
    /// paramter - offset - pagination number
    ///return the [Contacts] Model
    public func fetchContactList(offset: String) -> AnyPublisher<[Contact], Error> {
        let requestData = try? JSONEncoder().encode(ContactRequest.init(offset: offset))
        
        let urlRequest = URLRequest(url: APIEnvironment
                                            .queryParams(queryData: requestData).appendingPathComponent(APIEnvironment.APIURLS.contactList))
        
        return APIManager.shared.runGet(request: urlRequest)
    }
    
    
    
    
}
