//
//  PetKeyword.swift
//  CoCo
//
//  Created by 강준영 on 29/01/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import Foundation
import CoreData

struct PetKeywordData: CoreDataStructEntity {
    var objectID: NSManagedObjectID?
    // MARK: - Propertise
    var keywords: [String] = []
    var pet = ""
    
    
    init() { }
    
    init(pet: String, keywords: [String]) {
        self.pet = pet
        self.keywords = keywords
    }
}
