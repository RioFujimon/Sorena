//
//  ReserveViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import EMAlertController

class ReserveViewController: UIViewController{

    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var reserveButton: UIButton!
    
    var pickerView = UIPickerView()
    var userId = String()
    var userName = String()
    var partnerId = String()
    var partnerName = String()
    var year = String()
    var month = String()
    var day = String()
    
    
    
    
    let list: [String] = ["00:00", "00:30",
                "01:00", "01:30",
                "02:00", "02:30",
                "03:00", "03:30",
                "04:00", "04:30",
                "05:00", "05:30",
                "06:00", "06:30",
                "07:00", "07:30",
                "08:00", "08:30",
                "09:00", "09:30",
                "10:00", "10:30",
                "11:00", "11:30",
                "12:00", "12:30",
                "13:00", "13:30",
                "14:00", "14:30",
                "15:00", "15:30",
                "16:00", "16:30",
                "17:00", "17:30",
                "18:00", "18:30",
                "19:00", "19:30",
                "20:00", "20:30",
                "21:00", "21:30",
                "22:00", "22:30",
                "23:00", "23:30"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        memoTextView.layer.borderColor = UIColor.darkGray.cgColor
        memoTextView.layer.borderWidth = 1.0
        memoTextView.layer.cornerRadius = 15
        startTimeTextField.layer.borderColor = UIColor.darkGray.cgColor
        startTimeTextField.layer.borderWidth = 1.0
        startTimeTextField.layer.cornerRadius = 10
        endTimeTextField.layer.borderColor = UIColor.darkGray.cgColor
        endTimeTextField.layer.borderWidth = 1.0
        endTimeTextField.layer.cornerRadius = 10
        reserveButton.layer.cornerRadius = 15
        
        
        let toolbar1 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done1))
        doneItem1.tintColor = UIColor.black
        toolbar1.setItems([spacelItem1, doneItem1], animated: true)
        
        let toolbar2 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done2))
        doneItem2.tintColor = UIColor.black
        toolbar2.setItems([spacelItem2, doneItem2], animated: true)
        
        // インプットビュー設定
        startTimeTextField.inputView = pickerView
        startTimeTextField.inputAccessoryView = toolbar1
        
        endTimeTextField.inputView = pickerView
        endTimeTextField.inputAccessoryView = toolbar2
        
    }
    
    // 決定ボタン押下
    @objc func done1() {
        startTimeTextField.endEditing(true)
        startTimeTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    
    // 決定ボタン押下
    @objc func done2() {
        endTimeTextField.endEditing(true)
        endTimeTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    
    
    @IBAction func reserveButtonAction(_ sender: Any) {
        if startTimeTextField.text != endTimeTextField.text && memoTextView.text != "" && startTimeTextField.text != "" && endTimeTextField.text != "" {
            Firestore.firestore().collection("Reserves").document(partnerId).collection("Reserve").document().setData(["userName": userName,"userId": userId,"partnerName": partnerName,"partnerId": partnerId,"memo": memoTextView.text,"date": "\(year):\(month):\(day)", "startTime": startTimeTextField.text, "endTime": endTimeTextField.text])
            //アラート機能の実装
            let alert = EMAlertController(icon: UIImage(named: "check"), title: "予約完了のお知らせ", message: "予約が完了しました")
            let doneAction = EMAlertAction(title: "ok", style: .normal)
            alert.addAction(doneAction)
            present(alert, animated: true, completion: nil)
            
            startTimeTextField.text = "00:00"
            endTimeTextField.text = "00:00"
            memoTextView.text = ""
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ReserveViewController : UIPickerViewDelegate, UIPickerViewDataSource {
 
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    /*
    // ドラムロール選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = list[row]
    }
     */
    
    
    
}
