//
//  ViewController.swift
//  WeatherApp
//
//  Created by 심소영 on 6/19/24.
//

import UIKit
import Alamofire
import CoreLocation
import SnapKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    let imageView = UIImageView()
    var dateLabel = UILabel()
    var locationLabel = UILabel()
    var temperatureLabel = UILabel()
    var humidityLabel = UILabel()
    var windLabel = UILabel()
    var latNum: Double = 0.0
    var lonNum: Double = 0.0
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    var weatherList = Weather(coord: .init(lon: 0.0, lat: 0.0), main: .init(temp: 0.0, humidity: 0), wind: .init(speed: 0.0), name: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        requestWeather()
        locationManager.delegate = self
        mapView.delegate = self
        dateFormat()
        checkDeviceLocationAUthorization()
        mapView.showsUserLocation = true
        locationLabel.text = "나는 어디에?"
    }
    func requestWeather(){
        let url = "\(API.APIURL.URL)"
        let parameter: Parameters = ["lat": "\(latNum)", "lon": "\(lonNum)", "appid": "\(API.APIKey.key)"]
        AF.request(url, parameters: parameter).responseDecodable(of: Weather.self) { response in
            switch response.result {
            case .success(let value):
                self.weatherList = value
                let temp = self.weatherList.main.temp
                let num = Int(temp - 273.15)
                self.temperatureLabel.text = "지금은 \(num)°C 에요"
                self.humidityLabel.text = "\(self.weatherList.main.humidity)% 만큼 습해요"
                self.windLabel.text = "\(self.weatherList.wind.speed)m/s 바람이 불어요"
            case .failure(let error):
                print(error)
            }
        }
    }
    func configureHierarchy(){
        view.addSubview(imageView)
        view.addSubview(dateLabel)
        view.addSubview(locationLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(humidityLabel)
        view.addSubview(windLabel)
        view.addSubview(mapView)
        
    }
    func configureLayout(){
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(400)
        }
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(140)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        windLabel.snp.makeConstraints { make in
            make.top.equalTo(humidityLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        mapView.snp.makeConstraints { make in
            make.top.equalTo(windLabel.snp.bottom).offset(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            
        }

    }
    func configureUI(){
        view.backgroundColor = .white
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFit
        dateLabel.locationLabel(fontSize: 12)
        locationLabel.locationLabel(fontSize: 14)
        temperatureLabel.weatherLabel()
        humidityLabel.weatherLabel()
        windLabel.weatherLabel()
        mapView.layer.cornerRadius = 20
        mapView.clipsToBounds = true
    }
    func addPin(){
        let location = CLLocationCoordinate2D(latitude: latNum, longitude: lonNum)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "네이버"
        mapView.addAnnotation(pin)
        
    }
    func dateFormat(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 hh시 mm분"
        let currentDateString = formatter.string(from: Date())
        dateLabel.text = currentDateString
    }
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        requestLocationServiceAlert.addAction(goSetting)
        present(requestLocationServiceAlert, animated: true)
    }
    
    func checkCurrentLocationAuthorization(){
        var status: CLAuthorizationStatus

        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showRequestLocationServiceAlert()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default: print(status)
        }
    }
    func checkDeviceLocationAUthorization(){
            if CLLocationManager.locationServicesEnabled() {
               checkCurrentLocationAuthorization()
            } else {
                showRequestLocationServiceAlert()
            }
    }
    
    func setRegionAndAnnotation(center: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 100)
        latNum = region.span.latitudeDelta
        lonNum = region.span.longitudeDelta
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            print(coordinate)
            print(coordinate.latitude)
            setRegionAndAnnotation(center: coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(#function)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function, "14이상")
        checkDeviceLocationAUthorization()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function, "14미만")
    }
}


