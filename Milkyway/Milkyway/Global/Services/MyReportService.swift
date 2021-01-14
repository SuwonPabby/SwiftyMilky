//
//  MyReportService.swift
//  Milkyway
//
//  Created by ✨EUGENE✨ on 2021/01/13.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

struct MyReportService {

    private init() {}

    static let shared = MyReportService()

    func GetMyReport(completion: @escaping (NetworkResult<Any>) -> Void) {
        let URL = APIConstants.showMyReport
        print(URL)
        
        //let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWR4Ijo1LCJpYXQiOjE2MDk3Nzg0NjksImV4cCI6MTYxMjM3MDQ2OSwiaXNzIjoibWlsa3lXYXkifQ.c2JAdyd0pGQzbmT0E_yl51eAGkcO71YfokwJebqqDME"
        let token = KeychainWrapper.standard.string(forKey: "Token")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token ?? ""
        ]


        let dataRequest = AF.request(URL,
                                     method: .get,
                                     encoding: JSONEncoding.default,
                                     headers: headers
                                     )

        dataRequest.responseData{ (response) in

            switch response.result {

            case .success(_):
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        print("home server")
                        switch status {
                        case 200:
                            do {
                                let decoder = JSONDecoder()
                                let result = try decoder.decode(ResponseSimpleResult<MyReportData>.self,
                                                                from: value)
                                completion(.success(result.data ?? Token.self))

                            } catch {
                                completion(.pathErr)
                            }
                        case 400:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(_):
                completion(.networkFail)
            }

        }
    }
    
}
