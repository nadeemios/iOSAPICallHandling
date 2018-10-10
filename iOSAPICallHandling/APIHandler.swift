//
//  APIHandler.swift
//  iOSExercise
//
//  Created by Daffolap on 10/10/18.
//  Copyright © 2018 Daffolap. All rights reserved.
//

import Foundation
import Alamofire
protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}
struct K {
    struct ProductionServer {
        static let baseURL = "https://api.spacexdata.com/v3"
    }
    /// params
    struct APIParameterKey {
        static let password = "password"
        static let email = "email"
        
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}

enum APIRouter: APIConfiguration {
    
    case dragon(id:String)
    // MARK: - HTTPMethod
    internal var method: HTTPMethod {
        switch self {
        case .dragon:
            return .get
        }
    }
    
    // MARK: - Path
    internal var path: String {
        switch self {
        case .dragon(let id):
            return "/dragons/\(id)"
        }
    }
    
    // MARK: - Parameters
    internal var parameters: Parameters? {
        switch self {
        case .dragon:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}

class APIClient {
    static func getDragons(id:String, completion:@escaping (Dragon)->Void) {
        Alamofire.request(APIRouter.dragon(id: id))
            .responseData { (response: DataResponse<Data>) in
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
                    let dragon = try decoder.decode(Dragon.self, from: response.data!)
                    print(dragon)
                    completion(dragon)
                } catch {
                    print(error)
                }
        }
    }
}
