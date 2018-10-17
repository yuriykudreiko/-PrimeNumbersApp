//
//  PrimeNumbers+CoreDataProperties.swift
//  GURTAM_TEST
//
//  Created by Yra on 16.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//
//

import Foundation
import CoreData


extension PrimeNumbers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrimeNumbers> {
        return NSFetchRequest<PrimeNumbers>(entityName: "PrimeNumbers")
    }

    @NSManaged public var number: Int32
    @NSManaged public var calculation: Calculation?

}
