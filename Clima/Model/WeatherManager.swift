//
//  WeatherManager.swift
//  Clima
//
//  Created by Gustavo Leite Silvano on 01/01/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

let apiKey = <API_KEY>

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)"
    
    var delegate: WeatherManagerDelegate?
    
    func fecthWeatherByCityName(_ cityName: String){
        let url = "\(baseURL)&q=\(cityName)"
        performRequest(with: url)
    }
    
    func fetchWeatherByLatLon(lat: Double, lon: Double){
        let url = "\(baseURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration:  .default)
            let task = session.dataTask(with: url){data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
