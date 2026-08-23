//
//  TaskGroupBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 23.08.2026.
//

import SwiftUI
import Combine

final class DataManager {
    private let url = "https://picsum.photos/200"
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(url: url)
        async let fetchImage2 = fetchImage(url: url)
        async let fetchImage3 = fetchImage(url: url)
        async let fetchImage4 = fetchImage(url: url)
        
        let images: [UIImage] = try await [fetchImage1, fetchImage2, fetchImage3, fetchImage4]
        
        return images
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = Array(repeating: "https://picsum.photos/300", count: 5)
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)

            for urlString in urlStrings {
                group.addTask {
                    try await self.fetchImage(url: urlString)
                }
            }
            for try await taskResult in group {
                images.append(taskResult)
            }

            return images
        }
    }
    
    private func fetchImage(url: String) async throws -> UIImage {
        guard let url = URL(string: url) else { throw URLError(.badURL) }
        
        try Task.checkCancellation()
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

final class TaskGroupVM: ObservableObject {
    @Published var images: [UIImage] = []
    
    let manager = DataManager()
    
    func getImages() async {
        do {
            let fetched = try await manager.fetchImagesWithTaskGroup()
            await MainActor.run {
                self.images.append(contentsOf: fetched)
            }
        } catch {
            print("Failed to fetch images:", error)
        }
    }
}

struct TaskGroupBootcamp: View {
    @StateObject private var vm = TaskGroupVM()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task group bootcamp")
            .task {
                await vm.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
