//
//  RealmSwift.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.11.22.
//

import Foundation
import RealmSwift

class RealmManager<T> where T: Object {
    private let realm = try! Realm()
    
    func write(object: T) {
        try? realm.write {
            realm.add(object)
        }
    }
    
    func read() -> [T] {
        return Array(realm.objects(T.self))
    }
}
