//
//  Calculation+CoreDataClass.swift
//  GURTAM_TEST
//
//  Created by Yra on 16.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Calculation)
public class Calculation: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.sharedManager.entityForName(entityName: "Calculation"), insertInto: CoreDataManager.sharedManager.persistentContainer.viewContext)
    }
}
