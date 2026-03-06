import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    // Preset fonts
    let fonts = ["System", "Helvetica", "Courier", "Times New Roman", "Avenir"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeSwitch.isOn = false
        // Set up the profile image view
        if let savedImageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let savedImage = UIImage(data: savedImageData) {
            profileImageView.image = savedImage
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        // Load dark mode setting
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkMode")
        soundSwitch.isOn = AppSettings.shared.isSoundEnabled
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileChangeView", let profileVC = segue.destination as? ProfileViewController {
            profileVC.delegate = self
        }
    }
    
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        AppSettings.shared.isDarkModeEnabled = sender.isOn
        AppSettings.shared.applyDarkMode()
    }
    
    @IBAction func soundToggled(_ sender: UISwitch) {
        AppSettings.shared.isSoundEnabled = sender.isOn
    }
}
