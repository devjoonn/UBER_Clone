//
//  HomeViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/09.
//

import UIKit
import SnapKit
import FirebaseAuth
import MapKit
import CoreLocation

private let reuseIdentifier = "LocationCell"
private let annotationIndentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeViewController: UIViewController {

//MARK: - UI Components
    private let mapView = MKMapView()
    // 위치 묻는 역할
    private let locationManager = LocationHandler.shared.locationManager
    private let locationInputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200 // - 어디서든 수정 불가
    private final let rideActionViewHeight: CGFloat = 300 // - 어디서든 수정 불가
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private var user: User? {
        // 단일 책임 원칙으로 유저에 유저 정보를 넣어서 LocationInputView 자체에서 변경가능하게
        didSet { locationInputView.user = user }
    }
    
    private let actionButton: UIButton = {
        $0.setImage(UIImage(named: "baseline_menu_black"), for: .normal)
        $0.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return $0
    }(UIButton())
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        view.backgroundColor = .backgroundColor
        navigationController?.navigationBar.isHidden = true
        setUIandConstraints()
        enableLocationServices()
        fetchUserData()
        fetchDrivers()
    }
    
//MARK: - Selector
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG : showMenu")
        case .dismissActionView:
            removeAnnotationAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
            }
        }
    }
    
    // 현재 config에 따라 이미지 변환 & 설정
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(UIImage(named: "baseline_menu_black"), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "baseline_arrow_back"), for: .normal)
            actionButtonConfig = .dismissActionView // enum으로 dismiss된 것 처리
        }
        
    }
    
//MARK: - Firebase API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fatchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        print("DEBUG: HomeView called - fetchDriver")
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDriver(location: location) { (driver) in //
            guard let coordinate = driver.location?.coordinate else { return } // Driver location (드라이버 좌표 업데이트 시 coordinate도 변경)
            let annotation = DriverAnnotation.init(uid: driver.uid, coordinate: coordinate) // mapView에 driver 마킹
            
            // 드라이버의 정보가 있다면 
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        // 드라이버 위치 갱신
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        print("DEBUG: Driver 위치 갱신")
                        return true
                    } else {
                        return false
                    }
                })
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
            
        }
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        configureMapView()
        configureRideActionView()
        configureLocationActivationView()
        configureTableView()
    }
    
    // MapView
    func configureMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.delegate = self
    }
    
    // 홈 뷰에 있는 where to Bar and Menu
    func configureLocationActivationView() {
        view.addSubview(locationInputActivationView)
        view.addSubview(actionButton)
        
        locationInputActivationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(view.frame.width - 64)
            make.top.equalTo(actionButton.snp.bottom).inset(-32)
        }
        locationInputActivationView.alpha = 0
        locationInputActivationView.delegate = self
        
        // 뷰가 보일 시 애니메이션
        UIView.animate(withDuration: 2) {
            self.locationInputActivationView.alpha = 1
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
    }
    
    // where to Bar를 누르면 나오는 View
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            // tableView 애니메이션
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        
        // tableView의 frame과 같음
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    // 테이블 뷰에서 셀 선택하면 뷰가 사라지게 만드는 함수
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        // 천천히 사라지게
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            // 천천히 다시 나타나게
            // 뷰 스택 쌓이지않게 삭제 - 중요
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func presentRideActionView() {
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
        }
    }
}

//MARK: - MapView Helper Functions
private extension HomeViewController {
    // 검색어에 맞는 값 marking 하는 함수
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            // 위치내에 검색 값을 marking
            completion(results)
        }
    }
    
    // 폴리라인 생성하는 함수
    func generatePolyline(toDestination destination: MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionReqeust = MKDirections(request: request)
        directionReqeust.calculate { (response, error) in
            guard let response = response else { return }
            // 선언되어있는 route에 루트 값 추가
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    // 장소 선택 후 뒤돌아가기 시 annotation 삭제 & overlay(Polyline) 삭제
    func removeAnnotationAndOverlays() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}

//MARK: - MKMapViewDelegate: Driver 마킹을 여러 개 X -> 단일화
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIndentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    // polyline을 그리는 함수
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

//MARK: - 위치 사용 권한 부여
extension HomeViewController {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: 위치 정보 없을 때 권한 정보 물음")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: 항상 위치정보 권한 사용중")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: 앱을 사용할 때만 위치정보 권한 사용중")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }   
    }
}


//MARK: - LocationInputActivationViewDelegate
extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        locationInputActivationView.alpha = 0 // locationInputView를 띄우며 사라져보이게
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate
extension HomeViewController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.locationInputActivationView.alpha = 1
            })
        }
    }
}

//MARK: - TableView Delegate/DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        // locationView 사라지며 선택한 주소 값을 marking
        dismissLocationView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            // mapView에 있는 annotations의 값이 DriverAnnotation 클래스와 같으면
            // annotation과 User의 위치에 맞게 지도 확대
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }

}
