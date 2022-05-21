//
//  UICollectionViewWrapper.swift
//  Retrospect (iOS)
//
//  Created by Lowell Pence on 4/24/22.
//

import SwiftUI

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
    let dataModel: DataModel
    
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
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Identifier>(collectionView: controller.collectionView)
        { collectionView, indexPath, itemIdentifier in
            let reuse = DayCollectionViewCell.reuseID
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as! Cell

            cell.configure(in: controller, withView: Day(index: indexPath.row, data: itemIdentifier) as! Cell.Content)

            return cell
        }
        
        context.coordinator.dataSource = dataSource
        
        updateCollectionViewData(with: dataModel.data, using: dataSource, animate: false)

        return controller
    }
    
    
    /// Updates scroll view when the page state changes
    private func updateVisiblePage(_ collectionView: UICollectionView, context: Context) {
        guard dataModel.page.index != context.coordinator._temp else { return }
        
        // TODO: This isn't working properly
        
        if dataModel.page.index == context.coordinator._temp + 1 {
            collectionView.setContentOffset(.init(x: collectionView.contentOffset.x + collectionView.frame.width, y: 0), animated: true)
            context.coordinator.offset = collectionView.contentOffset.x + collectionView.frame.width
        } else if dataModel.page.index == context.coordinator._temp - 1 {
            collectionView.setContentOffset(.init(x: collectionView.contentOffset.x - collectionView.frame.width, y: 0), animated: true)
            context.coordinator.offset = collectionView.contentOffset.x - collectionView.frame.width
        }
    }
    
    
    private func updateCollectionViewData(with data: [Identifier], using dataSource: DataSource, animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Identifier>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    
    private func reconfigureData(with data: [Identifier], using dataSource: DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(data)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
//        updateVisiblePage(uiViewController.collectionView, context: context)
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
            print("Preventing data shift because page (\(page.index)) is not greater than the middle point \( dataModel.data[(dataModel.data.count - 1) / 2] )")
            
            // getting called twice
            if dataModel.shouldDecrement && page.index < context.coordinator._temp {
                dataModel.decrement()
                updateCollectionViewData(with: dataModel.data, using: context.coordinator.dataSource, animate: false)
                let index = (dataModel.data.count - 1) / 2
                scrollTo(index, view: scrollView, context: context)
                context.coordinator._temp = dataModel.page.index
            }
            
            return
        }
        
        if dataModel.page.index > context.coordinator._temp {
            dataModel.increment()
            updateCollectionViewData(with: dataModel.data, using: context.coordinator.dataSource, animate: false)
            let index = (dataModel.data.count - 1) / 2
            scrollTo(index, view: scrollView, context: context)
        }
        
        context.coordinator._temp = dataModel.page.index
    }
    
    
    final class Coordinator: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
        
        @Binding var page: Page
        
        var offset = 0.0
        var _temp: Int = 0
        var dataSource: UICollectionViewDiffableDataSource<Section, Identifier>!
        
        init(_ page: Binding<Page>) {
            self._page = page
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        
        // Triggered from programmatic scroll
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            afterScrollActions(scrollView)
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
