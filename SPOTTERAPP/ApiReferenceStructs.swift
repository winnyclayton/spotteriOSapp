//
//  ApiReferenceStructs.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 10/7/2023.
//

import Foundation


struct LocationForecastResponse: Codable {
    
    var location: Location
    var forecasts: Forecasts
}

struct Location: Codable {
        var id: Int
        var name: String
        var region: String
        var state: String
        var postcode: String
        var timeZone: String
        var lat: Float
        var lng: Float
        var typeId: Int
}

struct Forecasts: Codable {
    var rainfall: Rainfall
    var weather: Weather
    var wind: Wind
    var precis: Precis
    //var swell: Swell
    //var tides: Tides
}


//RAINFALL ATTRIBUTES
struct Rainfall: Codable {
var days: [RainfallDay]
}
struct RainfallDay: Codable {
var entries: [RainfallEntries]
}
struct RainfallEntries: Codable {
var dateTime: String
var probability: Int
}

///WEATHER ATTRIBUTES
struct Weather: Codable {
var days: [WeatherDay]
var units: WeatherUnits
}
struct WeatherDay: Codable {
var entries: [WeatherEntries]
}
struct WeatherEntries: Codable {
var dateTime: String
var min: Int
var max: Int
}
struct WeatherUnits: Codable {
    var temperature: String
}

//WIND ATTRIBUTES
struct Wind: Codable {
var days: [WindDay]
var units: WindUnits
}
struct WindDay: Codable {
var entries: [WindEntries]
}
struct WindEntries: Codable {
var dateTime: String
var speed: Double
}
struct WindUnits: Codable {
var speed: String
}

//CLOUD ATTRIBUTES
struct Precis: Codable {
var days: [PrecisDay]
}

struct PrecisDay: Codable {
var entries: [PrecisEntries]
}

struct PrecisEntries: Codable {
var dateTime: String
var precis: String
}


////SWELL ATTRIBUTES
//struct Swell: Codable {
//var days: [SwellDay]
//var units: SwellUnits
//}
//
//struct SwellDay: Codable {
//var entries: [SwellEntries]
//}
//
//struct SwellEntries: Codable {
//var dateTime: String
//var direction: Double
//var directionText: String
//var height: Double
//var period: Double
//}
//
//struct SwellUnits: Codable {
//var height: Double
//}
//
//
////TIDE ATTRIBUTES
//struct Tides: Codable {
//var days: [TideDay]
//var units: TideUnits
//}
//
//struct TideDay: Codable{
//var entries: [TideEntries]
//}
//
//struct TideEntries: Codable {
//var dateTime: String
//var height: Double
//var type: String
//}
//
//struct TideUnits: Codable {
//var height: Double
//}

class ApiReferenceStructs {
    
    
}
