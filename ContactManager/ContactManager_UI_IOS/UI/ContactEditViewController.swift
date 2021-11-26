//
//  ContactEditViewController.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import UIKit

class ContactEditViewController: UIViewController, StoryBoardSegueIdentifier, UINavigationControllerDelegate  {
    static var identifier: String = "showContactEdit"
    @IBOutlet weak var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    var imageView: UIImageView!
    var viewModel: ContactEditViewModel = ContactEditViewModel()
    var profilemode: ProfileMode = .edit { /// To change the Navigation based of profileMode
        ///edit - Normal mode
        ///save - editing to save  mode
        didSet {
            self.navigationSetup()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    ///Initial Setup for UI config
    private func initialSetup() {
        self.tableView.register(ContactListTableViewCell.nib, forCellReuseIdentifier: ContactListTableViewCell.identifier)
        self.tableView.register(ContactEditProfileTableViewCell.nib, forCellReuseIdentifier: ContactEditProfileTableViewCell.identifier)
        self.tableView.register(ContactTableViewCell.nib, forCellReuseIdentifier: ContactTableViewCell.identifier)
        self.tableView.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        self.navigationSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        viewModel.makeKeyValuePair()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func navigationSetup() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Details"
        let editButton = UIBarButtonItem.init(
            title: profilemode.title,
            style: .plain, target: self,
            action: #selector(save))
        editButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = editButton
    }
    @objc func save() {
        if profilemode == .save {
            viewModel.mappingUpdatedValue()
        }
        profilemode = profilemode == .edit ? .save : .edit
        self.navigationSetup()
        self.tableView.reloadData()
    }
    
    @IBAction func callAction(_ sender: Any) {
        /// formatter the Mobile number
        let number = viewModel.profilemodel?.phone ?? ""
        let  formatter = viewModel.phoneFormatter(phonenumber: number)
        guard let url = URL(string: "tel://\(formatter)") else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func mailAction(_ sender: Any) {
        self.openMailUrl()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title: "Alerts", message: "Are you sure want to delete?", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {_ in
            /// remove the selected model
            CoreDataManager.shared.delete(model: self.viewModel.profilemodel)
//            UserManager.shared.contacts?.removeAll(where: {$0 == self.viewModel.profilemodel })
//            CoreDataManager.shared.context.delete( self.viewModel.profilemodel ?? Contacts())
//            try! CoreDataManager.shared.context.save()
            self.successMessage()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    /// Sucess the popup
    private func successMessage() {
        let alert = UIAlertController(title: "Sucess", message: "Contact has been deleted successfully.", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            _ in
            /// popup the backup screen
            self.navigationController?.popViewController(animated: true)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
extension ContactEditViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.rowCount(section: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactEditProfileTableViewCell.identifier, for: indexPath) as? ContactEditProfileTableViewCell
            /// callback from cell when user tap Imageview
            cell?.imageEditTaped {
                self.imageView = cell?.profileUIImageview /// Imageview reference
                self.imagePicker.delegate = self
                self.viewModel.profileIndexPath = indexPath /// to reload the particular section & row
                self.self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            let model = viewModel.keyValueModel[indexPath.section]
            cell?.set(from: model, mode: profilemode)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.identifier, for: indexPath) as? ContactListTableViewCell
            let model = viewModel.keyValueModel[indexPath.section].value![indexPath.row]
            cell?.set(from: model, indexPath: indexPath, model: viewModel.keyValueModel, mode: profilemode)
            if indexPath.section == 1 { /// For the Phone Number keyboard Setup
                cell?.textView.keyboardType = .numberPad
                cell?.textView.addDoneButtonOnKeyboard()
            }
            return cell ?? UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension: UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier ) as? HeaderView else {
                fatalError("Unable to cast to HeaderView")
            }
            let model = viewModel.keyValueModel[section]
            headerView.titleUILabel.text = model.title
            headerView.titleUILabel.textColor = .red
            headerView.backgroundColor = .white
            return headerView
        }
        return UIView()
    }
    /// Reload the row
    private func reloadTableView() {
        self.tableView.reloadRows(at: [viewModel.profileIndexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
}
///Mark:- Seperation of code - Open Url and Custom Configuration
extension ContactEditViewController: UIImagePickerControllerDelegate {
    ///Open Mail url
    func openMailUrl() {
        if let url = URL(string: "mailto:\(viewModel.profilemodel?.email ?? "")") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    /// Image picker Configuration
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleToFill
            imagePicker.allowsEditing = false
            imageView.image = pickedImage
            if let jpegData = pickedImage.jpegData(compressionQuality: 0.75) {
                viewModel.setProifleDataSource(data: jpegData)
            }
            
        }
        dismiss(animated: true, completion: nil)
        self.reloadTableView()
    }
    
}
///Mark:- Seperation of code - keyboard Configuration
extension ContactEditViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + tableView.rowHeight, right: 0)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
}
