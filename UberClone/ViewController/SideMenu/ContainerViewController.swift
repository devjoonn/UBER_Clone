//
//  ContainerViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/11.
//

import UIKit

class ContainerViewController: UIViewController {

//MARK: - Properties
    private let homeViewController = HomeViewController()
    private let menuViewController = MenuViewController()
    private var isExpanded = false
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        configureHomeViewController()
        configureMenuViewController()
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
    func configureMenuViewController() {
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        // menuViewController를 가장 앞에 삽입
        view.insertSubview(menuViewController.view, at: 0)
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
