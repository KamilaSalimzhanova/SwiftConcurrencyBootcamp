//
//  DownloadImageAsync.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 19.08.2026.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    let url = URL(string: "https://picsum.photos/200")!
    
    // async await
    func downloadImageWithAsyncAwait() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
    // combine
    func downloadImageWithCombine() -> AnyPublisher <UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    // escaping
    func downloadImageWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completion(image, error)
        }
        .resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        
        return image
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    var cancellabes = Set<AnyCancellable>()
    let loader = DownloadImageAsyncImageLoader()
    
    func fetchImage() async {
//        loader.downloadImageWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        
        
//        loader.downloadImageWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//            } receiveValue: { [weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellabes)
        
        let image = try? await loader.downloadImageWithAsyncAwait()
        
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject private var vm = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 400, maxHeight: 400)
            }
        }
        .onAppear() {
            Task {
                await vm.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
