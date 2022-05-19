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
    
    @Published var data: [Model] = [0, 1, 2, 3, 4, 5, 6].map(Model.init)
    
    func fetchData(for index: Int) -> Model {
        return data[index]
    }
    
    var shouldAdjustData: Bool {
        page.index > data[(data.count - 1) / 2].data
    }
    
    var shouldDecrement: Bool { data.first!.data > 0 }
    
    func increment() {
        for index in 0..<data.count {
            data[index].data += 1
        }
        objectWillChange.send()
        print("Data incremented \(data.map(\.data))")
    }
    
    func decrement() {
        guard data.first?.data != 0 else { return }
        
        for index in 0..<data.count {
            data[index].data -= 1
        }
        objectWillChange.send()
        print("Data decremented \(data.map(\.data))")
    }
}

struct ContentView: View {
    
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Data: ")
                ForEach(dataModel.data) { model in
                    Text(model.data.description)
                        .foregroundColor(model.data == dataModel.page.index ? .red : .white)
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
