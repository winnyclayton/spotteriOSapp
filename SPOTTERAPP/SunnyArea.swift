//
//  SunnyArea.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 9/6/2023.
//

import Foundation

struct SunnyArea: Codable {
    
    let id: String
    let name: String
    let locationLat: Double
    let locationLng: Double
    let state: String
    let postcode: String
    let weather: String
    let forecasts: String
    let rainfallProbability: Double
    let rainfallForecast: String
    let distanceHours: String
    let distanceKlms: String
    
    init(id: String, name: String, locationLat: Double, locationLng: Double, state: String, postcode: String, weather: String, forecasts: String, rainfallProbability: Double, rainfallForecast: String, distanceHours: String, distanceKlms: String) {
        
        self.id = id
        self.name = name
        self.locationLat = locationLat
        self.locationLng = locationLng
        self.state = state
        self.postcode = postcode
        self.weather = weather
        self.forecasts = forecasts
        self.rainfallProbability = rainfallProbability
        self.rainfallForecast = rainfallForecast
        self.distanceHours = distanceHours
        self.distanceKlms = distanceKlms
        
        
    }
}

