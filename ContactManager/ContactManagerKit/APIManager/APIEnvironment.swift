//
//  APIEnvironment.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
public class APIEnvironment {
    static let shared = APIEnvironment()
    ///QueryParams for url
    public static func queryParams(queryData: Data?) -> URL {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "shielded-ridge-19050.herokuapp.com"
        urlComponent.queryItems = queryData?.queryItems
        return urlComponent.url!
    }
}
