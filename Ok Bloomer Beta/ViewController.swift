import UIKit
import CoreBluetooth
import UserNotifications
import AudioToolbox

protocol CommandSender {
    func otherSendCommand(command: String)
    func changeItems(x: Float)
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CommandSender {
    
    
    var items = ["temp", "humidity", "light", "moisture", "OFF", "2.5 min"]
    var itemLabels = ["Temperature (F):", "Humidity:", "Brightness:", "Moisture", "Light:", "Pump config:"]
    var delegate: UIViewController!
    
    
    // Bluetooth properties
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral?
    var arduinoCharacteristic: CBCharacteristic?
    var soundID: SystemSoundID = 0
    
    // UUIDs for services and characteristics (replace with your module's UUIDs)
    let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
    let characteristicUUID = CBUUID(string: "abcdef01-1234-5678-1234-56789abcdef0")
    
    // UI elements
    //    @IBOutlet weak var temperatureLabel: UILabel!
    //    @IBOutlet weak var humidityLabel: UILabel!
    //    @IBOutlet weak var lightLabel: UILabel!
    //    @IBOutlet weak var moistureLabel: UILabel!
    //    @IBOutlet weak var pumpSlider: UISlider!
    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var sliderValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        collectionView.delegate = self
        collectionView.dataSource = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
            print("Notification permission granted: \(granted)")
        }
        if let soundURL = Bundle.main.url(forResource: "clickSound", withExtension: "wav") {
                    AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
                }
        
//        applyFont()
//        NotificationCenter.default.addObserver(self, selector: #selector(applyFont), name: NSNotification.Name("FontChanged"), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
        cell.myLabel2.text = itemLabels[indexPath.row]
        cell.myLabel.text = items[indexPath.row]
        cell.myLabel.numberOfLines = 0
//        let fontName = AppSettings.shared.selectedFont
//        cell.myLabel.font = fontName == "System" ? UIFont.systemFont(ofSize: 17) : UIFont(name: fontName, size: 17)
//        cell.myLabel2.font = fontName == "System" ? UIFont.systemFont(ofSize: 17) : UIFont(name: fontName, size: 17)
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 30
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 5 {
            performSegue(withIdentifier: "toPumpView", sender: self)
        }
        if indexPath.item == 4 {
            if items[4] == "ON" {
                items[4] = "OFF"
                collectionView.reloadData()
                toggleLightSwitch(false)
            } else {
                items[4] = "ON"
                toggleLightSwitch(true)
                collectionView.reloadData()
            }
        }
        if AppSettings.shared.isSoundEnabled {
                   AudioServicesPlaySystemSound(soundID)
        }
    }
    deinit {
            
            AudioServicesDisposeSystemSoundID(soundID)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPumpView",
           let nextVC = segue.destination as? PumpViewController {
            nextVC.delegate = self
            nextVC.defaultSliderValue = Float(items[5].components(separatedBy: " ")[0])
        }
        if segue.identifier == "toPowerView", let powerVC = segue.destination as? PowerViewController {
            powerVC.delegate = self
        }
        
    }
    
    
    // MARK: - Bluetooth Central Manager Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            if let powerVC = delegate as? PowerViewController {
                powerVC.changeText("Bluetooth is not available")
            }
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let powerVC = delegate as? PowerViewController {
            powerVC.changeText("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        }
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        arduinoPeripheral = peripheral
        arduinoPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if let powerVC = delegate as? PowerViewController {
            powerVC.changeText("Connecting to \(peripheral.name ?? "Arduino...")")
        }
        print("Connected to \(peripheral.name ?? "Arduino")")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if let powerVC = delegate as? PowerViewController {
                    powerVC.changeText("Discovered service: \(service.uuid)")
                }
                print("Discovered service: \(service.uuid)")
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    if let powerVC = delegate as? PowerViewController {
                        powerVC.changeText("Arduino successfully connected")
                    }
                    print("Discovered characteristic: \(characteristic.uuid)")
                    arduinoCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let jsonString = String(data: data, encoding: .utf8) {
            updateSensorData(jsonString: jsonString)
        }
    }
    
    // MARK: - Helper Methods
    
    func updateSensorData(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if let temperature = json["temperature"] as? Double {
                    items[0] = "\(temperature)°F"
                }
                if let humidity = json["humidity"] as? Double {
                    items[1] = "\(humidity)%"
                }
                if let light = json["light"] as? Int {
                    items[2] = "\(light == 0 ? "Dark" : "Bright")"
                    if light == 0 {
                        sendNotification(for: "The sensor reading indicates it's dark!")
                    }
                }
                if let moisture = json["soil_moisture"] as? Int {
                    items[3] = "\(moisture)"
                }
                self.collectionView.reloadData()
            }
        } catch {
            print("Error parsing sensor data: \(error)")
        }
    }
    
    func sendCommand(_ command: String) {
        guard let characteristic = arduinoCharacteristic, let data = command.data(using: .utf8) else { return }
        arduinoPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        print(command)
    }
    
    func changeItems(x: Float) {
        items[5] = "\(String(format: "%.2f", x)) min"
        collectionView.reloadData()
    }
    
    
    func otherSendCommand(command: String) {
        sendCommand(command)
    }
    //
    //    // MARK: - Actions
    //
    //    @IBAction func toggleLightSwitch(_ sender: UISwitch) {
    //        let command = sender.isOn ? "LIGHT_ON" : "LIGHT_OFF"
    //        sendCommand(command)
    //        print("Sent command: \(command)")
    //    }
    func toggleLightSwitch(_ state: Bool) {
        var command = ""
        if state {
            command = "LIGHT_ON"
        } else {
            command = "LIGHT_OFF"
        }
        sendCommand(command)
        print("Sent command: \(command)")
    }
    
    func sendNotification(for message: String) {
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Sensor Alert"
        content.body = message
        content.sound = .default
        
        // Create a trigger (immediate for now)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create a request with a unique identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled: \(message)")
            }
        }
        
    }


    
    //
    //    @IBAction func pumpStartButtonPressed(_ sender: UIButton) {
    //        let duration = Int(pumpSlider.value)
    //        let command = "PUMP_START_\(duration)"
    //        sendCommand(command)
    //        print("Sent command: \(command)")
    //    }
    //
    //    @IBAction func sliderValueChanged(_ sender: UISlider) {
    //        // Round slider to nearest 5-second increment
    //        let step: Float = 5
    //        let roundedValue = round(sender.value / step) * step
    //        sender.value = roundedValue
    //
    //        // Update the slider value label
    //        sliderValueLabel.text = "Pump Duration: \(Int(roundedValue))s"
    //    }
}
