//
//  JsonParser.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation

protocol JsonParserService {
    func parse(fileName: String, completion handler: @escaping (Result<[Place], Error>) -> Void)
    func parse(address: Data) -> String?
}

final class JsonParser: DataParser, JsonParserService {
    typealias DataType = Place
    static let shared = JsonParser()

    private let type = "json"
    
    enum JsonParserError: Error {
        case invalidFileName
    }
    
    func parse(fileName: String, completion handler: @escaping (Result<[Place], Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                guard let path = Bundle.main.url(forResource: fileName, withExtension: self.type) else {
                    handler(.failure(JsonParserError.invalidFileName))
                    return
                }
                
                let data = try Data(contentsOf: path)
                let places = try JSONDecoder().decode(Places.self, from: data)
                
                DispatchQueue.main.async {
                    handler(.success(places.places))
                }
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    func parse(address: Data) -> String? {
        do {
            let geocoding = try JSONDecoder().decode(Geocoding.self, from: address)
                .results?
                .first
            let region = geocoding?.region
            
            let area1 = region?.area1?.name ?? ""
            let area2 = region?.area2?.name ?? ""
            let area3 = region?.area3?.name ?? ""
            let area4 = region?.area4?.name ?? ""
            
            let land = geocoding?.land
            let number1 = land?.number1 ?? ""
            var number2 = land?.number2 ?? ""
            if number2 != "" {
                number2 = "-" + number2
            }
            
            if let loadName = land?.name {
                return "\(area1) \(area2) \(area3) \(loadName) \(number1)\(number2)"
            } else {
                return "\(area1) \(area2) \(area3) \(area4)"
            }
        } catch {
            return nil
        }
    }
}
