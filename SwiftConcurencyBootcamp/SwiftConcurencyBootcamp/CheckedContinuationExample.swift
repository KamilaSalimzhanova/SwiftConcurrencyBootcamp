//
//  CheckedContinuationExample.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 23.08.2026.
//

import SwiftUI
import Combine

final class CheckedContinuationDataManager {
    fileprivate func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            return data
        } catch {
            throw error
        }
    }
    
    fileprivate func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data {
                    continuation.resume(returning: data)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
    }
}

final class CheckedContinuationVM: ObservableObject {
    @Published var image: UIImage? = nil
    private let dataManager = CheckedContinuationDataManager()
    
    fileprivate func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await dataManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CheckedContinuationExample: View {
    @StateObject private var vm = CheckedContinuationVM()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .task {
            await vm.getImage()
        }
    }
}

#Preview {
    CheckedContinuationExample()
}
