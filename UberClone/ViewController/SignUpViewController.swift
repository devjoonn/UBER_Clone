//
//  SignUpViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/04.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    //MARK: - UI Components
    private let titleLabel: UILabel = {
        $0.text = "UBER"
        $0.font = UIFont(name: "Avenir-Light", size: 36)
        $0.textColor = UIColor(white: 1, alpha: 0.8)
        return $0
    }(UILabel())
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_mail_outline_white")!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullnameContrinerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_person_outline_white")!, textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_account_box_white")!, segmentControl: accountTypeSegmentControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_lock_outline_white")!, textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Email", isSecureTextEntry: false)
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Fullname", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        setUIandConstraints()
        
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        configureNavigationBar()
        
        view.addSubview(titleLabel)
        let stack = UIStackView(arrangedSubviews: [emailContainerView, fullnameContrinerView, passwordContainerView, accountTypeContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        view.addSubview(stack)
        view.addSubview(alreadyHaveAccountButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-40)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        alreadyHaveAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(32)
        }
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

//MARK: - handler
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Debug 회원가입 실패: \(error.localizedDescription)")
                print(error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email": email,
                          "fullname": fullname,
                          "accountTypeIndex": accountTypeIndex] as [String: Any]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                print("유저 정보를 성공적으로 저장했습니다.")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
