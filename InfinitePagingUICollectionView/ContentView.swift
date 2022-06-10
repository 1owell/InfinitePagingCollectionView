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
            HStack(spacing: 2) {
                Text("Data: ")
                ForEach(dataModel.data, id: \.self) { model in
                    Text(model.description).foregroundColor(model == dataModel.page.index ? .red : .black).font(.caption)
                }
            }
            
            Text("Page \(dataModel.page.index)")
            
            InfinitePagingCollectionView(page: $dataModel.page, dataModel: dataModel)
                .scaleEffect(0.9)
            
            HStack {
                Button(action: { dataModel.decrement(withAnimation: true) }, label: {
                    Image(systemName: "arrow.backward")
                })
                
                Button(action: { dataModel.increment(withAnimation: true) }, label: {
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
