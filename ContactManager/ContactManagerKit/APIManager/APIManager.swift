//
//  APIManager.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import Foundation
import Combine
import os

class APIManager {
    static let shared = APIManager()
    let session = URLSession.shared
    // Response holds parsed value and URL Response
    public struct Response<T> {
        let value: T
        let response: URLResponse
    }
    private init() {
    }
    /// Get - T - generic Data model
    func runGet<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
        return run(request, .init()).map(\.value).eraseToAnyPublisher() /// mapped prased value to retun 
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return dataTaskPublisher(for: request).tryMap {
            result -> Response<T> in
            /// Print the response Status
            if let response = result.response as? HTTPURLResponse {
                print(response)
            }
            ///Decoder the generic model
            let value = try decoder.decode(T.self, from: result.data)
            return Response(value: value, response: result.response)
        }.map {
            error in
            print(error)
            return error
        }.eraseToAnyPublisher()
    }
    ///API Calls Happen Here
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher  {
        return session.dataTaskPublisher(for: request)
    }
    
}
