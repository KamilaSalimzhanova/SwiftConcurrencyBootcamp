//
//  AsyncLetBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 23.08.2026.
//

import SwiftUI
import Combine

struct AsyncLetBootcamp: View {
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async let bootcamp")
            .task {
                do {
                    async let fetchImage1 = fetchImage()
                    async let fetchImage2 = fetchImage()
                    async let fetchImage3 = fetchImage()
                    async let fetchImage4 = fetchImage()
                    
                    let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
                    
                    images.append(contentsOf: [image1])
                    images.append(contentsOf: [image2])
                    images.append(contentsOf: [image3])
                    images.append(contentsOf: [image4]) 
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchImage() async throws -> UIImage {
        guard let url else {
            throw URLError(.badURL)
        }
        
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

#Preview {
    AsyncLetBootcamp()
}
