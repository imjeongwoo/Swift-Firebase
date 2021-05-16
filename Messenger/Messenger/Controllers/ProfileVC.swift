//
//  ProfileVC.swift
//  Messenger
//
//  Created by 임정우 on 2021/05/13.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let data = ["로그아웃"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    


}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "로그아웃",
                                      style: .destructive,
                                      handler: { [weak self] action in
                                        //로그아웃
                                        do {
                                            try FirebaseAuth.Auth.auth().signOut()
                                            
                                            let vc = LoginVC()
                                            let nav = UINavigationController(rootViewController: vc)
                                            
                                            nav.modalPresentationStyle = .fullScreen
                                            self?.present(nav, animated: true, completion: nil)
                                            
                                        } catch  {
                                            print("로그아웃 실패!")
                                        }
        }))
        
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
