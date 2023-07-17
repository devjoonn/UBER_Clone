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
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeViewController()
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
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
//MARK: - Helper Functions
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
        
    }
    
    func animateMenu(shouldExpand: Bool) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeViewController.view.frame.origin.x = self.view.frame.width - 80
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeViewController.view.frame.origin.x = 0
            })
        }
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
