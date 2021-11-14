//
//  ContactListTableViewCell.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import UIKit

class ContactListTableViewCell: UITableViewCell, CellReusableIdentifier, UITextViewDelegate {
    static var identifier: String = "ContactListTableViewCell"
    @IBOutlet weak var textView: UITextView!
    var indexPath: IndexPath?
    var model: [KeyValueModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    static var nib: UINib {
        return .init(nibName: ContactListTableViewCell.identifier, bundle: nil)
    }
    /// Customize UI Model Setup
    func set(from item: String, indexPath: IndexPath, model: [KeyValueModel], mode: ProfileMode) {
        self.textView.isEditable = mode == .edit ? false : true
        self.textView.isSelectable = mode == .edit ? false : true
        self.indexPath = indexPath
        self.model = model
        self.textView.text = item
    }
    
}
///Mark:- Usage - For Using seperation code implememtation for TextView Delegate
extension ContactListTableViewCell {
    func textViewDidChange(_ textView: UITextView) {
        self.model![indexPath?.section ?? 0].value![indexPath?.row ?? 0] = self.textView.text
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
