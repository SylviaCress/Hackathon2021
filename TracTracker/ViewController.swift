//
//  ViewController.swift
//  TracTracker
//
//  Created by Avi Rez on 11/6/21.
//

import UIKit
import CoreLocation
import LMGaugeViewSwift

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {
                (response: URLResponse?, data: Data?, error: Error?) -> Void in
                if let imageData = data as Data? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}

class ViewController: UIViewController, WeatherGetterDelegate, CLLocationManagerDelegate {
    
    func didGetWeather(weather: Weather) {
        DispatchQueue.global(qos: .background).async {

            DispatchQueue.main.async {

                self.weather1.text = weather.weatherDescription
                self.weather2.text = "\(Int(round(weather.tempFahrenheit)))°"
                self.weather3.text = "\(Int(round(weather.windSpeed * 2.237))) mph"
              
              if let rain = weather.rainfallInLast3Hours {
                  self.weather4.text = "\(Int(round(rain/25.4))) in"
              }
              else {
                  self.weather4.text = "None"
              }
              
                self.weather5.text = "\(weather.humidity)%"
                self.weather6.text = "\(weather.cloudCover)%"
                self.weatherTitle.text = "Current Weather in \(weather.city)"
                self.weatherImage.imageFromUrl(urlString: "https://openweathermap.org/img/wn/\(weather.weatherIconID)@2x.png")
        }
        }
    }
    
    func didNotGetWeather(error: Error) {
        DispatchQueue.global(qos: .background).async {

            DispatchQueue.main.async {
                self.showSimpleAlert(title: "Can't get the weather",
                                   message: "The weather service isn't responding.")
            }
        }
        print("didNotGetWeather error: \(error)")
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(
          title: title,
          message: message,
          preferredStyle: .alert
        )
        let okAction = UIAlertAction(
          title: "OK",
          style:  .default,
          handler: nil
        )
        alert.addAction(okAction)
        present(
          alert,
          animated: true,
          completion: nil
        )
      }
    
    @IBOutlet weak var weather1: UILabel!
    @IBOutlet weak var weather2: UILabel!
    @IBOutlet weak var weather3: UILabel!
    @IBOutlet weak var weather4: UILabel!
    @IBOutlet weak var weather5: UILabel!
    @IBOutlet weak var weather6: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherTitle: UILabel!
    
    
    var weather: WeatherGetter!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timedUpdate), userInfo: nil, repeats: true)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
        }
        
        weather = WeatherGetter(delegate: self)
        maxSpeedometer.valueRingColor = UIColor.red
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        weather.getWeatherByLatLong(lat: String(locValue.latitude), long: String(locValue.longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    
    @IBOutlet weak var stopDistance: UILabel!
    @IBOutlet weak var roadCondition: UILabel!
    @IBOutlet weak var speedometer: GaugeView!
    @IBOutlet weak var maxSpeedometer: GaugeView!
    
    @objc func timedUpdate() {
        roadCondition.text = "Red ring is max speed to"
        stopDistance.text = "stop safely in 100 ft"
        let content = try? String(contentsOf: URL(string: "http://raspberrypi.local/hack2021/data")!)
        let parts = content?.split(separator: "\n")

        speedometer.value = Double(parts![7]) ?? 10
        maxSpeedometer.value = Double(parts![3]) ?? 10
        
        print(Double(parts![3]) ?? 0)
    }
}

