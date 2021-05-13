//
//  RegisterVC.swift
//  Messenger
//
//  Created by 임정우 on 2021/05/13.
//

import UIKit
import Photos
import FirebaseAuth

class RegisterVC: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return imageView
    }()
    
    private let nickNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "닉네임"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "이메일"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let domainLabel: UILabel = {
        let label = UILabel()
        label.text = "@dgu.ac.kr"
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        return label
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "비밀번호"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
    }()
    
   
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "회원가입"
        view.backgroundColor = .white
 
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)
        
        nickNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nickNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(domainLabel)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePicture))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc func didTapChangeProfilePicture() {
        print("Change picture called")
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        nickNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: nickNameField.bottom + 10,
                                  width: (scrollView.width - 60) / 2,
                                  height: 52)
        
        domainLabel.frame = CGRect(x: emailField.width + 30,
                                  y: nickNameField.bottom + 10,
                                  width: (scrollView.width - 60) / 2,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
    }
    
    @objc private func registerButtonTapped() {
        nickNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let nickName = nickNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !nickName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6
        else {
            alertUserLoginError()
            return
        }
        
        // Firebase Login
        DatabaseManager.shared.uesrExists(with: email) { [weak self] exists in
            
            guard !exists else {
                // user alreay exists
                self?.alertUserLoginError(message: "이미 존재하는 메일입니다.")
                return
                
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("에러가 발생했습니다.")
                    return
                }
                
                DatabaseManager.shared.insertUser(with: ChatAppUser(nickName: nickName,
                                                                    emailAddress: email))
                
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func alertUserLoginError(message: String = "모든 정보를 입력해주세요.") {
        let alert = UIAlertController(title: "알림",
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

extension RegisterVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nickNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "프로필 사진",
                                            message: "사진을 어떻게 가져올까요?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "카메라로 촬영하기",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.openCamera()
                                            }))
                              
        actionSheet.addAction(UIAlertAction(title: "앨범에서 가져오기",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.openLibrary()
                                            }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] authorizationsStatus in
                switch authorizationsStatus {
                case .limited:
                    completion()
                    print("limited authorization granted\n")
                case .authorized:
                    completion()
                    print("authorization granted")
                default:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "알림",
                                                      message: "설정에서 사진권한을 \'허용\' 해주세요.",
                                                      preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "확인",
                                                      style: .cancel, handler: nil))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func openCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func openLibrary() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true

        self.requestPHPhotoLibraryAuthorization { [weak self] in
            
            DispatchQueue.main.async {
                self?.present(vc, animated: true, completion: nil)
            }
            
        }
    }
}
