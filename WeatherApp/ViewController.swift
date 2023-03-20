//
//  ViewController.swift
//  WeatherApp
//
//  Created by Raghul Ragavan on 19/03/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController , UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var celciusLabel: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var farenheitLabel: UIButton!
    
    let locationManager = CLLocationManager()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        setdefaulttemperature()
        
        searchTextField.delegate = self
        
        let myLocationManager = self
        myLocationManager.getLocation()
    }
    
    func getLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
       
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
                    return
                }
        let geocoder = CLGeocoder()
               geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
                   if let error = error {
                       print("Error getting location: \(error)")
                       return
                   }

                   guard let placemark = placemarks?.first else {
                       print("No placemark found for location")
                       return
                   }

                   if let city = placemark.locality, let state = placemark.administrativeArea {
                       self.loadWeather(search: "\(city), \(state)")
                   } else {
                       print("Unable to determine location")
                   }
               }
        locationManager.stopUpdatingLocation()
       
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        
        loadWeather(search: textField.text)
        return true
    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        setdefaulttemperature()
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        celciusLabel.tintColor = UIColor(ciColor: .green)
        let myLocationManager = self
        myLocationManager.getLocation()

    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        setdefaulttemperature()
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        loadWeather(search: searchTextField.text)
    }
    
    @IBAction func onFarenheitTapped(_ sender: UIButton) {
        
        sender.tintColor = UIColor(ciColor: .green)
        celciusLabel.tintColor = UIColor(ciColor: .white)
        
        if let temperature = temperatureLabel.text {
            guard let celsiusValue = Double(temperature.replacingOccurrences(of: "°C", with: "")) else {
                print("error")
                return
                
            }
            let fahrenheitValue = (celsiusValue * 9/5) + 32
            temperatureLabel.text = "\(Int(round(fahrenheitValue)))°F"
        }
    }
    
    @IBAction func onCelciusTapped(_ sender: UIButton) {
        setdefaulttemperature()
        
        if let temperature = temperatureLabel.text {
            guard let fahrenheitValue = Double(temperature.replacingOccurrences(of: "°F", with: "")) else {
                print("error")
                return
                
            }
            let celsiusValue = (fahrenheitValue  - 32) * (5/9)
            temperatureLabel.text = "\(Int(round(celsiusValue)))°C"
        }
        
    }
    
    func setdefaulttemperature() {
        farenheitLabel.tintColor = UIColor(ciColor: .white)
        celciusLabel.tintColor = UIColor(ciColor: .green)
    }
    
    func loadWeather(search: String?) {
        
        searchTextField.text = ""
        guard let search = search else {
            return
        }
        
        guard let url = getUrl(query: search) else {
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {  data, response, error in
            
            guard error == nil else {
                print("Error processing")
                return
            }
            
            guard let data = data else {
                print("No Data Found")
                return
            }
            if let weatherResponse = self.ParseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async { [self] in
                    cityLabel.text = weatherResponse.location.name
                    provinceLabel.text = weatherResponse.location.region
                    
                    temperatureLabel.text = "\(Int(weatherResponse.current.temp_c))°C"
                    weatherConditionLabel.text = weatherResponse.current.condition.text
                    
                    DateLabel.text = dateFormatter(dateString: weatherResponse.location.localtime)
                    
                    let configuration = UIImage.SymbolConfiguration(hierarchicalColor: .white)
                    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .medium)
                    self.weatherImage.preferredSymbolConfiguration=configuration
                    if (weatherResponse.current.condition.code) == 1000{
                        self.weatherImage.image = UIImage (systemName: "cloud", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1003{
                        self.weatherImage.image = UIImage (systemName: "cloud.fill", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1006{
                        self.weatherImage.image = UIImage (systemName: "smoke.fill", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1009{
                        self.weatherImage.image = UIImage (systemName: "cloud.fog.fill", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1030{
                        self.weatherImage.image = UIImage (systemName: "wind", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1063{
                        self.weatherImage.image = UIImage (systemName: "cloud.drizzle", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1066{
                        self.weatherImage.image = UIImage (systemName: "cloud.snow", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1072{
                        self.weatherImage.image = UIImage (systemName: "cloud.sleet", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1087{
                        self.weatherImage.image = UIImage (systemName: "cloud.bolt.rain", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1114{
                        self.weatherImage.image = UIImage (systemName: "wind.snow", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1117{
                        self.weatherImage.image = UIImage (systemName: "tropicalstorm", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1135{
                        self.weatherImage.image = UIImage (systemName: "cloud.fog", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1147{
                        self.weatherImage.image = UIImage (systemName: "cloud.fog.fill", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1150{
                        self.weatherImage.image = UIImage (systemName: "cloud.drizzle", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1183{
                        self.weatherImage.image = UIImage (systemName: "cloud.drizzle", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1219{
                        self.weatherImage.image = UIImage (systemName: "snowflake", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1240{
                        self.weatherImage.image = UIImage (systemName: "cloud.rain", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1255{
                        self.weatherImage.image = UIImage (systemName: "cloud.snow.fill", withConfiguration: config)
                    }
                    if (weatherResponse.current.condition.code) == 1279{
                        self.weatherImage.image = UIImage (systemName: "cloud.bolt.rain", withConfiguration: config)
                    }
                }
              
            }
            
            }
        
        dataTask.resume()
        
    }
    
    private func getUrl(query: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apikey = "fda72daabbb9454696e203424231903"
        guard let url = "\(baseUrl)\(currentEndpoint)?Key=\(apikey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        
        return URL(string: url)
    }
    
    private func ParseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print ("Error decoding")
        }
        
        return weather
        
    }
    
    private func dateFormatter(dateString: String) -> String {
      
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: dateString)

        dateFormatter.dateFormat = "EEEE, d MMMM"
        let formattedDate = dateFormatter.string(from: date!)
        
        return formattedDate
    }
    
}

struct WeatherResponse: Decodable {
    let location : Location
    let current : Weather
}


struct Location: Decodable {
    let name: String
    let region: String
    let localtime: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition : WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}
