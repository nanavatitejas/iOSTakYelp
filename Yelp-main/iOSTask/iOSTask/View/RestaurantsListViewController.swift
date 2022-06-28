
import UIKit
import CoreData

class RestaurantsListViewController: UIViewController {

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = nil
        table.dataSource = nil
        table.register(RestaurantsListTableViewCell.self, forCellReuseIdentifier: "restaurantsListTableCell")
       /// table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        //table.tableFooterView = UIView()
        return table
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        return searchController

    }()
    var busniessViewModel = BusinessViewModel()


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Restaurants"
        setRightBarButton()
        
        let connectivity = Reachability.shared
        connectivity.checkNetwork { (status) in
            if status == true {
                DispatchQueue.main.async {
                    self.setUpTableView()
                    self.activityIndicatorBegin()
                    self.initViewModel()
                    self.setSeachBar()
                    if self.busniessViewModel.searchTerm.count != 0{
                        self.busniessViewModel.fetchBusinesses()
                       // self.fetchBusiness()

                    } else {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                        self.activityIndicatorEnd()

                    }
                }
            } else {
                self.busniessViewModel.getLocallySavedData()
                
                    DispatchQueue.main.async {
                        self.setUpTableView()
                      //  self.busniessViewModel.busniess = businesses
                        self.tableView.delegate = self
                        self.tableView.dataSource = self

                        self.tableView.reloadData()
                    }
                }
            
        }
        
        

    }
    
    func initViewModel(){
        busniessViewModel.reloadTableView = {
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }
        
        busniessViewModel.showLoading = {
            DispatchQueue.main.async { self.activityIndicatorBegin() }
        }
        busniessViewModel.hideLoading = {
            DispatchQueue.main.async { self.activityIndicatorEnd() }
        }
      
    }
    
    
    //MARK: - SetUpUI
    private func setUpTableView() {
        self.view.addSubview(tableView)

        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    private func setSeachBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setRightBarButton(){
        let filterButton  : UIBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItem.Style.plain, target: self, action: #selector(filterButtonPressed))
        self.navigationItem.rightBarButtonItem = filterButton

    }
    
    //MARK: -  Button Action
    @objc func filterButtonPressed() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)

        let filterVC = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        filterVC.modalPresentationStyle = .fullScreen

        
        let navController = UINavigationController(rootViewController: filterVC)
        filterVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        
        filterVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))

        self.navigationController!.present(navController, animated: true, completion: nil)

       
        
    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        self.activityIndicatorBegin()
        busniessViewModel.fetchFilteredBusinesses()
    }
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        busniessViewModel.resetFilterData()
    }

}

//MARK: - TableView Delagate & Datasource

extension RestaurantsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.busniessViewModel.numberOfFilteredCells == 0 {
            return self.busniessViewModel.numberOfCells

        } else {
            return self.busniessViewModel.numberOfFilteredCells

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurantsListTableCell = tableView.dequeueReusableCell(withIdentifier: "restaurantsListTableCell", for: indexPath) as! RestaurantsListTableViewCell
        if self.busniessViewModel.numberOfFilteredCells == 0 {
            let cellVM = busniessViewModel.getCellViewModel( at: indexPath )
            restaurantsListTableCell.lblName.text = cellVM.name + "\n" + cellVM.city
        } else {
            let cellVM = busniessViewModel.getFilteredCellViewModel(at: indexPath )

            restaurantsListTableCell.lblName.text = cellVM.name + "\n" + cellVM.city
        }
        return restaurantsListTableCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.selectedDataDetailIndex = indexPath.row
        detailVC.detailViewModel = self.busniessViewModel
        saveLocally(indexPath: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
//MARK: - UISearchBar &  UISearchResults Delagate

extension RestaurantsListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.busniessViewModel.searchTerm = searchBar.text ?? ""
        self.activityIndicatorBegin()
        self.tableView.isHidden = true
        busniessViewModel.fetchBusinesses()
        

    }
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        //your code here....
    }
}

//MARK: - Saving to CoreData

extension RestaurantsListViewController {
    func saveLocally(indexPath:IndexPath ) {
        
        
        if self.busniessViewModel.numberOfFilteredCells == 0 {
            let cellVM = busniessViewModel.getCellViewModel( at: indexPath )
            let coreDataVM = BussinessCoreDataViewModel()
            coreDataVM.saveLocally(detailVM: cellVM)
        } else {
            let cellVM = busniessViewModel.getFilteredCellViewModel(at: indexPath )
            let coreDataVM = BussinessCoreDataViewModel()
            coreDataVM.saveLocally(detailVM: cellVM)

        }
        
        
       
    }
}
