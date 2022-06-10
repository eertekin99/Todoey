//
//  Category.swift
//  Todoey
//
//  Created by Efe Ertekin on 9.06.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item> ()
}
