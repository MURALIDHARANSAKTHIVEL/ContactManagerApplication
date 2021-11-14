//
//  ViewController.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import UIKit

class ContactViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var searchTextField: UISearchBar!
    var viewmodel: ContactListViewModel = ContactListViewModel() /// Viewmodel for store Data to show UI
    var searchActivate: Bool = false /// Is User active in Search Sessions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    ///Initial Setup for UI config
    private func initialSetup() {
        self.tableview.register(ContactTableViewCell.nib, forCellReuseIdentifier: ContactTableViewCell.identifier)
        self.tableview.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        self.searchTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refreshUIModel()
    }
    /// Back the UI to refresh the Viewmodel data
    private func refreshUIModel() {
        self.viewmodel.contactList = UserManager.shared.contactList
        self.navigationSetup()
        if searchActivate { /// To check the Active and group the unsorted list
            viewmodel.ungroupedContactList = UserManager.shared.contacts
            self.viewmodel.searchList(searchTextField.text ?? "", isActive: true)
        }
        self.tableview.reloadData()
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
}
///Mark:- Seperation of code - UITableView Configuration
extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    ///Mark:- Based on searchActivate key
    ///show the Sorted list and Filter List result
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActivate == false ? viewmodel.rowCount(section: section) : (viewmodel.filterContactList?.count ?? 0)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchActivate == false ? viewmodel.count : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as? ContactTableViewCell
        let model =  searchActivate == false ? viewmodel[indexPath] : viewmodel.filterContactList?[indexPath.row]
        cell?.set(from: model ?? .init())
        cell?.cellSelectedAction {
            self.performSegue(withIdentifier: ContactEditViewController.identifier, sender: model)
        }
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        return searchActivate == false ? 40 : 0
    }
}
///Mark:- Seperation of code - UISearchbar Configuration
extension ContactViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {
            self.searchActivate = false
            self.tableview.reloadData()
            return
        }
        self.searchActivate = true
        self.viewmodel.searchList(searchText, isActive: true)
        self.tableview.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchTextField.text == "" || searchTextField.text == nil {
            searchActivate = false
        }
        searchTextField.resignFirstResponder()
        self.tableview.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActivate = false
        self.tableview.reloadData()
    }
}
