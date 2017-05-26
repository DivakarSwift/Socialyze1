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
    var placeId: String?
    
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
        self.placeId <- map["placeId"]
    }
}

//func setupPlaces() {
//
//    // Ohio State University
//
//    places.append(Place.init(nameAddress: "RPAC", mainImage: #imageLiteral(resourceName: "RPAC"), secondImage: nil, lat: 39.999643, long: -83.018489, size: 3, early: 0, bio: "Best place to find a workout buddy.",placeID: "ChIJB-ZAQ5SOOIgRM79SReqgWlI"))
//
//    places.append(Place.init(nameAddress: "Ohio Union", mainImage: #imageLiteral(resourceName: "Union"), secondImage: nil, lat: 39.997957, long: -83.0085650, size: 3, early: 0, bio: "Connect with friends and student orgs over food and study.",placeID: "ChIJQXKDxbiOOIgRI9TvX8VM4ik"))
//
//    //places.append(Place.init(nameAddress: "18th Ave Library, Ohio State", mainImage: #imageLiteral(resourceName: "18thAvelibrary"), secondImage: nil, lat: 0, long: 0, size: 2, early: 0, bio: ""))
//
//    places.append(Place.init(nameAddress: "Thompson Library", mainImage: #imageLiteral(resourceName: "ThompsonLibrary1"), secondImage: nil, lat: 39.999346, long: -83.014863, size: 2, early: 0, bio: "The go-to place for group studying.", placeID: "ChIJP74-z5eOOIgRBVNFuzx7O7U"))
//
//    // Other Universities
//
//    places.append(Place.init(nameAddress: "Columbus State", mainImage: #imageLiteral(resourceName: "ColumbusStateCC"), secondImage: nil, lat:39.969207, long: -82.987190, size: 0, early: 0, bio: "Connect with friends and students downtown.",placeID: "ChIJh6KJCdSIOIgRr6tbp10S-tQ"))//polygon
//
//    //places.append(Place.init(nameAddress: "Capital University", mainImage: #imageLiteral(resourceName: "CapitalUni"), secondImage: nil, lat: 39.955322, long: -82.938515, size: 0, early: 0, bio: "", placeID: defaultPlaceID)) // polygon
//
//    // Towns and Large Areas
//
//    //places.append(Place.init(nameAddress: "Downtown Columbus", mainImage: #imageLiteral(resourceName: "DowntownColumbus "), secondImage: nil, lat: 0, long: 0, size: 2, early: 0, bio: "", placeID: defaultPlaceID)) // polygon
//
//    places.append(Place.init(nameAddress: "Short North", mainImage: #imageLiteral(resourceName: "ShortNorth"), secondImage: nil, lat: 39.987237, long: -83.008599, size: 0, early: 0, bio: "Centered on the main strip of High Street, it is the Art and Soul of Columbus.",placeID: "")) // polygon
//
//    //places.append(Place.init(nameAddress: "German Village", mainImage: #imageLiteral(resourceName: "germanvillage"), secondImage: nil, lat: 39.952666, long: -82.997876, size: 0, early: 0, bio: "", placeID: defaultPlaceID)) // polygon
//
//    // Centers and Arenas
//
//    //places.append(Place.init(nameAddress: "Ohio Expo Center", mainImage: #imageLiteral(resourceName: "ohioexpocenter"), secondImage: nil, lat: 40.002574, long: -82.990648 ,size: 4, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Huntington Park", mainImage: #imageLiteral(resourceName: "HuntingtonPark.jpg"), secondImage: nil, lat: 39.968675, long: -83.010920, size: 4, early: 0, bio: "A large and beautiful park that serves as home to the Columbus Clippers!", placeID: "ChIJ63GhnCOPOIgR8rcdYWnemkw"))
//
//    places.append(Place.init(nameAddress: "Mapfre stadium", mainImage: #imageLiteral(resourceName: "mapfre-stadium"), secondImage: nil, lat: 40.009521, long: -82.991087, size: 4, early: 0, bio: "The place to cheer on the Columbus Crew!", placeID: "ChIJk4BJbVOJOIgRn_sPxoazXCs"))
//
//    places.append(Place.init(nameAddress: "Nationwide Arena", mainImage: #imageLiteral(resourceName: "NationWideArena1"), secondImage: #imageLiteral(resourceName: "Nationwide"), lat: 39.969274, long: -83.005992, size: 4, early: 1, bio: "The heart of the Arena District and the venue of the Blue Jackets and great shows and concerts!", placeID: "ChIJ6_-8ziWPOIgRSQzt9UEhOmI"))
//
//    //places.append(Place.init(nameAddress: "Columbus Convention Center", mainImage: #imageLiteral(resourceName: "GreaterConventionCenter"), secondImage: nil, lat: 39.970323, long: -83.000803, size: 4, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Newport Music Hall", mainImage: #imageLiteral(resourceName: "NewportMusicHall-yelp"), secondImage: nil, lat: 39.997719, long: -83.007267, size: 1, early: 1, bio: "A historic ballroom that hosts major acts.", placeID: "ChIJnRvS7biOOIgR8WzprZwSklE"))
//
//    places.append(Place.init(nameAddress: "Express Live!", mainImage: #imageLiteral(resourceName: "ExpressLive!"), secondImage: nil, lat: 39.969865, long: -83.009947, size: 2, early: 1, bio: "A fantastic indoor and outdoor music venue!", placeID: "ChIJCcOQ6COPOIgRcLEuZixc9Wk"))
//
//    places.append(Place.init(nameAddress: "Schottenstein Music Center", mainImage: #imageLiteral(resourceName: "SchottTomPetty2"), secondImage: nil, lat: 40.007549, long: -83.025020, size: 4, early: 1, bio: "Connect with people going to Tom Petty on June 4th!", placeID: "ChIJMQsDsZqOOIgReHL17_Uf2Hg"))
//
//    // Bars & Clubs
//
//    places.append(Place.init(nameAddress: "Ugly Tuna Saloona", mainImage: #imageLiteral(resourceName: "UglyTuna "), secondImage: nil, lat: 39.993811, long: -83.006448, size: 2, early: 0, bio: "There's no better time than sharing a Fishbowl with some friends.", placeID: "ChIJOdSeCMeOOIgRmMsYhusrEwM"))
//
//    places.append(Place.init(nameAddress: "Short North Pint House", mainImage: #imageLiteral(resourceName: "Pinthouse"), secondImage: nil, lat: 39.978301, long: -83.003153, size: 2, early: 0, bio: "American pub grub with a large selection of brews to drink on their patio.", placeID: "ChIJV1GKfNeOOIgR4-ZZbcipC8g"))
//
//    places.append(Place.init(nameAddress: "Axis Nightclub", mainImage: #imageLiteral(resourceName: "Axisnightclub"), secondImage: nil, lat: 39.978057, long: -83.004419, size: 2, early: 0, bio: "A gay-friendly club full of entertainment.", placeID: "ChIJG87B09mOOIgRQ55xUsoqKCs"))
//
//    //places.append(Place.init(nameAddress: "World of Beer", mainImage: #imageLiteral(resourceName: "WorldofBeer3"), secondImage: #imageLiteral(resourceName: "WorldofBeer1"), lat: 0, long: 0, size: 1, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Park Street Cantina", mainImage: #imageLiteral(resourceName: "ParkStreetCantina1"), secondImage: nil, lat: 39.972233, long: -83.005100, size: 2, early: 0, bio: "Tacos, tequila, and friends make for a good time.", placeID: "ChIJRaaWyyePOIgRt2G7Nk7HDAs"))
//
//    //places.append(Place.init(nameAddress: "Char Bar", mainImage: #imageLiteral(resourceName: "Charbar"), secondImage: nil, lat: 39.971304, long: -83.002569, size: 2, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Out R Inn", mainImage: #imageLiteral(resourceName: "OutRInn"), secondImage: nil, lat: 40.005088, long: -83.008432, size: 2, early: 0, bio: "The oldest campus bar is the place to play billiards with some friends.", placeID: "ChIJRX1tQ7uOOIgRO9wNKF-naaE"))
//
//    places.append(Place.init(nameAddress: "Midway on High", mainImage: #imageLiteral(resourceName: "Midwayonhigh"), secondImage: nil, lat: 39.997669, long: -83.007395, size: 2, early: 0, bio: "Proudly the loudest club on High Street and the best place to dance together.", placeID: "ChIJ73Ok77iOOIgR_EQyWdpUgxE"))
//
//    places.append(Place.init(nameAddress: "Bakersfield Short North", mainImage: #imageLiteral(resourceName: "BakersfieldShortNorth"), secondImage: nil, lat: 39.977321, long: -83.003828, size: 1, early: 0, bio: "Quirky food choices and a long list of beers and cocktails.", placeID: "ChIJu1T6hteOOIgRHLqMIL76xGI"))
//
//    //places.append(Place.init(nameAddress: "Chumley's", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: <#T##Double#>, long: <#T##Double#>, size: <#T##Int#>, early: <#T##Int#>, bio: "", placeID: defaultPlaceID))
//
//    //places.append(Place.init(nameAddress: "Ethyl & Tank", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.997661, long: -83.006919, size: 1, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "The Big Bar & Grill", mainImage: #imageLiteral(resourceName: "BigBar"), secondImage: nil, lat: 39.997343, long: -83.007020, size: 2, early: 0, bio: "Campus watering hole with a dancefloor, giant TVs, and rooftop patio.", placeID: "ChIJfZ9D7LiOOIgR3yngaYcmMms"))
//
//    places.append(Place.init(nameAddress: "The O Patio & Pub", mainImage: #imageLiteral(resourceName: "Opatio&pub"), secondImage: nil, lat: 40.000295, long: -83.007737, size: 2, early: 0, bio: "Let's go to the O and sit around the firepit.", placeID: "ChIJJ8q0brmOOIgRR_SqfUOKtbM"))
//
//    //places.append(Place.init(nameAddress: "The Library", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006640, long: -83.009561, size: 1, early: 0, bio: "", placeID: defaultPlaceID))
//
//    //places.append(Place.init(nameAddress: "Little Bar", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006840, long: -83.009729, size: 2, early: 0, bio: "", placeID: defaultPlaceID))
//
//    //places.append(Place.init(nameAddress: "Cazuelas Grill", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.009699, long: -83.010323, size: 2, early: 0, bio: "", placeID: defaultPlaceID))
//
//    //places.append(Place.init(nameAddress: "Bullwinkles", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.998463, long: -83.007246, size: 2, early: 0, bio: "", placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Fourth Street Bar & Grill", mainImage: #imageLiteral(resourceName: "4thStreetBarandGrill"), secondImage: nil, lat: 40.000335, long: -82.998396, size: 1, early: 0, bio: "Campus pub with craft beers, burgers, and wings.", placeID: "ChIJjwIdAbSOOIgRJrWV2TNIOQE"))
//
//    places.append(Place.init(nameAddress: "Condado Tacos", mainImage: #imageLiteral(resourceName: "Condado"), secondImage: nil, lat: 39.987486, long: -83.005805, size: 2, early: 0, bio: "Arrive with the intention of building the world's best taco.", placeID: "ChIJhyaTGsWOOIgR-sVg4_VyO2w"))
//
//    //places.append(Place.init(nameAddress: "Lucky's Stout House", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.992392, long: -83.006889, size: 1, early: 0, bio: "", placeID: defaultPlaceID))
//
//    // Coffee Shops
//
//    places.append(Place.init(nameAddress: "Fox in the Snow Cafe", mainImage: #imageLiteral(resourceName: "FoxintheSnow"), secondImage: nil, lat: 39.984228, long: -82.999388, size: 2, early: 0, bio: "A chic cafe featuring java drinks and baked goods.", placeID: "ChIJxfUn7NGOOIgRwf1Z3TIzy64"))
//
//    // Shopping Malls
//
//    //places.append(Place.init(nameAddress: "Polaris Fashion Place", mainImage: #imageLiteral(resourceName: "PolarisFashionPlace"), secondImage: #imageLiteral(resourceName: "PolarisFashionPlace1-yelp"), lat: 40.145472, long: -82.981640, size: 0, early: 0, placeID: defaultPlaceID))
//
//    places.append(Place.init(nameAddress: "Easton Town Center", mainImage: #imageLiteral(resourceName: "EastonTownCenter"), secondImage: nil, lat: 40.050716, long: -82.915363, size: 0, early: 0, bio: "A beautiful gathering of every eatery, restaurant, and shop Columbus has to offer.", placeID: "ChIJG9vehYeKOIgRkLBPTqjudW4")) // polygon
//
//    Authenticator.shared.places = self.places
//
//    self.collectionView.reloadData()
//
//}
