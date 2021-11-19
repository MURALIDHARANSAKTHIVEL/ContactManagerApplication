//
//  HeaderView.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/13/21.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView, CellReusableIdentifier {
    static var identifier: String = "HeaderView"
    
    @IBOutlet weak var titleUILabel: UILabel!
    var orderTapped: (()->Void)? /// Order change completion
    
    @IBOutlet weak var orderButton: UIButton!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    static var nib: UINib {
        return .init(nibName: HeaderView.identifier, bundle: nil)
    }
    /// UI Model change
    /// `DescContactOrder` - bool key - used for the Order change store in local device . Is user in differee
    func set(from item: ContactUIModel?) {
        titleUILabel.text = item?.title
        orderButton.isSelected = UserDefaults.standard.bool(forKey: "DescContactOrder")
    }
    @IBAction func orderAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UserDefaults.standard.set(sender.isSelected, forKey: "DescContactOrder")
        orderTapped?()
    }
    /// Callback - When User change the Order
    func sortingTapped(_ sender: @escaping () -> Void ) {
        orderTapped = sender
    }
}
