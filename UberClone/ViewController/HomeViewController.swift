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

// pickup, destination Anno 구분
private enum AnnotationType: String {
    case pickup
    case destination
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
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers() // mapView에 driver 표시
                configureLocationActivationView() // 주소 입력 창
                observeCurrentTrip() // 현재 유저의 상태 변경 
            } else {
                observeTrips() // driver 시
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let controller = PickupViewController(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            } else {
                print("DEBUG: trip을 적용하기 위해 actionView 띄우기")
            }
        }
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
        centerMapOnUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        print("DEBUG: Trip state is \(trip.state)")
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
                self.animateRideActionView(shouldShow: false)
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
    
//MARK: - Passenger API
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state else { return }
            guard let driverUid = trip.driverUid else { return }
            
            switch state {
                
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationAndOverlays()
                self.zoomForActiveTrip(withDriverUid: driverUid)
                
                Service.shared.fatchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { (error, ref) in
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.locationInputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip Completed", message: "We hope you enjoyed your trip")
                }
            }
        }
    }
    
    // pickup 후 목적지 까지
    func startTrip() {
        guard let trip = trip else { return }
        
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) {  (error, ref) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            
            let placeMark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placeMark)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            self.generatePolyline(toDestination: mapItem)
            
            // 유저와 목적지가 한 번에 보이게 mapView 최적화
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    // driver 위치 표시
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDriver(location: location) { (driver) in //
            guard let coordinate = driver.location?.coordinate else { return } // Driver location (드라이버 좌표 업데이트 시 coordinate도 변경)
            let annotation = DriverAnnotation.init(uid: driver.uid, coordinate: coordinate) // mapView에 driver 마킹
            
            // 드라이버의 정보가 있다면 
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        // 드라이버 위치 갱신
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
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

//MARK: - Driver API
    func observeTrips() {
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeCancelTrip(trip: Trip) {
        // rider 매칭 취소 시 driver -> rider에게 가는 polyline, RideActionView 사라짐
        DriverService.shared.observeTripCancelled(trip: trip, completion: {
            self.removeAnnotationAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops!", message: "The Passenger has decided to cancel this ride. Press Ok to continue.")
        })
    }

//MARK: - shared API
    // 로그인한 유저 데이터 불러옴
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fatchUserData(uid: currentUid) { user in
            self.user = user
            
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
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
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
        rideActionView.delegate = self
        
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
    
    // rideActionView y값으로 가시성 조절 - didselect 시 true 반환 / 뒤로가기 시 false 반환
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = destination {
                self.rideActionView.destination = destination
            }
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.config = config
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
    
    // 확대 되었던 유저 location - Zoom out
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    // Driver가 Rider의 위치에 도착했을 때
    func setCustomRegion(withType type: AnnotationType, coordinates: CLLocationCoordinate2D) {
        // locationManager가 해당 지역을 관찰
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    // annotation이 center에 위치하게 줌 인/아웃
    func zoomForActiveTrip(withDriverUid  driverUid: String) {
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == driverUid {
                    annotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation{
                annotations.append(userAnno)
            }
        }
        self.mapView.zoomToFit(annotations: annotations)
    }
}

//MARK: - MKMapViewDelegate: Driver 마킹을 여러 개 X -> 단일화
extension HomeViewController: MKMapViewDelegate {
    // mapView 실시간 업데이트
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // 오직 driver 일 때만
        guard let user = self.user else { return }
        guard user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocaton(location: location)
    }
    
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

//MARK: CLLocationManagerDelegate - 위치 사용 권한 부여
extension HomeViewController: CLLocationManagerDelegate {
    // 모니터링 시작
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: pickup 지역 모니터링 시작 - \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: destination 지역 모니터링 시작 - \(region)")
        }
    }
    
    // 모니터링하는 지역에 도착
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (error, ref) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { (error, ref) in
                self.rideActionView.config = .endTrip
            }
        }
    }
    
    func enableLocationServices() {
        locationManager?.delegate = self
         
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
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            
            // mapView에 있는 annotations의 값이 DriverAnnotation 클래스와 같으면
            // annotation과 User의 위치에 맞게 지도 확대
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            // - self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }

}

//MARK: - RideActionView Delegate
extension HomeViewController: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        // 현재 위치 & 선택 장소 위치
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
            if let err = err  {
                print("DEBUG: Failed to upload trip with error \(err.localizedDescription)")
            }
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error {
                print("DEBUG: Trip 삭제 중 에러")
                return
            }
            
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationAndOverlays()
            
            self.actionButton.setImage(UIImage(named: "baseline_menu_black"), for: .normal)
            self.actionButtonConfig = .showMenu
            
            self.locationInputActivationView.alpha = 1
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (error, ref) in
            self.removeAnnotationAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            
        }
    }
}

//MARK: - PickupViewControllerDelegate - Driver
extension HomeViewController: PickupViewControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placeMark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placeMark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelTrip(trip: trip)
        
        // PickupView 기준 self
        self.dismiss(animated: true) {
            Service.shared.fatchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}
