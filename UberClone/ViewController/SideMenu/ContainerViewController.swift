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
    private var menuViewController: MenuViewController!
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeViewController()
    }
    
//MARK: - Helper Functions
    func configureHomeViewController() {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        
    }
}
