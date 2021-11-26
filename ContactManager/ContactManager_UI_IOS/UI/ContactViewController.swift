//
//  ViewController.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import UIKit

class ContactViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    var contacts = [Contacts]()
    @IBOutlet weak var searchTextField: UISearchBar!
    var viewmodel: ContactListViewModel = ContactListViewModel() /// Viewmodel for store Data to show UI
    var searchActivate: Bool = true /// Is User active in Search Sessions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
        //contacts = CoreDataManager.shared.fetchAllData(Contacts.self) ?? []
    }
    ///Initial Setup for UI config
    private func initialSetup() {
        self.tableview.register(ContactTableViewCell.nib, forCellReuseIdentifier: ContactTableViewCell.identifier)
        self.tableview.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        self.searchTextField.delegate = self
        tableview.dragInteractionEnabled = viewmodel.sortOrderType == .ReOrder // Enable intra-app drags for iPhone.
        tableview.dragDelegate = self
        tableview.dropDelegate = self
        self.tableview.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refreshUIModel()
    }
    /// Back the UI to refresh the Viewmodel data
    private func refreshUIModel() {
        self.navigationSetup()
        /// To check the Active and group the unsorted list
        viewmodel.ungroupedContactList = UserManager.shared.contactDetails
        self.viewmodel.contactList = UserManager.shared.contactList
        if viewmodel.sortOrderType == .ReOrder {
        viewmodel.sortedOrder()
        }
        self.viewmodel.searchList(searchTextField.text ?? "", isActive: viewmodel.searchIsActive)
        self.tableview.reloadData()
        self.navigationleftBarItem()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    private func navigationSetup() {
        self.title = "Contact Manager"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  == ContactEditViewController.identifier {
            if let vc = segue.destination as? ContactEditViewController {
                /// Pass the current selected model
                vc.viewModel.profilemodel = sender as? Contacts ?? Contacts()
            }
        }
    }
    private func navigationleftBarItem() {
        let usersItem = UIAction(title: "custom order", image: UIImage(systemName: "person.fill")) { (action) in
            self.sortOrderMethod(.ReOrder)
        }
        
        let addUserItem = UIAction(title: "A-Z", image: UIImage(systemName: "arrow.down")) { (action) in
            self.sortOrderMethod(.AToZ)
        }
        
        let removeUserItem = UIAction(title: "Z-A", image: UIImage(systemName: "arrow.up")) { (action) in
            self.sortOrderMethod(.ZToA)
        }
        
        let menu = UIMenu( options: .destructive , children: [usersItem , addUserItem , removeUserItem])
        let navItems = [UIBarButtonItem(image:  UIImage(systemName: "plus"), menu: menu)]
        self.navigationItem.rightBarButtonItems = navItems
    }
    private func sortOrderMethod(_ sortOrder: SortOrderType) {
        self.viewmodel.sortOrderType = sortOrder
        self.viewmodel.sortedOrder()
        self.tableview.reloadData()
        self.tableview.dragInteractionEnabled = sortOrder == .ReOrder
        self.searchTextField.text = ""
    }
}
///Mark:- Seperation of code - UITableView Configuration
extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    ///Mark:- Based on searchActivate key
    ///show the Sorted list and Filter List result
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.rowCount(section: section)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewmodel.secondCount    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as? ContactTableViewCell
        let model =  viewmodel[indexPath]
        cell?.set(from: model ?? Contactdetails() )
        cell?.cellSelectedAction {
            let selectedmodel = self.viewmodel.pickSelectedContact(index: indexPath)
            self.performSegue(withIdentifier: ContactEditViewController.identifier, sender: selectedmodel)
        }
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewmodel.searchIsActive == false && viewmodel.sortOrderType != .ReOrder else {
            return UIView()
        }
        guard let headerView = tableview.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier ) as? HeaderView else {
            fatalError("Unable to cast to HeaderView")
        }
        headerView.set(from: viewmodel[section])
        headerView.orderButton.isHidden = (searchActivate == false && section == 0) ? false : true
        ///Callabck from Cell to sorting
        headerView.sortingTapped {
            self.viewmodel.searchList("", isActive: false)
            self.tableview.reloadData()
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewmodel.sortOrderType == .ReOrder { /// no need for custom Order
            return 0
        } else {
            return viewmodel.searchIsActive == false ? 40 : 0
        }
        
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        /// to get source and destination
        viewmodel.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        self.tableview.reloadData()
    }
}
///Mark:- Seperation of code - UISearchbar Configuration
extension ContactViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {
            self.viewmodel.searchIsActive = false
            self.tableview.dragInteractionEnabled = viewmodel.sortOrderType == .ReOrder
            self.tableview.reloadData()
            return
        }
        self.viewmodel.searchIsActive = true
        self.viewmodel.searchList(searchText, isActive: true)
        self.tableview.dragInteractionEnabled = false
        self.tableview.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchTextField.text == "" || searchTextField.text == nil {
            self.viewmodel.searchIsActive = false
        }
        searchTextField.resignFirstResponder()
        self.tableview.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActivate = false
        self.tableview.reloadData()
    }
}

extension ContactViewController: UITableViewDragDelegate {
    // MARK: - UITableViewDragDelegate
    /**
     The `tableView(_:itemsForBeginning:at:)` method is the essential method
     to implement for allowing dragging from a table.
     */
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return viewmodel.dragItems(for: indexPath)
    }
}


extension ContactViewController: UITableViewDropDelegate {
    // MARK: - UITableViewDropDelegate
    
    /**
     Ensure that the drop session contains a drag item with a data representation
     that the view can consume.
     */
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
        
    }
    
    /**
     A drop proposal from a table view includes two items: a drop operation,
     typically .move or .copy; and an intent, which declares the action the
     table view will take upon receiving the items. (A drop proposal from a
     custom view does includes only a drop operation, not an intent.)
     */
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)
        
        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }
        
        // The .move drag operation is available only for dragging within this app and while in edit mode.
        if tableView.hasActiveDrag {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            // Drag is coming from outside the app.
            dropProposal = UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        
        return dropProposal
    }
    
    /**
     This delegate method is the only opportunity for accessing and loading
     the data representations offered in the drag item. The drop coordinator
     supports accessing the dropped items, updating the table view, and specifying
     optional animations. Local drags with one item go through the existing
     `tableView(_:moveRowAt:to:)` method on the data source.
     */
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            let reorderList = items as! [Contacts]
            
            var indexPaths = [IndexPath]()
            for (index, item) in reorderList.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                self.viewmodel.addItem(item, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
