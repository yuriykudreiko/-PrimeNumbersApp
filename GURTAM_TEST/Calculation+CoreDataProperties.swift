//
//  Calculation+CoreDataProperties.swift
//  GURTAM_TEST
//
//  Created by Yra on 16.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//
//

import Foundation
import CoreData


extension Calculation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calculation> {
        return NSFetchRequest<Calculation>(entityName: "Calculation")
    }

    @NSManaged public var name: Int16
    @NSManaged public var time: Double
    @NSManaged public var maxNumber: Int32
    @NSManaged public var primeNumbers: NSSet?

}

// MARK: Generated accessors for primeNumbers
extension Calculation {

    @objc(addPrimeNumbersObject:)
    @NSManaged public func addToPrimeNumbers(_ value: PrimeNumbers)

    @objc(removePrimeNumbersObject:)
    @NSManaged public func removeFromPrimeNumbers(_ value: PrimeNumbers)

    @objc(addPrimeNumbers:)
    @NSManaged public func addToPrimeNumbers(_ values: NSSet)

    @objc(removePrimeNumbers:)
    @NSManaged public func removeFromPrimeNumbers(_ values: NSSet)

}
