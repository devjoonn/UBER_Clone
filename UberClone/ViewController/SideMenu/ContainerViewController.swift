//
//  ContainerViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/11.
//

import UIKit
import FirebaseAuth

class ContainerViewController: UIViewController {

//MARK: - Properties
    private let homeViewController = HomeViewController()
    private var menuViewController: MenuViewController!
    private var isExpanded = false
    private let blackView = UIView()
    private lazy var  xOrigin = self.view.frame.width - 80
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeViewController.user = user
            configureMenuViewController(withUser: user)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // 메뉴 확장 시 상태바 Hidden 설정
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
//MARK: - API
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
            let vc = UINavigationController(rootViewController: LoginViewController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
//MARK: - Helper Functions
    func configure() {
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeViewController()
    }
    
    // home이 postion 1
    func configureHomeViewController() {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        homeViewController.delegate = self
        
    }
    
    // menu가 position 0
    func configureMenuViewController(withUser user: User) {
        menuViewController = MenuViewController(user: user)
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        // menuViewController를 가장 앞에 삽입
        view.insertSubview(menuViewController.view, at: 0)
        menuViewController.delegate = self
        // 메뉴 뷰 옆 지도를 가리는 뷰
        configureBlackView()
    }
    
    func configureBlackView() {
        blackView.frame = CGRect(x: self.xOrigin,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                // 홈 뷰 위치 수정
                self.homeViewController.view.frame.origin.x = self.xOrigin
                // 블랙 뷰 위치 수정
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeViewController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    // 상태바 설정
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
//MARK: - Selector
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: - HomeViewController Delegate
extension ContainerViewController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: - MenuViewController Delegate
extension ContainerViewController: MenuViewControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "Are you sure want to log out?",
                                              preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
                
                self.present(alert, animated: true)
            }
        }
    }
}
