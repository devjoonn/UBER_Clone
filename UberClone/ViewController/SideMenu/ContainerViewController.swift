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
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeViewController()
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
}

extension ContainerViewController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        print("DEBUG: ContainerViewController - handleMenuToggle() 호출")
    }
}
