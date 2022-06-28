

import UIKit
import MapKit
import CoreLocation

class DetailViewController : UIViewController {

    var detailViewModel = BusinessViewModel()

    
    lazy var lblName: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Name"
        lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 7.0
        return lbl

    }()
    
    
    lazy var lblLocation: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Location"
        lbl.font = lbl.font.withSize(13)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 7.0
        return lbl

    }()
    
    lazy var lblPrice: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Price"
        lbl.font = lbl.font.withSize(13)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 7.0
        return lbl

    }()
    
    lazy var lblRating: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Rating"
        lbl.font = lbl.font.withSize(13)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 7.0
        return lbl

    }()
    
    lazy var lblPhone: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Phone"
        lbl.font = lbl.font.withSize(13)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 7.0
        return lbl

    }()
    
    
    lazy var imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView

    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView

    }()
    let newPin = MKPointAnnotation()

    var selectedDataDetailIndex : Int?

    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Restaurants Details"
        setUpUI()
        setData()

    }
    
    //MARK: - SetUp UI

    private func setUpUI() {
        self.view.addSubview(imgView)
        self.imgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.imgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        self.imgView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2).isActive = true
        self.imgView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        
        self.view.addSubview(lblName)
        self.lblName.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.lblName.topAnchor.constraint(equalTo: self.imgView.bottomAnchor, constant: 0.0).isActive = true
        self.lblName.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lblName.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        self.view.addSubview(lblPrice)
        self.lblPrice.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.lblPrice.topAnchor.constraint(equalTo: self.lblName.bottomAnchor, constant: 0.0).isActive = true
        self.lblPrice.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lblPrice.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2).isActive = true
        
        self.view.addSubview(lblRating)
        self.lblRating.leadingAnchor.constraint(equalTo: self.lblPrice.trailingAnchor, constant: 0.0).isActive = true
        self.lblRating.topAnchor.constraint(equalTo: self.lblName.bottomAnchor, constant: 0.0).isActive = true
        self.lblRating.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lblRating.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2).isActive = true
        
        
        self.view.addSubview(lblLocation)
        self.lblLocation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.lblLocation.topAnchor.constraint(equalTo: self.lblRating.bottomAnchor, constant: 0.0).isActive = true
        self.lblLocation.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lblLocation.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2).isActive = true
        
        self.view.addSubview(lblPhone)
        self.lblPhone.leadingAnchor.constraint(equalTo: self.lblLocation.trailingAnchor, constant: 0.0).isActive = true
        self.lblPhone.topAnchor.constraint(equalTo: self.lblRating.bottomAnchor, constant: 0.0).isActive = true
        self.lblPhone.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.lblPhone.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2).isActive = true
        
        self.view.addSubview(mapView)
        self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.mapView.topAnchor.constraint(equalTo: self.lblPhone.bottomAnchor, constant: 0.0).isActive = true
        self.mapView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.mapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
       
    }
   
    //MARK: - SetUp MapView

    private func setMapView(lat:Double, long: Double) {
       
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
      
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            //set region on the map
            mapView.setRegion(region, animated: true)
            newPin.coordinate = center
            mapView.addAnnotation(newPin)
    }
    
    
    //MARK: - Set Data

    private func setData() {
        let detailData = self.detailViewModel.getDataDetail(selectedData: self.selectedDataDetailIndex ?? 0)
        
        self.lblName.text = detailData.name
        if detailData.name.count == 0 {
            self.lblLocation.text = "N/A"
        } else {
            self.lblLocation.text = detailData.city

        }
        
        if detailData.phone.count == 0 {
            self.lblPhone.text = "N/A"
        } else {
            self.lblPhone.text = detailData.phone

        }
       
        self.lblRating.text = "\(detailData.review)"

        if detailData.price.count == 0 {
            self.lblPrice.text = "N/A"
        } else {
            self.lblPrice.text = detailData.price

        }
        
        self.imgView.dowloadFromServer(link: detailData.imageUrl )
        setMapView(lat: detailData.lat, long: detailData.long)
    }
   

}


//MARK: - Download image from server

extension UIImageView {
    func dowloadFromServer( link: String, contentMode mode: UIView.ContentMode = .scaleToFill) {
        var imageUrlStr = ""
        if link.count == 0 || link == "" {
            //If imageurl is not present then image will be set from below URL (also possible to save image locally as default image but wanted to check download image code will below URL.)
            imageUrlStr = "https://ramw.org/sites/default/files/styles/content/public/default_images/default-news.jpg?itok=jsMUP47r"
        } else {
            imageUrlStr = link
        }
        
        guard let url = URL(string: imageUrlStr) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
        
        }
}
