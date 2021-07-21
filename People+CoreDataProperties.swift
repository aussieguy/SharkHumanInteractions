//
//  People+CoreDataProperties.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 26/1/21.
//
//

import Foundation
import CoreData


extension People {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<People> {
        return NSFetchRequest<People>(entityName: "People")
    }

    @NSManaged public var activity: String?
    @NSManaged public var age: String?
    @NSManaged public var area: String?
    @NSManaged public var country: String?
    @NSManaged public var date: String?
    @NSManaged public var fatal: String?
    @NSManaged public var gender: String?
    @NSManaged public var injury: String?
    @NSManaged public var latitudelongitude: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var species: String?
    @NSManaged public var time: String?
    @NSManaged public var type: String?
    @NSManaged public var year: String?
    @NSManaged public var uniqID: Int64

}

extension People : Identifiable {

}
