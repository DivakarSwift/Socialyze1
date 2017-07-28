//
//  Place.swift
//  Slide
//
//  Created by Rajendra Karki on 5/25/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import ObjectMapper


struct Place:Mappable {
    var nameAddress: String?
    var mainImage: String?
    var secondImage: String?
    var lat: Double?
    var long: Double?
    var size: Int? // custom = 0, small = 1, medium = 2, large = 3
    var early: Int? // early check-in, 0 for no, 1 for yes
    var bio: String? // locations description
    var nameBio:String? // Imp Description
    var placeId: String?
    var ads:[Ads]?
    
    var date:String?
    var time:String?
    var hall:String?
    
    var isEvent:Bool?
    var hasDeal: Bool?
    var event:Event?
    
    var deal: Deal?
    
    var id: Int?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.nameAddress <- map["nameAddress"]
        self.mainImage <- map["mainImage"]
        self.secondImage <- map["secondImage"]
        self.lat <- map["lat"]
        self.long <- map["long"]
        self.size <- map["size"]
        self.early <- map["early"]
        self.bio <- map["bio"]
        self.nameBio <- map["nameBio"]
        self.placeId <- map["placeId"]
        self.ads <- map["ads"]
        
        self.date <- map["date"]
        self.time <- map["time"]
        self.hall <- map["hall"]
        
        self.isEvent <- map["isEvent"]
        self.event <- map["Event"]
        
        self.deal <- map["deal"]
        self.hasDeal <- map["hasDeal"]
    }
}

struct Ads: Mappable {
    var title: String?
    var image: String?
    var link: String?
    var headerImage:String?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.title <- map["title"]
        self.image <- map["image"]
        self.link <- map["link"]
        self.headerImage <- map["headerImage"]
    }
}

struct Event: Mappable {
    var title: String?
    var image: String?
    var detail: String?
    var date:String?
    var time:String?
    var uid: String?
    var expiryDate: Date?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        
        let transform = DateFormatterTransform.init(dateFormatter: dateFormatter)
        
        self.title <- map["eventName"]
        self.image <- map["firstImage"]
        self.detail <- map["eventDetails"]
        self.date <- map["date"]
        self.time <- map["time"]
        self.uid <- map["uid"]
        self.expiryDate <- (map["expiryDate"], transform)
    }
}

