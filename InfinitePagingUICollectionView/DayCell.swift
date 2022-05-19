//
//  DayCell.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 5/18/22.
//

import SwiftUI

protocol Configurable {
    associatedtype Content: View
    func configure(in parent: UIViewController, withView content: Content)
}

final class DayCollectionViewCell: SwiftUICollectionViewCell<Day> {
    
    static let reuseID = "dayCell"
        
}

struct Day: View {
    
    let index: Int
    @ObservedObject var data: Model
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Index \(index)").font(.body)
                
            Text("Data \(data.data)").font(.system(size: 60, weight: .semibold))
        }
        
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.blue, width: 4)
    }
}

/// Should be subclassed
class SwiftUICollectionViewCell<Content: View>: UICollectionViewCell, Configurable {
    
    private(set) var host: UIHostingController<Content>?
    
    
    /// Receives some SwiftUI view, and adds the UIKit interface via UIHostingController. Resues the hosting controller after creation
    func configure(in parent: UIViewController, withView content: Content) {
        if let host = self.host {
//            print("Reusing host")
            host.rootView = content
            host.view.layoutIfNeeded()
        } else {
//            print("Initializing new host")
            let host = UIHostingController(rootView: content)
            
            parent.addChild(host)
            host.didMove(toParent: parent)
            host.view.frame = contentView.bounds
            contentView.addSubview(host.view)
            
            self.host = host
        }
    }
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        print("MyCollectionViewCell has been cleaned up")
    }
}
