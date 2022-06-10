//
//  UICollectionViewWrapper.swift
//
//  Created by Lowell Pence on 4/24/22.
//

import SwiftUI

enum DayCollectionSection: Int {
    case main
}

struct InfinitePagingCollectionView: UIViewControllerRepresentable {
    
    typealias Section    = DayCollectionSection
    typealias Identifier = Int
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Identifier>
    let reuseID = "cell"
    
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
        controller.collectionView.delegate = context.coordinator
        controller.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseID)
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Identifier>(collectionView: controller.collectionView)
        { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)

            cell.contentConfiguration = UIHostingConfiguration {
                Text("\(itemIdentifier.description)")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
            }
            
            return cell
        }
        
        context.coordinator.dataSource = dataSource
        
        updateCollectionViewData(with: dataModel.data, using: dataSource, animate: false)

        return controller
    }
    
    
    private func updateCollectionViewData(with data: [Identifier],
                                          using dataSource: DataSource,
                                          animate: Bool = true,
                                          completion: (() -> ())? = nil) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Identifier>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: animate, completion: completion)
    }
    
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        if page.animate {
            // User tapped arrow button, should scroll then update data in the scrollViewDidEndAnimation delegate
            scrollTo(dataModel.index, view: uiViewController.collectionView, coordinator: context.coordinator, animated: true)
        } else {
            if page.increment {
                dataModel.incrementData()
            } else {
                dataModel.decrementData()
            }
            
            updateCollectionViewData(with: dataModel.data, using: context.coordinator.dataSource, animate: false)
            
            // after data is updated, find the index of the item in the data array that matches page.index
            let index = dataModel.data.firstIndex(of: page.index) ?? dataModel.data.endIndex
            scrollTo(index, view: uiViewController.collectionView, coordinator: context.coordinator, animated: page.animate)
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    private func scrollTo(_ index: Int, view: UICollectionView, coordinator: Coordinator, animated: Bool = false) {
        // Remove the delegate to manually scroll, then re-add
        view.delegate = nil
        print("------")
        print("Scrolling to index \(index) of \(dataModel.data) (\(dataModel.data[index])), animated: \(animated)")
        view.scrollToPage(index: index, animated: animated, offset: &coordinator.offset)
        view.delegate = coordinator
    }
    
    
    final class Coordinator: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
        
        let view: InfinitePagingCollectionView
        
        var offset = 0.0
        var _temp: Int = 0
        var dataSource: UICollectionViewDiffableDataSource<Section, Identifier>!
        
        init(_ wrapper: InfinitePagingCollectionView) {
            self.view = wrapper
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        
        
        // Triggered from programmatic scroll
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            // see if data needs to be incremented
            if view.page.increment {
                view.dataModel.incrementData()
            } else {
                view.dataModel.decrementData()
            }
            
            view.updateCollectionViewData(with: view.dataModel.data, using: dataSource, animate: false)
            view.scrollTo(view.dataModel.index, view: scrollView as! UICollectionView, coordinator: self)
        }
        
        
        // Triggered from finger scroll
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard let scrollView = scrollView as? UICollectionView else { return }
            
            let currentOffset = scrollView.contentOffset.x
        
            guard currentOffset != offset else {
                print("NO full page scroll detected")
                return
            }
            
            if currentOffset > offset {
                view.dataModel.increment()
            } else {
                view.dataModel.decrement()
            }
            
            offset = currentOffset
        }
    }
}
