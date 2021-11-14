//
//  ContactEditProfileTableViewCell.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import UIKit

class ContactEditProfileTableViewCell: UITableViewCell, CellReusableIdentifier, UITextViewDelegate {
    static var identifier: String = "ContactEditProfileTableViewCell"
    
    @IBOutlet weak var profileUIImageview: UIImageView!
    @IBOutlet weak var nameUITextview: UITextView!
    @IBOutlet weak var companyTextView: UITextView!
    var model: KeyValueModel?
    var editmode: ProfileMode?
    var imageTapped: (()->Void)? ///Compeletion for ImageViewAction
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameUITextview.delegate = self
        self.companyTextView.delegate = self
        self.uiSetup()
    }
    private func uiSetup() {
        self.profileUIImageview.layer.cornerRadius = profileUIImageview.frame.size.height / 2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    static var nib: UINib {
        return .init(nibName: ContactEditProfileTableViewCell.identifier, bundle: nil)
    }
    /// To set value for the custom view
    /// index 0 - name
    /// index 1 - company
    func set(from item: KeyValueModel , mode: ProfileMode) {
        self.model = item
        self.nameUITextview.text = item.value?[0]
        self.companyTextView.text = item.value?[1]
        ///To Set Data Type to Image with
        ///with resolution 75 * 75
        self.profileUIImageview.image = UIImage.init(data: item.profileData ?? Data())?.imageResize(withSize: .init(width: 75, height: 75))
        self.editChanges(textView: nameUITextview, mode: mode)
        self.editChanges(textView: companyTextView, mode: mode)
        self.editmode = mode
    }
    ///To Config the TextView with editable / selectable
    private func editChanges(textView: UITextView, mode: ProfileMode) {
        textView.isEditable = mode == .edit ? false : true
        textView.isSelectable = mode == .edit ? false : true
    }
    
    @IBAction func imageEditAction(_ sender: Any) {
        if editmode == .save { /// Only Configure for save mode
            self.imageTapped?()
        }
    }
    ///To get the Call Back When tap the Image for edit Model
    public func imageEditTaped(_ sender: @escaping (()->Void) ) {
        self.imageTapped = sender
    }
}
///Mark:- Usage - For Using seperation code implememtation for TextView Delegate
extension ContactEditProfileTableViewCell {
    func textViewDidChange(_ textView: UITextView) {
        if textView == nameUITextview {
            model?.value?[0] = textView.text
        } else {
            model?.value?[1] = textView.text
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

