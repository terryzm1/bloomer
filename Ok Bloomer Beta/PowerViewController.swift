//
//  PowerViewController.swift
//  Ok Bloomer Beta
//
//  Created by Terry Zhang on 12/1/24.
//

import UIKit

protocol ConnectionChecker: AnyObject {
    func changeText(_ status: String)
}

class PowerViewController: UIViewController, ConnectionChecker {
    
    @IBOutlet weak var connectionLabel: UILabel!
    weak var delegate: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionLabel.numberOfLines = 0
        print("Delegate: \(String(describing: delegate))")
        applyFont()
        NotificationCenter.default.addObserver(self, selector: #selector(applyFont), name: NSNotification.Name("FontChanged"), object: nil)
    }

    
    
    func changeText(_ status: String) {
        print("changeText called with status: \(status)")
        connectionLabel.text = status
    }
    @objc func applyFont() {
        let fontName = AppSettings.shared.selectedFont
//        someLabel.font = fontName == "System" ? UIFont.systemFont(ofSize: 17) : UIFont(name: fontName, size: 17)
    }
    

}
