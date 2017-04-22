//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import GooglePlaces
import FloatRatingView
struct Place {
    let nameAddress: String
    let mainImage: UIImage
    let secondImage: UIImage?
    let lat: Double
    let long: Double
    let placeID: String
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func switchToCategoryFromButton(_ sender: Any) {
        let categoryDefaults = UserDefaults.standard
        switch (sender as AnyObject).tag {
        case 0:
            categoryDefaults.set("Coffee", forKey: "Category")
            break
        case 1:
            categoryDefaults.set("Dining", forKey: "Category")
            break
        case 2:
            categoryDefaults.set("Nightlife", forKey: "Category")
            break
        case 3:
            categoryDefaults.set("Party", forKey: "Category")
            break
        case 4:
            categoryDefaults.set("Fitness", forKey: "Category")
            break
        case 5:
            categoryDefaults.set("Gaming", forKey: "Category")
            break
        case 6:
            categoryDefaults.set("Study Group", forKey: "Category")
            break
        case 7:
            categoryDefaults.set("Causes", forKey: "Category")
            break
        case 8:
            categoryDefaults.set("Chill", forKey: "Category")
            break
        case 9:
            categoryDefaults.set("Others", forKey: "Category")
            break
        default:
            break
        }
        
        print("button press \(categoryDefaults.value(forKey: "Category") as! String)")
        
        performSegue(withIdentifier: "categoryDetail", sender: self)
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
       
        let mosaicLayout = TRMosaicLayout()
        self.collectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        self.collectionView.reloadData()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Profile",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
            
            
        )
       
        
        setupPlaces()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Explore Columbus"
    }
    
    var places = [Place]()
    
    func setupPlaces() {
        places.append(Place.init(nameAddress: "RPAC, Ohio State", mainImage: #imageLiteral(resourceName: "RPAC1-yelp"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJB-ZAQ5SOOIgRM79SReqgWlI"))
        
        places.append(Place.init(nameAddress: "The Union, Ohio State", mainImage: #imageLiteral(resourceName: "Union"), secondImage: nil, lat: 39.997957, long: -83.0085650,placeID: "ChIJB3St4biOOIgRlGJv79oKtW4"))
        places.append(Place.init(nameAddress: "18th Ave Library, Ohio State", mainImage: #imageLiteral(resourceName: "18thAvelibrary"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJDRJ-3r2OOIgR-Wmwn25uGc4"))
        
        places.append(Place.init(nameAddress: "Thompson Library, Ohio State", mainImage: #imageLiteral(resourceName: "ThompsonLibrary"), secondImage: #imageLiteral(resourceName: "ThompsonLibrary1"), lat: 39.999472, long: -83.014833,placeID: "ChIJP74-z5eOOIgRBVNFuzx7O7U"))
        
        places.append(Place.init(nameAddress: "Capital University", mainImage: #imageLiteral(resourceName: "CapitalUni"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJY8M8bEOIOIgRZYLL8jWPXNw"))
        
        places.append(Place.init(nameAddress: "Columbus State CC.", mainImage: #imageLiteral(resourceName: "ColumbusStateCC"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJh6KJCdSIOIgRr6tbp10S-tQ"))
        places.append(Place.init(nameAddress: "Ohio Expo Center", mainImage: #imageLiteral(resourceName: "ohioexpocenter"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJQUwvF0yJOIgRevS5vYDi7bc"))
        places.append(Place.init(nameAddress: "Columbus Convention Center", mainImage: #imageLiteral(resourceName: "GreaterConventionCenter"), secondImage: nil, lat: 39.970323, long: -83.000803,placeID: "ChIJcyJmACmPOIgR7nFss0s9IZo"))
        places.append(Place.init(nameAddress: "Schottenstein Center", mainImage: #imageLiteral(resourceName: "SchottCenter"), secondImage: nil, lat: 39.999009, long: -83.007331,placeID: "ChIJA1F8r5qOOIgRgs1lAQypqmA"))
        places.append(Place.init(nameAddress: "Express Live", mainImage: #imageLiteral(resourceName: "ExpressLive!"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJCcOQ6COPOIgRcLEuZixc9Wk"))
        places.append(Place.init(nameAddress: "Ugly Tuna", mainImage: #imageLiteral(resourceName: "UglyTuna "), secondImage: nil, lat: 0, long: 0,placeID: "ChIJOdSeCMeOOIgRmMsYhusrEwM"))
        places.append(Place.init(nameAddress: "Short North Pint House", mainImage: #imageLiteral(resourceName: "Pinthouse"), secondImage: nil, lat: 39.978351, long: -83.003153,placeID: "ChIJV1GKfNeOOIgR4-ZZbcipC8g"))
        places.append(Place.init(nameAddress: "Axis Nightclub", mainImage: #imageLiteral(resourceName: "Axisnightclub"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJG87B09mOOIgRQ55xUsoqKCs"))
        places.append(Place.init(nameAddress: "World of Beer", mainImage: #imageLiteral(resourceName: "WorldofBeer3"), secondImage: #imageLiteral(resourceName: "WorldofBeer1"), lat: 0, long: 0,placeID: "ChIJMx8lCceOOIgRhauV8WVch3M"))
        places.append(Place.init(nameAddress: "Park street Cantina", mainImage: #imageLiteral(resourceName: "ParkStreetCantina"), secondImage: #imageLiteral(resourceName: "ParkStreetCantina1"), lat: 0, long: 0,placeID: "ChIJRaaWyyePOIgRt2G7Nk7HDAs"))
        places.append(Place.init(nameAddress: "Char bar", mainImage: #imageLiteral(resourceName: "Charbar"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJXVLuvyiPOIgRaKnaqKcSzCQ"))
        places.append(Place.init(nameAddress: "Mapfre stadium", mainImage: #imageLiteral(resourceName: "mapfre-stadium"), secondImage: nil, lat: 40.009521, long: -82.991087,placeID: "ChIJk4BJbVOJOIgRn_sPxoazXCs"))
        places.append(Place.init(nameAddress: "Nationwide Arena", mainImage: #imageLiteral(resourceName: "NationwideArena"), secondImage: #imageLiteral(resourceName: "NationWideArena1"), lat: 39.969274, long: -83.005992,placeID: "ChIJ6_-8ziWPOIgRSQzt9UEhOmI"))
        
        places.append(Place.init(nameAddress: "Out R Inn", mainImage: #imageLiteral(resourceName: "OutRInn"), secondImage: nil, lat: 40.005088, long: -83.008432,placeID: "ChIJRX1tQ7uOOIgRO9wNKF-naaE"))
        
        places.append(Place.init(nameAddress: "Midway Bar and Grill", mainImage: #imageLiteral(resourceName: "MidwayonHigh-Yelp"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJ73Ok77iOOIgR_EQyWdpUgxE"))
        
        places.append(Place.init(nameAddress: "Newport Music & Big Bar", mainImage: #imageLiteral(resourceName: "NewportMusicHall-yelp"), secondImage: nil, lat: 39.997719, long: -83.007267,placeID: "ChIJnRvS7biOOIgR8WzprZwSklE"))
        places.append(Place.init(nameAddress: "Polaris Fashion Mall", mainImage: #imageLiteral(resourceName: "PolarisFashionPlace"), secondImage: #imageLiteral(resourceName: "PolarisFashionPlace1-yelp"), lat: 0, long: 0,placeID: "ChIJv15SJGX0OIgRso-ZcKg17K0"))
        places.append(Place.init(nameAddress: "Easton Town Center", mainImage: #imageLiteral(resourceName: "EastonTownCenter"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJG9vehYeKOIgRkLBPTqjudW4"))
        places.append(Place.init(nameAddress: "Downtown, Columbus", mainImage: #imageLiteral(resourceName: "DowntownColumbus "), secondImage: nil, lat: 0, long: 0,placeID: "ChIJ5baLxS-POIgR8ijJ-dGNvts"))
        
        places.append(Place.init(nameAddress: "Short North", mainImage: #imageLiteral(resourceName: "ShortNorth"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJddhE1tmOOIgR1ULAuDDb34w"))
        
        places.append(Place.init(nameAddress: "German Village", mainImage: #imageLiteral(resourceName: "germanvillage"), secondImage: nil, lat: 0, long: 0,placeID: "ChIJSZTZKbOIOIgRi4gi7mnhLtM"))
        
        places.append(Place.init(nameAddress: "Fox in the Snow Cafe", mainImage: #imageLiteral(resourceName: "FoxandSnowCafe"), secondImage: nil, lat: 39.984228, long: -82.999388,placeID: "ChIJxfUn7NGOOIgRwf1Z3TIzy64"))
               
    }
    
    func eventBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as UIViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func profileBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.userId = Authenticator.currentFIRUser?.uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
        vc.place = place
        self.navigationController?.pushViewController(vc, animated: true)
       // self.performSegue(withIdentifier: "categoryDetail", sender: self)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        (cell.viewWithTag(1) as! UIImageView).image = places[indexPath.row].mainImage
        (cell.viewWithTag(2) as! UILabel).text = places[indexPath.row].nameAddress
        let floatRatingView: FloatRatingView!
        floatRatingView = cell.viewWithTag(3) as! FloatRatingView
        floatRatingView.rating = 0
        floatRatingView.floatRatings = true
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if screenHeight == 568{
            cell.widthLayout.constant = 70
        }else{
          cell.widthLayout.constant = 100
            
        }
        (cell.viewWithTag(4) as! UILabel).text = "0.0"
         if(UserDefaults.standard.object(forKey: places[indexPath.row].placeID) != nil){
             let starData = UserDefaults.standard.object(forKey: places[indexPath.row].placeID) as! NSDictionary
            print(starData)
            floatRatingView.rating = Float(starData["rating"] as! String)!
             (cell.viewWithTag(4) as! UILabel).text = starData["rating"] as? String

         }else{
            if places[indexPath.row].placeID != "" {
                self.placeId( nmbr: indexPath.row)
            }
            
        }
        if(indexPath.item % 6 == 0){
            (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 14)
             (cell.viewWithTag(4) as! UILabel).font = UIFont.systemFont(ofSize: 11)
        }else{
              (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 11)
             (cell.viewWithTag(4) as! UILabel).font = UIFont.systemFont(ofSize: 11)
        }
        return cell
    }
}

extension ViewController : TRMosaicLayoutDelegate {
    
 
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
       // return UIEdgeInsets(top: 2, left: 3, bottom: 3, right: 3)
        return UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 180
    }
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        
        // I recommend setting every third cell as .Big to get the best layout
        return indexPath.item % 6 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func placeId( nmbr:Int)  {
        let placeID = places[nmbr].placeID
          let placesClinet = GMSPlacesClient()
        placesClinet.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place placeID \(place.placeID)")
            print("Place attributions \(place.rating)")
            let Str = String(place.rating)
             var userDefaultDict = [String: String]()
            userDefaultDict["rating"] = Str
            userDefaultDict["placeID"] = place.placeID
            userDefaultDict["address"] = place.formattedAddress
            UserDefaults.standard.set(userDefaultDict, forKey:place.placeID )
            UserDefaults.standard.synchronize()
            self.collectionView.reloadData()
        })
    }
}
