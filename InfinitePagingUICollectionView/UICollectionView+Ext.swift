//
//  UICollectionView+Ext.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 5/18/22.
//

import UIKit

extension UICollectionView {
    func scrollToEnd(_ section: Int) {
        let row = numberOfItems(inSection: section) - 1
        scrollToItem(at: .init(row: row, section: section), at: .centeredHorizontally, animated: true)
    }
    
    func scrollToPage(index: Int, animated: Bool = true, offset: inout Double) {
        scrollToItem(at: .init(row: index, section: 0), at: .centeredHorizontally, animated: animated)
        offset = contentOffset.x
    }
}
