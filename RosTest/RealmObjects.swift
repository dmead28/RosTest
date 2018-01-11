//
//  RealmObjects.swift
//  RosTest
//
//  Created by Doug Mead on 1/9/18.
//  Copyright © 2018 Doug Mead. All rights reserved.
//

import Foundation
import RealmSwift

class TestObject: Object {
    @objc dynamic var id: String = ""
    convenience init(id: String) {
        self.init()
        self.id = id
    }
}

// Created this to avoid duplicates with realm server and easier to read than UUID
class Incrementer {
    func incrementingIndex(forKey key: String) -> Int {
        let index = UserDefaults.standard.integer(forKey: key)
        let newIndex = index + 1
        UserDefaults.standard.set(newIndex, forKey: key)
        return newIndex
    }
}
