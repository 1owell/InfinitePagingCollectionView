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
    
    var index: Int {
        data.firstIndex(of: page.index) ?? 0
    }
    
    func fetchData(for index: Int) -> Int { data[index] }
    

    // UI requests page forward
    func increment(withAnimation: Bool = false) {
        // increment page
        page.increment(withAnimation: withAnimation)
        
        
    }
    
    func incrementData() {
        guard page.index > data[(data.count - 1) / 2] else { return }
        
        for index in 0..<data.count {
            data[index] += 1
        }
        
        print("Data incremented \(data)")
    }
    
    
    // UI request page backwards
    func decrement(withAnimation: Bool = false) {
        // decrement page
        page.decrement(withAnimation: withAnimation)
        
        
    }
    
    func decrementData() {
        guard data.first! > 0 else { return }
        
        for index in 0..<data.count {
            data[index] -= 1
        }
        
        print("Data decremented \(data)")
    }
}

struct Page {
    var index: Int = 0
    var animate = false
    var increment = false
    
    mutating func increment(withAnimation: Bool = false) {
        animate = withAnimation
        increment = true
        index += 1
    }
    
    mutating func decrement(withAnimation: Bool = false) {
        guard index > 0 else { return }
        
        animate = withAnimation
        increment = false
        index -= 1
    }
}
