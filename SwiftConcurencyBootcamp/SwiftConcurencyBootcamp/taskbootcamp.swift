//
//  taskbootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 22.08.2026.
//

import SwiftUI
import Combine

final class TaskBootcampVM: ObservableObject {
    let url = URL(string: "https://picsum.photos/200")
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run {
                self.image = UIImage(data: data)
                print("yesss")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                self.image2 = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct newView: View {
    var body: some View {
        NavigationView {
            NavigationLink("Click me!") {
                taskbootcamp()
            }
        }
    }
}

struct taskbootcamp: View {
    @StateObject private var vm = TaskBootcampVM()
    @State private var task: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            if let image = vm.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                }
        }
        .onDisappear {
            self.task?.cancel()
        }
        .onAppear {
            self.task = Task {
                print(Thread.current)
                print(Task.currentPriority)
                await vm.fetchImage()
            }
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await vm.fetchImage2()
//            }
//            Task(priority: .low) {
//                print("low \(Thread.current) and \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("medium \(Thread.current) and \(Task.currentPriority)")
//            }
//            Task(priority: .high) {
//                print("high \(Thread.current) and \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("bg \(Thread.current) and \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility \(Thread.current) and \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userinitiated \(Thread.current) and \(Task.currentPriority)")
//            } 
        }
    }
}

#Preview {
    newView()
}

