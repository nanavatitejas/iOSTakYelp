
import UIKit
import CoreLocation
import CoreLocation



class HomeScreenViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = nil
        table.dataSource = nil
        table.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeTableCell")
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        return table
    }()
    
    private let searchCategories = "burgers,pizza,mexican,chinese"
    var busniessViewModel = BusinessViewModel()
    
   // private var busniessViewModel : BusinessViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        checkConnectivity()
    }
    
    
    func initViewModel(){
        busniessViewModel.reloadTableView = {
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }
        busniessViewModel.showError = {
            DispatchQueue.main.async { self.showAlert() }
        }
        busniessViewModel.showLoading = {
            DispatchQueue.main.async { self.activityIndicatorBegin() }
        }
        busniessViewModel.hideLoading = {
            DispatchQueue.main.async { self.activityIndicatorEnd() }
        }
      
    }
    
    //MARK: - CheckInternetConnectivity
    
    func checkConnectivity () {
        let connectivity = Reachability.shared
        connectivity.checkNetwork { (status) in
            if status == true {
                DispatchQueue.main.async {
                        self.setUpTableView()
                        self.initViewModel()
                       
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.setUpTableView()
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    //MARK: - SetupUI
    private func setUpTableView() {
        self.view.addSubview(tableView)

        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    //MARK: - CheckLocationPermission
    
    func checkPermission() {
        if !hasLocationPermission() {
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                    //Redirect to Settings app
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                alertController.addAction(cancelAction)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
        }

    }
    
    
    //MARK: - HasLocationPermission
    func hasLocationPermission() -> Bool {
            var hasPermission = false
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    hasPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    hasPermission = true
                }
            } else {
                hasPermission = false
            }
            
            return hasPermission
        }
    
    

    //MARK: - FetchAnotherLocation
    // Fall back mechanism if by any chance lat long are not availablet than setting it to default lat long for london city
    private func fetchAnotherLocation() {
        self.activityIndicatorBegin()

        let lat =  51.50998
        let long =  -0.1337

        busniessViewModel.fetchBusinesses(lat: lat, long: long)

        }
}
    






//MARK: - TableView Delagate & Datasource
extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Search By"
        } else {
            return "Near By Restaurants"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.busniessViewModel.numberOfCells == 0 {
            return 1
        }
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let homeTableCell = tableView.dequeueReusableCell(withIdentifier: "homeTableCell", for: indexPath) as! HomeTableViewCell
        homeTableCell.cellDelegate = self
        homeTableCell.selectionStyle = .none

        if indexPath.section == 0 {
            homeTableCell.numberOfRows = 2
        } else{
            homeTableCell.numberOfRows = 4
            homeTableCell.busniessViewModel = self.busniessViewModel
            homeTableCell.collection.reloadData()
        }
        return homeTableCell
    }
    
    
}


//MARK: - CollectionViewCellDelegate
// Get Data from collectionCell

extension HomeScreenViewController: CollectionViewCellDelegate {
    func collectionView(collectionviewcell: HomeCollectionViewCell?, index: Int, didTappedInTableViewCell: HomeTableViewCell, term: String?,business:Business?) {
        
        if term == ""{
            if index == 3 {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let restaurantsListVC = storyBoard.instantiateViewController(withIdentifier: "RestaurantsListViewController") as! RestaurantsListViewController
                restaurantsListVC.busniessViewModel = self.busniessViewModel
                restaurantsListVC.busniessViewModel.searchTerm = ""
                navigationController?.pushViewController(restaurantsListVC, animated: true)
                return
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailVC.selectedDataDetailIndex = index

            detailVC.detailViewModel = self.busniessViewModel
            //detailVC.detailViewModel.business = business
            let indexPath = IndexPath(item: index, section: 0)
            saveLocally(indexPath: indexPath)

            navigationController?.pushViewController(detailVC, animated: true)
            
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let restaurantsListVC = storyBoard.instantiateViewController(withIdentifier: "RestaurantsListViewController") as! RestaurantsListViewController
            restaurantsListVC.busniessViewModel = self.busniessViewModel
            restaurantsListVC.busniessViewModel.searchTerm = term ?? ""
                navigationController?.pushViewController(restaurantsListVC, animated: true)
        }
        }
        
}




//MARK: - Saving to Coredata

extension HomeScreenViewController {
    func saveLocally(indexPath:IndexPath ) {
        let coreDataVM = BussinessCoreDataViewModel()
        let cellVM = busniessViewModel.getCellViewModel( at: indexPath )
        coreDataVM.saveLocally(detailVM: cellVM)
       
       // coreDataVM.saveLocally(detailVM: detailVM)
    }
}

//MARK: - Show Alert

extension HomeScreenViewController {
    func showAlert() {
        let alert = UIAlertController(title: "No Data Found", message: "No Data Found in your current location we are working on it to bring it to your location.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            self.dismiss(animated: true, completion: nil)
        }
        // For now another location is set to london
        let tryAction = UIAlertAction(title: "Try with other location", style: .cancel) { (tryAction) in
            self.fetchAnotherLocation()
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(tryAction)
        alert.preferredAction = okAction
        
        DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
    }
}
