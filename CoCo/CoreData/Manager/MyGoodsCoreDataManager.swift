//
//  CoreDataManager.swift
//  CoCo
//
//  Created by 강준영 on 25/01/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MyGoodsCoreDataManager: MyGoodsCoreDataManagerType {

    // MARK: - Fetch Methodes
    /**
     MyGoods의 모든 데이터를 오름차순으로 가져온다.
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameter :
     - pet: 해당하는 펫(고양이 또는 강아지)과 관련된 데이터를 가져오기 위한 파마리터.
     기본값은 nil로, 값을 넣어주지 않으면 고양이와 강아지의 모든 데이터를 가져온다.
     */
    func fetchObjects(pet: String? = nil) throws -> [CoreDataStructEntity]? {
        let sort = NSSortDescriptor(key: #keyPath(MyGoods.date), ascending: true)
        var myGoodsDatas: [MyGoodsData] = []
        var predicate: NSPredicate?

        if let pet = pet {
            predicate = NSPredicate(format: "pet = %@", pet)
        }

        guard let objects = try fetchObjects(MyGoods.self, sortBy: [sort], predicate: predicate) else {
            return nil
        }
        if !objects.isEmpty {
            for object in objects {
                var myGoodsData = MyGoodsData()
                myGoodsData.mappinng(from: object)
                myGoodsDatas.append(myGoodsData)
            }
            return myGoodsDatas
        } else {
            return nil
        }
    }

    /**
     해당펫의 즐겨찾기 한 데이터를 오름차순으로 가져온다
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameter :
     - pet: 해당하는 펫(고양이 또는 강아지)과 관련된 데이터를 가져오기 위한 파마리터.
     */
    func fetchFavoriteGoods(pet: String? = nil) throws -> [MyGoodsData]? {
        let sort = NSSortDescriptor(key: #keyPath(MyGoods.date), ascending: true)
        var myGoodsDatas: [MyGoodsData] = []
        var predicate: NSPredicate?

        if let pet = pet {
            predicate = NSPredicate(format: "pet = %@ AND isFavorite = %@", pet, NSNumber(booleanLiteral: true))
        } else {
            predicate = NSPredicate(format: "isFavorite = %@", NSNumber(booleanLiteral: true))
        }

        guard let objects = try fetchObjects(MyGoods.self, sortBy: [sort], predicate: predicate) else {
            return nil
        }

        if !objects.isEmpty {
            for object in objects {
                var myGoodsData = MyGoodsData()
                myGoodsData.mappinng(from: object)
                myGoodsDatas.append(myGoodsData)
            }
            return myGoodsDatas
        } else {
            return nil
        }
    }

    /**
     해당펫의 최근본 상품을 오름차순, 내림차순으로 가져온다
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameter :
     - pet: 해당하는 펫(고양이 또는 강아지)과 관련된 데이터를 가져오기 위한 파마리터.
     - isLatest: 데이터를 오름차순, 또는 내림차순으로 가져오기 위한 파라미터
     */
    func fetchLatestGoods(pet: String? = nil, isLatest: Bool, ascending: Bool) throws -> [MyGoodsData]? {
        let sort = NSSortDescriptor(key: #keyPath(MyGoods.date), ascending: ascending)
        var myGoodsDatas: [MyGoodsData] = []
        var predicate: NSPredicate?

        if let pet = pet {
             predicate = NSPredicate(format: "pet = %@ AND isLatest = %@", pet, NSNumber(booleanLiteral: isLatest))
        } else {
            predicate = NSPredicate(format: "isLatest = %@", NSNumber(booleanLiteral: isLatest))
        }

        guard let objects = try fetchObjects(MyGoods.self, sortBy: [sort], predicate: predicate) else {
            return nil
        }

        if !objects.isEmpty {
            for object in objects {
                var myGoodsData = MyGoodsData()
                myGoodsData.mappinng(from: object)
                myGoodsDatas.append(myGoodsData)
            }
            return myGoodsDatas
        } else {
            return nil
        }
    }

    /**
     productId를 통해 동일한 상품이 Entity에 존재하는 지 확인.
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameter :
     - productId: 상품들마다 가지고 있는 고유 productId.
     */
    func fetchProductID(productID: String) -> MyGoods? {
        var predicate: NSPredicate?
        predicate = NSPredicate(format: "productID = %@", productID)

        do {
            guard let object = try fetchObjects(MyGoods.self, sortBy: nil, predicate: predicate) else {
                return nil
            }
            guard let firstObject = object.first else {
                throw CoreDataError.fetch(message: "MyGoods Entity has not \(productID) data, So can not fetch data")
            }
            return firstObject
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    // MARK: - Delete Method
    /**
     특정펫의 즐겨찾기한 상품들을 모두 삭제한다.
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameters:
     - pet: 특정 펫의 데이터를 지우기위한 파라미터.
     */
    @discardableResult func deleteFavoriteAllObjects(pet: String) throws -> Bool {
        guard let context = context else {
            return false
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyGoods")
        let predicate = NSPredicate(format: "pet = %@ AND isFavorite = true AND isLatest = false", pet)

        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    /**
     특정펫의 최근본 상품들을 모두 삭제한다.
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameters:
     - pet: 특정 펫의 데이터를 지우기위한 파라미터.
     */
    @discardableResult func deleteLatestAllObjects(pet: String, isLatest: Bool) throws -> Bool {
        guard let context = context else {
            return false
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyGoods")
        let predicate = NSPredicate(format: "pet = %@ AND isLatest = %@ AND isFavorite = false", pet, NSNumber(booleanLiteral: isLatest))
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            print("Delete!")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    /**
     최근본 상품들을 날짜순으로 정렬 후 10개를 제외한 데이터들은 최근본 정보를 false로 변환
     - Author: [강준영](https://github.com/lavaKangJun)
     - Parameters:
     - pet: 특정 펫의 데이터를 지우기위한 파라미터.
     */
    func latestGoodsToFalse(pet: String) throws {
        do {
            guard var objects = try fetchLatestGoods(pet: pet, isLatest: true, ascending: false) else {
                throw CoreDataError.fetch(message: "Can not fetch data")
            }
            if objects.count > 10 {
                for index in 10..<objects.count {
                    objects[index].isLatest = false
                    print(index)
                    try updateObject(objects[index])
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
