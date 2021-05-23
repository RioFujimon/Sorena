//
//  MenuViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メニュー画面の位置
        let menuPosition = self.menuView.layer.position
        // 初期位置設定
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示アニメーション
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPosition.x
            },
            completion: { bool in
            })
        
    }
    
    // メニュー外をタップした場合に非表示にする
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                    },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                    }
                )
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //ログアウト処理を行うアクション
    @IBAction func logoutAction(_ sender: Any) {
        //ログアウトする
        do{
            try Auth.auth().signOut()
            print("成功")
        }catch let signOutError as NSError {
            print("Error signing out:\(signOutError)")
        }
    }
    
}
