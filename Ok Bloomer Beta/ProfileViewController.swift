import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the profile image view to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor

        // Load saved profile data
        if let savedName = UserDefaults.standard.string(forKey: "userName") {
            nameTextField.text = savedName
        }
        if let savedImageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let savedImage = UIImage(data: savedImageData) {
            profileImageView.image = savedImage
        }
        applyFont()
        NotificationCenter.default.addObserver(self, selector: #selector(applyFont), name: NSNotification.Name("FontChanged"), object: nil)
    }

    @IBAction func saveProfileTapped(_ sender: UIButton) {
        // Save profile name
        if let name = nameTextField.text {
            UserDefaults.standard.set(name, forKey: "userName")
        }

        // Save profile image
        if let profileImage = profileImageView.image,
           let imageData = profileImage.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "userProfileImage")
        }
    }

    @IBAction func changeProfilePictureTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Choose Profile Picture", message: "Select a source", preferredStyle: .actionSheet)

        // Option to use the Camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(sourceType: .camera)
            }))
        }

        // Option to use the Photo Library
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))

        // Cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    @objc func applyFont() {
        let fontName = AppSettings.shared.selectedFont
//        someLabel.font = fontName == "System" ? UIFont.systemFont(ofSize: 17) : UIFont(name: fontName, size: 17)
    }
}
