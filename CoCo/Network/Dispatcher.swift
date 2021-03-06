//
//  Dispatcher.swift
//  CoCo
//
//  Created by 이호찬 on 28/01/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import Foundation

protocol DispatcherType {
    /**
     dataTask를 실행하여 Data를 넘겨준다.
     
     - Author: [이호찬](https://github.com/LHOCHAN)
     - Parameters:
        - request: path, method, parameter, header 등이 포함된 프로토콜
        - completion: 데이터를 성공적으로 불러올 시 호출된다.
                        data 서버에서 반환된 Data
     */
    func execute(request: RequestType, completion: @escaping (Data) -> Void) throws
    /**
     URLRequest를 생성하여 파라미터와 헤더를 설정한다.
     
     - Author: [이호찬](https://github.com/LHOCHAN)
     - Parameters:
        - request: path, method, parameter, header 등이 포함된 프로토콜
     */
    func prepare(request: RequestType) throws -> URLRequest

    func cancel()

    init(environment: Environment)
}

class NetworkDispatcher {
    // MARK: - Private Properties
    private var environment: Environment

    var task: URLSessionTask?

    // MARK: - Initializer
    required init(environment: Environment) {
        self.environment = environment
    }

    // MARK: - Methods
    /**
     NetworkDispatcher 클래스를 Dispatcher 프로토콜 타입으로 변환한다.
     
     - Author: [이호찬](https://github.com/LHOCHAN)
     */
    func makeNetworkProvider() -> DispatcherType {
        return self
    }
}

extension NetworkDispatcher: DispatcherType {
    // MARK: - Methods
    func execute(request: RequestType, completion: @escaping (Data) -> Void) throws {
        let request = try self.prepare(request: request)

        task = URLSession.shared.dataTask(with: request) {  (data, _, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let data = data else {
                return
            }
            completion(data)
        }
        task?.resume()
    }

    func prepare(request: RequestType) throws -> URLRequest {
        let fullUrl = "\(environment.host)/\(request.path ?? "")"
        guard let url = URL(string: fullUrl) else {
            throw NetworkErrors.badInput
        }
        var apiRequest = URLRequest(url: url)

        // 파라미터 설정
        switch request.parameters {
        case .body(let params):
            guard let params = params else {
                break
            }
            let body = try JSONEncoder().encode(params)
            apiRequest.httpBody = body
        case .url(let params):
            guard let params = params else {
                break
            }
            let queryParams = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard var components = URLComponents(string: fullUrl) else {
                throw NetworkErrors.invalidComponent
            }
            components.queryItems = queryParams
            apiRequest.url = components.url
        }

        // 헤더 값 설정
        if environment.headerDic?.isEmpty == false {
            environment.headerDic?.forEach { apiRequest.setValue("\($0.value)", forHTTPHeaderField: $0.key) }
        }
        if request.headerDic?.isEmpty == false {
            request.headerDic?.forEach { apiRequest.setValue("\($0.value)", forHTTPHeaderField: $0.key) }
        }
        apiRequest.httpMethod = request.method.rawValue
        return apiRequest
    }

    func cancel() {
        task?.cancel()
    }
}
