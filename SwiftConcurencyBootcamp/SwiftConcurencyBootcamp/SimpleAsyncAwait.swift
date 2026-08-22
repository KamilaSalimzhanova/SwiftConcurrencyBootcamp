//
//  SimpleAsyncAwait.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 22.08.2026.
//

import SwiftUI
import Combine

final class AsyncAwaitBootcampl: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // does not mean that we go background
        let author2 = "Author2 : \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(author2)
        }
    }
}

struct SimpleAsyncAwait: View {
    @StateObject private var vm = AsyncAwaitBootcampl()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.dataArray, id: \.self) { data in
                    Text(data)
                }
            }
            .navigationTitle("Simple Async/Await examples")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await vm.addAuthor1()
                }
            }
        }
    }
}

#Preview {
    SimpleAsyncAwait()
}
