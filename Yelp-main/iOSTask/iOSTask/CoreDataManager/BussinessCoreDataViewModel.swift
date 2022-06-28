
import Foundation
import CoreData

class BussinessCoreDataViewModel {
    
    let context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveLocally(detailVM:DataViewModel ) {
        
        checkDataForDelete()
        let savedRestaurant = NSEntityDescription.insertNewObject(forEntityName: "BusinessCD", into: context)
        savedRestaurant.setValue(detailVM.id, forKey: "id")
        savedRestaurant.setValue(detailVM.name, forKey: "name")
        savedRestaurant.setValue(detailVM.price, forKey: "price")
        savedRestaurant.setValue(detailVM.imageUrl, forKey: "imageUrl")
        savedRestaurant.setValue(detailVM.review, forKey: "rating")
        savedRestaurant.setValue(detailVM.city, forKey: "city")
        savedRestaurant.setValue(detailVM.phone, forKey: "phone")
        savedRestaurant.setValue(detailVM.review, forKey: "review")

        savedRestaurant.setValue(detailVM.lat, forKey: "lat")
        savedRestaurant.setValue(detailVM.long, forKey: "long")
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    private func checkDataForDelete(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BusinessCD")
        do {
            let results   = try context.fetch(fetchRequest)
            let businesses = results as! [BusinessCD]
            if businesses.count > 4 {
                if let lastObj = businesses.first {
                    context.delete((lastObj) as NSManagedObject)
                    try context.save()

                }
            }

            
        } catch let error as NSError {
            print("Could not fetch \(error)")
          }
    }
    
    
    
    func retriveData(completion: @escaping ([DataViewModel]) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BusinessCD")
        do {
            let results   = try context.fetch(fetchRequest)
            let businesses = results as! [BusinessCD]
            var businessObjArray = [DataViewModel]()
            for busines in businesses {
                let busniessObj = DataViewModel(id: busines.id ?? "", name: busines.name ?? "", city: busines.city ?? "", phone: busines.phone ?? "" , review: Int(busines.review), imageUrl: busines.imageUrl ?? "", price: busines.price ?? "", lat: busines.lat , long: busines.long)

                businessObjArray.append(busniessObj)
                
            }
            
            completion(businessObjArray)
             

        } catch let error as NSError {
          print("Could not fetch \(error)")
        }
    }
}
