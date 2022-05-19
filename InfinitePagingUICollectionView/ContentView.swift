//
//  ContentView.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 5/18/22.
//

import SwiftUI

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

class Model: ObservableObject, Identifiable {
    var id: Int { data }
    @Published var data: Int
    
    init(data: Int) {
        self.data = data
    }
}

class DataModel: ObservableObject {
    
    @Published var page = Page()
    
    @Published var data: [Int] = [0, 1, 2, 3, 4, 5, 6]
    
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

struct ContentView: View {
    
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Data: ")
                ForEach(dataModel.data, id: \.self) { model in
                    Text(model.description)
                        .foregroundColor(model == dataModel.page.index ? .red : .white)
                }
            }
            
            Text("Page \(dataModel.page.index)")
            
            InfinitePagingCollectionView<DayCollectionViewCell>(page: $dataModel.page)
                .environmentObject(dataModel)
                .scaleEffect(0.9)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
