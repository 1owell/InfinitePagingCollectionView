//
//  DataModel.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 5/18/22.
//

import Foundation

final class DataModel: ObservableObject {
    
    @Published var page = Page()
    var data: [Int] = [0, 1, 2, 3, 4, 5, 6]
    
    func fetchData(for index: Int) -> Int {
        return data[index]
    }
    
    var shouldAdjustData: Bool {
        page.index > data[(data.count - 1) / 2]
    }
    
    var shouldDecrement: Bool { data.first! > 0 }
    
    func increment() {
        for index in 0..<data.count {
            data[index] += 1
        }
        
        print("Data incremented \(data)")
    }
    
    func decrement() {
        guard data.first != 0 else { return }
        
        for index in 0..<data.count {
            data[index] -= 1
        }
        
        print("Data decremented \(data)")
    }
}

struct Page {
    var index: Int = 0
    
    mutating func increment() {
        index += 1
    }
    
    mutating func decrement() {
        guard index > 0 else { return }
        
        index -= 1
    }
}
