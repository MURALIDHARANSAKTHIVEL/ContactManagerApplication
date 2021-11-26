//
//  ContactTableViewCell.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import UIKit
///Common protocal for all cell indentifier
protocol CellReusableIdentifier {
    static var identifier: String {get set}
}
class ContactTableViewCell: UITableViewCell, CellReusableIdentifier {
    static var identifier: String = "ContactTableViewCell"
    @IBOutlet weak var profileViewImageView: UIImageView!
    @IBOutlet weak var nameUIlabel: UILabel!
    @IBOutlet weak var companyUIlabel: UILabel!
    var cellTapped: (()->Void)? /// cell Action Completion
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.uiSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    static var nib: UINib {
        return UINib.init(nibName: ContactTableViewCell.identifier, bundle: nil)
    }
    ///UI Setup for Image rounder corner
    private func uiSetup() {
        self.profileViewImageView.layer.cornerRadius = profileViewImageView.frame.size.height / 2
    }
    /// Customize UI Model Setup
    func set(from item: Contactdetails) {
        nameUIlabel.text = item.name
        companyUIlabel.text = item.company
        profileViewImageView.image = UIImage.init(data: item.profile ?? Data())?.imageResize(withSize: .init(width: 75, height: 75))
    }
    ///Usage - callback method When user click the Cell
    ///this can also achive by didSelect tableView method
    func cellSelectedAction( _ sender: @escaping(()->Void)) {
        cellTapped = sender
        
    }
    @IBAction func cellAction(_ sender: Any) {
        cellTapped?()
    }
}

