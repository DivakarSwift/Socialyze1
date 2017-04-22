//
//  Places+CoreDataProperties.swift
//  
//
//  Created by Muhammad Salman on 4/19/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Places {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Places> {
        return NSFetchRequest<Places>(entityName: "Places");
    }

    @NSManaged public var place_address: String?
    @NSManaged public var place_image: NSData?
    @NSManaged public var place_lat: String?
    @NSManaged public var place_long: String?
    @NSManaged public var place_name: String?
    @NSManaged public var place_rating: String?

}
