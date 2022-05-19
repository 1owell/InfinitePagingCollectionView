//
//  UICollectionViewWrapper.swift
//  Retrospect (iOS)
//
//  Created by Lowell Pence on 4/24/22.
//

import SwiftUI
import Combine

protocol CollectionViewSection: Hashable {
    static var main: Self { get }
}

enum DayCollectionSection: Int {
    case main
}

struct InfinitePagingCollectionView<Cell: UICollectionViewCell & Configurable>: UIViewControllerRepresentable {
    
    typealias Section    = DayCollectionSection
    typealias Identifier = Int
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Identifier>
    
    @Binding var page: Page
    @EnvironmentObject var dataModel: DataModel
    
    private var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0 // necessary
        
        return layout
    }
    
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        let controller = UICollectionViewController(collectionViewLayout: layout)
        controller.collectionView.showsHorizontalScrollIndicator = false
        controller.collectionView.isPagingEnabled = true
        controller.collectionView.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: DayCollectionViewCell.reuseID)
        controller.collectionView.delegate = context.coordinator
        
        context.coordinator.dataSource = InfiniteDataSource<Cell>(dataModel, controller)
        controller.collectionView.dataSource = context.coordinator.dataSource

        return controller
    }
    
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        print("updateUIViewController called")
        shiftData(uiViewController.collectionView, context: context)
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator($page)
    }
    
    
    private func scrollTo(_ index: Int, view: UICollectionView, context: Context) {
        // Remove the delegate to manually scroll, then re-add
        view.delegate = nil
        print("------")
        let index = (dataModel.data.count - 1) / 2
        print("Scrolling to index \(index)")
        view.scrollToPage(index: index, animated: false, offset: &context.coordinator.offset)
        view.delegate = context.coordinator
    }
    
    
    // only want to shift data if contentOffset adjustment was user initiated
    private func shiftData(_ scrollView: UICollectionView, context: Context) {
        
        guard dataModel.shouldAdjustData else {
            print("Preventing data shift because page (\(page.index)) is not greater than the middle point \( dataModel.data[(dataModel.data.count - 1) / 2].data )")
            
            // getting called twice
            if dataModel.shouldDecrement && page.index < context.coordinator._temp {
                dataModel.decrement()
                let index = (dataModel.data.count - 1) / 2
                scrollTo(index, view: scrollView, context: context)
                context.coordinator._temp = dataModel.page.index
            }
            
            return
        }
        
        if dataModel.page.index > context.coordinator._temp {
            dataModel.increment()
            let index = (dataModel.data.count - 1) / 2
            scrollTo(index, view: scrollView, context: context)
        }
        
        context.coordinator._temp = dataModel.page.index
    }
    
    
    final class Coordinator: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
        
        @Binding var page: Page
        var offset = 0.0
        var _temp: Int = 0
        
        var dataSource: InfiniteDataSource<Cell>!
        
        init(_ page: Binding<Page>) {
            self._page = page
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        
        // Triggered from programmatic scroll
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    //        afterScrollActions(scrollView)
        }
        
        // Triggered from finger scroll
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            afterScrollActions(scrollView)
        }
        
        private func afterScrollActions(_ scrollView: UIScrollView) {
            guard let scrollView = scrollView as? UICollectionView else { return }
            
            let currentOffset = scrollView.contentOffset.x
        
            guard currentOffset != offset else {
                print("NO full page scroll detected")
                return
            }
            
            if currentOffset > offset {
                page.increment()
            } else {
                page.decrement()
            }
            
            print("Scroll complete, now at page \(page.index)")
            offset = currentOffset
        }
    }
}


extension UICollectionView {
    
    var currentPage: Int {
        Int(contentOffset.x / frame.size.width)
    }
    
    func scrollToEnd(_ section: Int) {
        let row = numberOfItems(inSection: section) - 1
        scrollToItem(at: .init(row: row, section: section), at: .centeredHorizontally, animated: true)
    }
    
    func scrollToPage(index: Int, animated: Bool = true, offset: inout Double) {
        scrollToItem(at: .init(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        offset = self.contentOffset.x
    }
}


class InfiniteDataSource<Cell: UICollectionViewCell & Configurable>: NSObject, UICollectionViewDataSource {
    
    let dataModel: DataModel
    let controller: UIViewController
    
    init(_ dataModel: DataModel, _ controller: UIViewController) {
        self.dataModel = dataModel
        self.controller = controller
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuse = DayCollectionViewCell.reuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as! Cell

        let data = dataModel.fetchData(for: indexPath.row)
        cell.configure(in: controller, withView: Day(index: indexPath.row, data: data) as! Cell.Content)

        return cell
    }
}
