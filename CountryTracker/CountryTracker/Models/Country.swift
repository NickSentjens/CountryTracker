//
//  CountryModel.swift
//  CountryTracker
//
//  Created by Nick Sentjens on 2018-10-11.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import Foundation

struct Country {
    let name: String
    let capital: String
    let population: Int
    let flagURL: URL
    var isFavorited = false
    
    init(name: String,
         capital: String,
         population: Int,
         flagURL: URL) {
        self.name = name
        self.capital = capital
        self.population = population
        self.flagURL = flagURL
    }
}

extension Country: Decodable {
    enum CountryModelKeys: String, CodingKey {
        case name = "name"
        case capital = "capital"
        case population = "population"
        case flagURL = "flag"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CountryModelKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let capital = try container.decode(String.self, forKey: .capital)
        let population = try container.decode(Int.self, forKey: .population)
        let flagURL = try container.decode(URL.self, forKey: .flagURL)
        
        self.init(name: name,
                  capital: capital,
                  population: population,
                  flagURL: flagURL)
    }
}
