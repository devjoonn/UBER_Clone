//
//  HomeViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/09.
//

import UIKit
import SnapKit
import FirebaseAuth

class HomeViewController: UIViewController {

    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLogIn()
        view.backgroundColor = .backgroundColor
        
    }
    
    
//MARK: - Firebase API
    func checkIfUserIsLogIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: 유저가 로그인 하지 않음")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            print("DEBUG: 유저 로그인 중! - 유저 아이디: \(String(describing: Auth.auth().currentUser?.uid))")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
}
