//
//  PumpViewController.swift
//  Ok Bloomer Beta
//
//  Created by Terry Zhang on 12/1/24.
//

import UIKit

class PumpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waterLevelTextField: UITextField!
    @IBOutlet weak var slider: UISlider!
    
    var delegate: UIViewController!
    var defaultSliderValue: Float!
    var waterVol: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.minimumValue = 150
        slider.maximumValue = 300
        slider.value = defaultSliderValue * 60
        timeLabel.text = "Pump Duration: \(String(format: "%.2f", defaultSliderValue!)) min"
        waterLevelTextField.delegate = self
        applyFont()
        NotificationCenter.default.addObserver(self, selector: #selector(applyFont), name: NSNotification.Name("FontChanged"), object: nil)
        
    }
    
    
    @IBAction func startPump(_ sender: Any) {
        let mainVC = delegate as! CommandSender
        let duration = Int(slider.value)
        let command = "PUMP_START_\(duration)"
        mainVC.otherSendCommand(command: command)
        print(command)
        let vol = Float(duration) * 0.78
        if let temp = waterVol {
            var newVol = temp - vol
            waterVol = newVol
            waterLevelTextField.text = String(waterVol!)
        }
        
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        // Round slider to nearest 5-second increment
        let step: Float = 5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        timeLabel.text = "Pump Duration: \(String(format: "%.2f", roundedValue/60)) min"
        
        let mainVC = delegate as! CommandSender
        mainVC.changeItems(x: (roundedValue/60))
    }
    
    @IBAction func stopPump(_ sender: Any) {
        let mainVC = delegate as! CommandSender
        mainVC.otherSendCommand(command: "PUMP_STOP")
        print("PUMP_STOP")
    }
    
    @IBAction func updateButtonClicked(_ sender: Any) {
        waterVol = Float(waterLevelTextField.text!)
    }
    
    // Called when 'return' key pressed

    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func applyFont() {
//       let fontName = AppSettings.shared.selectedFont
//        someLabel.font = fontName == "System" ? UIFont.systemFont(ofSize: 17) : UIFont(name: fontName, size: 17)
    }
    
}
