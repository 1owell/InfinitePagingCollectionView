//
//  Page.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 6/10/22.
//

import Foundation

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
