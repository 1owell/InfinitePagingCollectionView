//
//  ContentView.swift
//  InfinitePagingUICollectionView
//
//  Created by Lowell Pence on 5/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Data: ")
                ForEach(dataModel.data, id: \.self) { model in
                    Text(model.description)
                        .foregroundColor(model == dataModel.page.index ? .red : .black)
                }
            }
            
            Text("Page \(dataModel.page.index)")
            
            InfinitePagingCollectionView<DayCollectionViewCell>(page: $dataModel.page, dataModel: dataModel)
                .scaleEffect(0.9)
            
            HStack {
                Button(action: { dataModel.page.decrement() }, label: {
                    Image(systemName: "arrow.backward")
                })
                
                Button(action: { dataModel.page.increment() }, label: {
                    Image(systemName: "arrow.forward")
                })
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
