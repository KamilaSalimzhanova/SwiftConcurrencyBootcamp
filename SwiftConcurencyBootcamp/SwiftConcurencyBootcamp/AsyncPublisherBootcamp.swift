//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 20.09.2026.
//

import Foundation
import Combine
import SwiftUI

actor AsyncPublisher {
    @Published var data = [String]()
    
    func addData() async {
        data.append(contentsOf: ["some fruit"])
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append(contentsOf: ["apple", "banana"])
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append(contentsOf: ["melon", "watermelon"])
    }
}

class AsyncPublisherBootcamp: ObservableObject {
    @MainActor @Published var dataArr = [String]()
    
    private let manager = AsyncPublisher()
    var cancell = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func start() async {
        await manager.addData()
    }
    
    private func addSubscribers() {
        Task {
            for await val in await manager.$data.values {
                await MainActor.run {
                    self.dataArr = val
                }
            }
        }
//            .receive(on: DispatchQueue.main)
//            .sink { dataArr in
//                self.dataArr = dataArr
//            }
//            .store(in: &cancell)
    }
}

struct AsyncPublisherView: View {
    @StateObject private var vm = AsyncPublisherBootcamp()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.dataArr, id: \.self) { text in
                    Text(text)
                        .foregroundStyle(.black)
                }
            }
        }
        .task {
            await vm.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherView()
    }
}
