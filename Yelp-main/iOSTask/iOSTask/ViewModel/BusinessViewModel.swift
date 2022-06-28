
import Foundation
import CoreLocation

class BusinessViewModel:NSObject, CLLocationManagerDelegate {
    
    var userLocation = UserLocation(location: CLLocationManager())
    var searchTerm = ""

    //CallBacks
    var reloadTableView: (()->())?
    var showError: (()->())?
    var showLoading: (()->())?
    var hideLoading: (()->())?
    
    private var dataViewModels: [DataViewModel] = [DataViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    
    private var filtereddataViewModels: [DataViewModel] = [DataViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    
    override init() {
        super.init()
        self.userLocation.locationManager?.delegate = self

    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> DataViewModel {
        
        return dataViewModels[indexPath.row]
    }
    
    func getFilteredCellViewModel( at indexPath: IndexPath ) -> DataViewModel {
        
        return filtereddataViewModels[indexPath.row]
    }
    
    func resetFilterData(){
        filtereddataViewModels = [DataViewModel]()
    }
    
    
    func getDataDetail(selectedData:Int)-> DataViewModel {
        if filtereddataViewModels.count == 0 {
            return dataViewModels[selectedData]

        } else {
            return filtereddataViewModels[selectedData]

        }
    }
    var numberOfCells: Int {
        return dataViewModels.count
    }
    
    var numberOfFilteredCells: Int {
        return filtereddataViewModels.count 
    }
    
    //MARK: - FetchData

    func fetchBusinesses(lat : Double = 0.0, long: Double = 0.0) {
        let lat = self.userLocation.locationManager?.location?.coordinate.latitude ?? 0.0
        let long = self.userLocation.locationManager?.location?.coordinate.longitude ?? 0.0
        APIService.shared.fetchBusinesses(latitude: lat, longitude: long, radius: 40000, sortBy: "distance", categories: FilterViewModel.selectedCategory,term: searchTerm) { (success,businesses) in
            if success {
                self.createDataView(data: businesses!)

                self.reloadTableView?()
                self.hideLoading?()
            } else {
                self.hideLoading?()

                self.showError?()
            }
        }
    }
    
    
    //MARK: - FetchFilteredData

    func fetchFilteredBusinesses(lat : Double = 0.0, long: Double = 0.0) {
        let lat = self.userLocation.locationManager?.location?.coordinate.latitude ?? 0.0
        let long = self.userLocation.locationManager?.location?.coordinate.longitude ?? 0.0
        APIService.shared.fetchBusinesses(latitude: lat, longitude: long, radius: 40000, sortBy: "distance", categories: FilterViewModel.selectedCategory,term: searchTerm) { (success,businesses) in
            if success {
                self.createFilteredDataView(data: businesses!)

                self.reloadTableView?()
                self.hideLoading?()
            } else {
                self.hideLoading?()

                self.showError?()
            }
        }
    }
    
    func createDataView(data:[Business]) {
        var dataDetailVM = [DataViewModel]()
        for dataDetail in data {
            let detailVM = DataViewModel(id:dataDetail.id ?? "",name: dataDetail.name ?? "", city: dataDetail.location?.city ?? "", phone: dataDetail.phone ?? "", review: dataDetail.review_count ?? 0, imageUrl: dataDetail.image_url ?? "", price: dataDetail.price ?? "",lat:self.userLocation.locationManager?.location?.coordinate.latitude ?? 0.0,long: self.userLocation.locationManager?.location?.coordinate.longitude ?? 0.0 )
            dataDetailVM.append(detailVM)
        }
        dataViewModels = dataDetailVM
        
        
    }
    
    
    
    func getLocallySavedData(){
        let businessCoreDataViewModel = BussinessCoreDataViewModel()
        businessCoreDataViewModel.retriveData { (localData) in
            self.dataViewModels = localData
            self.reloadTableView?()
        }
    }
    
    
    func createFilteredDataView(data:[Business]) {
        var dataDetailVM = [DataViewModel]()
        for dataDetail in data {
            let detailVM = DataViewModel(id:dataDetail.id ?? "",name: dataDetail.name ?? "", city: dataDetail.location?.city ?? "", phone: dataDetail.phone ?? "", review: dataDetail.review_count ?? 0, imageUrl: dataDetail.image_url ?? "", price: dataDetail.price ?? "",lat:self.userLocation.locationManager?.location?.coordinate.latitude ?? 0.0,long: self.userLocation.locationManager?.location?.coordinate.longitude ?? 0.0)
            dataDetailVM.append(detailVM)
        }
        filtereddataViewModels = dataDetailVM
        
        
    }
    
    //MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        UserDefaults.standard.set(true, forKey: "FirstTime")
        

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.fetchBusinesses(lat: locValue.latitude, long: locValue.longitude)

       
    }
    
    
}
struct DataViewModel {
    let id : String
    let name: String
    let city: String
    let phone: String
    let review: Int
    let imageUrl: String
    let price : String
    let lat : Double
    let long : Double
}
