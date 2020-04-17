//
//  JSONDownloader.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation

class JSONDownloader {
    let session: URLSession
    let decoder = JSONDecoder()

    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }

    convenience init() {
        self.init(configuration: .default)
    }

    typealias JSON = Data?
    typealias JSONTaskCompletionHandler = (JSON?, LocationError?) -> Void

    func jsonTask(with request: URLRequest,
                  completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {

        let task = session.dataTask(with: request) { data, response, _ in

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }

            if httpResponse.statusCode == 200 {
                if let data = data {

                        completion(data, nil)

                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }

        }

        return task
    }
}