/*
func setupPlaces() {
 
 // How to image link from firebas storage:
    1. click the desired image
    2. then the image will appear in right side of screen.
    3. right click image and click open in new tab
    4. copy the url in new tab
    5. paste that url in mainImage value.

     Ohio State University

    places.append(Place.init(nameAddress: "RPAC", mainImage: #imageLiteral(resourceName: "RPAC"), secondImage: nil, lat: 39.999643, long: -83.018489, size: 3, early: 0, bio: "Best place to find a workout buddy.",placeID: "ChIJB-ZAQ5SOOIgRM79SReqgWlI"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FRPAC.jpg?alt=media&token=6075e952-63e0-4cca-8043-ac8508b29ce7

    places.append(Place.init(nameAddress: "Ohio Union", mainImage: #imageLiteral(resourceName: "Union"), secondImage: nil, lat: 39.997957, long: -83.0085650, size: 3, early: 0, bio: "Connect with friends and student orgs over food and study.",placeID: "ChIJQXKDxbiOOIgRI9TvX8VM4ik"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FUnion.jpg?alt=media&token=8b67783b-8a4e-4a4f-914b-b9a328f4f18a

    places.append(Place.init(nameAddress: "18th Ave Library, Ohio State", mainImage: #imageLiteral(resourceName: "18thAvelibrary"), secondImage: nil, lat: 0, long: 0, size: 2, early: 0, bio: ""))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2F18thAvelibrary.jpg?alt=media&token=1a08241e-18f6-4f8b-9756-964f3bf29349
 

    places.append(Place.init(nameAddress: "Thompson Library", mainImage: #imageLiteral(resourceName: "ThompsonLibrary1"), secondImage: nil, lat: 39.999346, long: -83.014863, size: 2, early: 0, bio: "The go-to place for group studying.", placeID: "ChIJP74-z5eOOIgRBVNFuzx7O7U"))
 https://console.firebase.google.com/project/socialyze-72c6a/storage/socialyze-72c6a.appspot.com/files/PlacesImages/

     Other Universities

    places.append(Place.init(nameAddress: "Columbus State", mainImage: #imageLiteral(resourceName: "ColumbusStateCC"), secondImage: nil, lat:39.969207, long: -82.987190, size: 0, early: 0, bio: "Connect with friends and students downtown.",placeID: "ChIJh6KJCdSIOIgRr6tbp10S-tQ"))polygon
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FColumbusStateCC.jpg?alt=media&token=de51877e-d97d-4033-953c-31d33338a6de
 

    places.append(Place.init(nameAddress: "Capital University", mainImage: #imageLiteral(resourceName: "CapitalUni"), secondImage: nil, lat: 39.955322, long: -82.938515, size: 0, early: 0, bio: "", placeID: defaultPlaceID)) // polygon
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FCapitalUni.jpg?alt=media&token=0f665520-1943-4d1a-b38b-de26721015b4
 
 

     Towns and Large Areas

    places.append(Place.init(nameAddress: "Downtown Columbus", mainImage: #imageLiteral(resourceName: "DowntownColumbus "), secondImage: nil, lat: 0, long: 0, size: 2, early: 0, bio: "", placeID: defaultPlaceID)) // polygon

 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FDowntownColumbus%20.jpg?alt=media&token=37f462d3-c4cb-419f-b330-2eb1015c387b
 
 
    places.append(Place.init(nameAddress: "Short North", mainImage: #imageLiteral(resourceName: "ShortNorth"), secondImage: nil, lat: 39.987237, long: -83.008599, size: 0, early: 0, bio: "Centered on the main strip of High Street, it is the Art and Soul of Columbus.",placeID: ""))  polygon
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FShortNorth.jpg?alt=media&token=e08ad888-3828-49cf-8f26-78c965b39158
 

    places.append(Place.init(nameAddress: "German Village", mainImage: #imageLiteral(resourceName: "germanvillage"), secondImage: nil, lat: 39.952666, long: -82.997876, size: 0, early: 0, bio: "", placeID: defaultPlaceID)) // polygon
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2Fgermanvillage.jpg?alt=media&token=5eba5bb3-a72b-447a-800e-897394e9916e
 
 

     Centers and Arenas

    places.append(Place.init(nameAddress: "Ohio Expo Center", mainImage: #imageLiteral(resourceName: "ohioexpocenter"), secondImage: nil, lat: 40.002574, long: -82.990648 ,size: 4, early: 0, bio: "", placeID: defaultPlaceID))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2Fohioexpocenter.jpg?alt=media&token=e6f9d92e-dda4-4dce-b469-495a78b94a4e
 

    places.append(Place.init(nameAddress: "Huntington Park", mainImage: #imageLiteral(resourceName: "HuntingtonPark.jpg"), secondImage: nil, lat: 39.968675, long: -83.010920, size: 4, early: 0, bio: "A large and beautiful park that serves as home to the Columbus Clippers!", placeID: "ChIJ63GhnCOPOIgR8rcdYWnemkw"))

    places.append(Place.init(nameAddress: "Mapfre stadium", mainImage: #imageLiteral(resourceName: "mapfre-stadium"), secondImage: nil, lat: 40.009521, long: -82.991087, size: 4, early: 0, bio: "The place to cheer on the Columbus Crew!", placeID: "ChIJk4BJbVOJOIgRn_sPxoazXCs"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2Fmapfre-stadium.jpg?alt=media&token=c3c81ac5-30e0-49d4-98cf-a72618ce3bb4
 

    places.append(Place.init(nameAddress: "Nationwide Arena", mainImage: #imageLiteral(resourceName: "NationWideArena1"), secondImage: #imageLiteral(resourceName: "Nationwide"), lat: 39.969274, long: -83.005992, size: 4, early: 1, bio: "The heart of the Arena District and the venue of the Blue Jackets and great shows and concerts!", placeID: "ChIJ6_-8ziWPOIgRSQzt9UEhOmI"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FNationWideArena1.jpg?alt=media&token=70b89807-28a4-46ff-92a0-f3e452ab20eb
 

    places.append(Place.init(nameAddress: "Columbus Convention Center", mainImage: #imageLiteral(resourceName: "GreaterConventionCenter"), secondImage: nil, lat: 39.970323, long: -83.000803, size: 4, early: 0, bio: "", placeID: defaultPlaceID))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FGreaterConventionCenter.jpg?alt=media&token=ef3fbe61-6ad1-4f77-b6e9-60b50b3455b2
 

    places.append(Place.init(nameAddress: "Newport Music Hall", mainImage: #imageLiteral(resourceName: "NewportMusicHall-yelp"), secondImage: nil, lat: 39.997719, long: -83.007267, size: 1, early: 1, bio: "A historic ballroom that hosts major acts.", placeID: "ChIJnRvS7biOOIgR8WzprZwSklE"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FNewportMusicHall-yelp.jpg?alt=media&token=c3eca17d-c6ff-47be-9984-f1bb7b495940
 

    places.append(Place.init(nameAddress: "Express Live!", mainImage: #imageLiteral(resourceName: "ExpressLive!"), secondImage: nil, lat: 39.969865, long: -83.009947, size: 2, early: 1, bio: "A fantastic indoor and outdoor music venue!", placeID: "ChIJCcOQ6COPOIgRcLEuZixc9Wk"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FExpressLive!.jpg?alt=media&token=4084fdb2-9571-44f0-bbb0-f19d88c66b57
 

    places.append(Place.init(nameAddress: "Schottenstein Music Center", mainImage: #imageLiteral(resourceName: "SchottTomPetty2"), secondImage: nil, lat: 40.007549, long: -83.025020, size: 4, early: 1, bio: "Connect with people going to Tom Petty on June 4th!", placeID: "ChIJMQsDsZqOOIgReHL17_Uf2Hg"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FSchottTomPetty2.png?alt=media&token=dc8a867b-9850-4c22-a43f-3c63535e628c

     Bars & Clubs

    places.append(Place.init(nameAddress: "Ugly Tuna Saloona", mainImage: #imageLiteral(resourceName: "UglyTuna "), secondImage: nil, lat: 39.993811, long: -83.006448, size: 2, early: 0, bio: "There's no better time than sharing a Fishbowl with some friends.", placeID: "ChIJOdSeCMeOOIgRmMsYhusrEwM"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FUglyTuna%20.jpg?alt=media&token=0ea5066b-a02a-4a20-82d5-6bf219b8fccc
 

    places.append(Place.init(nameAddress: "Short North Pint House", mainImage: #imageLiteral(resourceName: "Pinthouse"), secondImage: nil, lat: 39.978301, long: -83.003153, size: 2, early: 0, bio: "American pub grub with a large selection of brews to drink on their patio.", placeID: "ChIJV1GKfNeOOIgR4-ZZbcipC8g"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FPinthouse.jpg?alt=media&token=a5c4d4ec-4ab3-40be-bf64-212c44c4f14e
 

    places.append(Place.init(nameAddress: "Axis Nightclub", mainImage: #imageLiteral(resourceName: "Axisnightclub"), secondImage: nil, lat: 39.978057, long: -83.004419, size: 2, early: 0, bio: "A gay-friendly club full of entertainment.", placeID: "ChIJG87B09mOOIgRQ55xUsoqKCs"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FAxisnightclub.jpg?alt=media&token=49607113-a0db-4974-8024-4bb611bf2ed1
 

    places.append(Place.init(nameAddress: "World of Beer", mainImage: #imageLiteral(resourceName: "WorldofBeer3"), secondImage: #imageLiteral(resourceName: "WorldofBeer1"), lat: 0, long: 0, size: 1, early: 0, bio: "", placeID: defaultPlaceID))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FWorldofBeer3.jpg?alt=media&token=c1ad41a3-e6e1-4024-9651-b0547379ae76
 

    places.append(Place.init(nameAddress: "Park Street Cantina", mainImage: #imageLiteral(resourceName: "ParkStreetCantina1"), secondImage: nil, lat: 39.972233, long: -83.005100, size: 2, early: 0, bio: "Tacos, tequila, and friends make for a good time.", placeID: "ChIJRaaWyyePOIgRt2G7Nk7HDAs"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FParkStreetCantina1.jpg?alt=media&token=137dea0e-b242-4bf2-b7c0-167a0d6b26b4
 

    places.append(Place.init(nameAddress: "Char Bar", mainImage: #imageLiteral(resourceName: "Charbar"), secondImage: nil, lat: 39.971304, long: -83.002569, size: 2, early: 0, bio: "", placeID: defaultPlaceID))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FCharbar.jpg?alt=media&token=d8dd9619-413c-4a7a-a059-df78cbd49fdf

    places.append(Place.init(nameAddress: "Out R Inn", mainImage: #imageLiteral(resourceName: "OutRInn"), secondImage: nil, lat: 40.005088, long: -83.008432, size: 2, early: 0, bio: "The oldest campus bar is the place to play billiards with some friends.", placeID: "ChIJRX1tQ7uOOIgRO9wNKF-naaE"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FOutRInn.jpg?alt=media&token=4f5c9583-3745-475b-a013-4e624fc9468e
 

    places.append(Place.init(nameAddress: "Midway on High", mainImage: #imageLiteral(resourceName: "Midwayonhigh"), secondImage: nil, lat: 39.997669, long: -83.007395, size: 2, early: 0, bio: "Proudly the loudest club on High Street and the best place to dance together.", placeID: "ChIJ73Ok77iOOIgR_EQyWdpUgxE"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FMidwayonhigh.jpg?alt=media&token=decdbaec-e8f5-4836-9026-4c245d50ff9d

    places.append(Place.init(nameAddress: "Bakersfield Short North", mainImage: #imageLiteral(resourceName: "BakersfieldShortNorth"), secondImage: nil, lat: 39.977321, long: -83.003828, size: 1, early: 0, bio: "Quirky food choices and a long list of beers and cocktails.", placeID: "ChIJu1T6hteOOIgRHLqMIL76xGI"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FBakersfieldShortNorth.jpg?alt=media&token=65d60a17-73db-4f29-80b6-2defd9b39297

    places.append(Place.init(nameAddress: "Chumley's", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: <#T##Double#>, long: <#T##Double#>, size: <#T##Int#>, early: <#T##Int#>, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "Ethyl & Tank", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.997661, long: -83.006919, size: 1, early: 0, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "The Big Bar & Grill", mainImage: #imageLiteral(resourceName: "BigBar"), secondImage: nil, lat: 39.997343, long: -83.007020, size: 2, early: 0, bio: "Campus watering hole with a dancefloor, giant TVs, and rooftop patio.", placeID: "ChIJfZ9D7LiOOIgR3yngaYcmMms"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FBigBar.jpg?alt=media&token=a96ecc13-acf5-48ee-8573-3f949cd64919
 

    places.append(Place.init(nameAddress: "The O Patio & Pub", mainImage: #imageLiteral(resourceName: "Opatio&pub"), secondImage: nil, lat: 40.000295, long: -83.007737, size: 2, early: 0, bio: "Let's go to the O and sit around the firepit.", placeID: "ChIJJ8q0brmOOIgRR_SqfUOKtbM"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FOpatio%26pub.jpg?alt=media&token=884e2b44-4334-428c-8f97-80bbc0c80fbd
 

    places.append(Place.init(nameAddress: "The Library", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006640, long: -83.009561, size: 1, early: 0, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "Little Bar", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006840, long: -83.009729, size: 2, early: 0, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "Cazuelas Grill", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.009699, long: -83.010323, size: 2, early: 0, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "Bullwinkles", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.998463, long: -83.007246, size: 2, early: 0, bio: "", placeID: defaultPlaceID))

    places.append(Place.init(nameAddress: "Fourth Street Bar & Grill", mainImage: #imageLiteral(resourceName: "4thStreetBarandGrill"), secondImage: nil, lat: 40.000335, long: -82.998396, size: 1, early: 0, bio: "Campus pub with craft beers, burgers, and wings.", placeID: "ChIJjwIdAbSOOIgRJrWV2TNIOQE"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2F4thStreetBarandGrill.jpg?alt=media&token=52ca052c-11fe-41fe-9c33-28990a8eabb3

    places.append(Place.init(nameAddress: "Condado Tacos", mainImage: #imageLiteral(resourceName: "Condado"), secondImage: nil, lat: 39.987486, long: -83.005805, size: 2, early: 0, bio: "Arrive with the intention of building the world's best taco.", placeID: "ChIJhyaTGsWOOIgR-sVg4_VyO2w"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FCondado.jpeg?alt=media&token=33071044-8147-4e29-a8b1-17daafb315e2
 

    places.append(Place.init(nameAddress: "Lucky's Stout House", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.992392, long: -83.006889, size: 1, early: 0, bio: "", placeID: defaultPlaceID))

     Coffee Shops

    places.append(Place.init(nameAddress: "Fox in the Snow Cafe", mainImage: #imageLiteral(resourceName: "FoxintheSnow"), secondImage: nil, lat: 39.984228, long: -82.999388, size: 2, early: 0, bio: "A chic cafe featuring java drinks and baked goods.", placeID: "ChIJxfUn7NGOOIgRwf1Z3TIzy64"))
 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FFoxintheSnow.jpg?alt=media&token=89037452-875d-4eea-9b39-80ac01f1662e
 

     Shopping Malls

    places.append(Place.init(nameAddress: "Polaris Fashion Place", mainImage: #imageLiteral(resourceName: "PolarisFashionPlace"), secondImage: #imageLiteral(resourceName: "PolarisFashionPlace1-yelp"), lat: 40.145472, long: -82.981640, size: 0, early: 0, placeID: defaultPlaceID))

 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FPolarisFashionPlace.jpg?alt=media&token=4f541898-b9f2-4ff2-92e0-143379899142
 
 
    places.append(Place.init(nameAddress: "Easton Town Center", mainImage: #imageLiteral(resourceName: "EastonTownCenter"), secondImage: nil, lat: 40.050716, long: -82.915363, size: 0, early: 0, bio: "A beautiful gathering of every eatery, restaurant, and shop Columbus has to offer.", placeID: "ChIJG9vehYeKOIgRkLBPTqjudW4"))  polygon

 https://firebasestorage.googleapis.com/v0/b/socialyze-72c6a.appspot.com/o/PlacesImages%2FEastonTownCenter.jpg?alt=media&token=6996e687-3300-49a0-b6b4-2d8df673c429
 
    Authenticator.shared.places = self.places

    self.collectionView.reloadData()

}
 */
