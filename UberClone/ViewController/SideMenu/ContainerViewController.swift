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
    private let menuViewController = MenuViewController()
    private var isExpanded = false
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            configureHomeViewController(withUser: user)
            configureMenuViewController(withUser: user)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        fetchUserData()
    }
    
//MARK: - API
    // 로그인한 유저 데이터 불러옴
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fatchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
//MARK: - Helper Functions
    // home이 postion 1
    func configureHomeViewController(withUser user: User) {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        homeViewController.delegate = self
        homeViewController.user = user
    }
    
    // menu가 position 0
    func configureMenuViewController(withUser user: User) {
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        // menuViewController를 가장 앞에 삽입
        view.insertSubview(menuViewController.view, at: 0)
        menuViewController.user = user
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

extension ContainerViewController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}
