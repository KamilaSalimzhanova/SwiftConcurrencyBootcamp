//
//  ActorBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 25.08.2026.
//

import SwiftUI
import Combine

actor MyActorDataManager {
    static let shared = MyActorDataManager()
    
    private init() {}
    
    var data: [String] = []
    
    func getRandData() -> String? {
        self.data.append(UUID().uuidString)
        print("Current thread \(Thread.current)")
        return self.data.randomElement()
    }
}

final class MyDataManager {
    static let shared = MyDataManager()
    
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandData(completionHandler: @escaping (String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print("Current thread \(Thread.current)")
            completionHandler(self.data.randomElement())
        }
    }
}

struct HomeView: View {
    @State private var text: String = ""
    
    private let manager = MyDataManager.shared
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandData { title in
//                    if let title {
//                        DispatchQueue.main.async {
//                            self.text = title
//                        }
//                    }
//                 }
//            }
        }
    }
}

struct BrowseView: View {
    @State private var text: String = ""
    
    private let manager = MyActorDataManager.shared
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            Task {
//                let title = await manager.getRandData()
//                if let title {
//                    await MainActor.run {
//                        text = title
//                    }
//                }
//            }
        }
    }
}

struct ActorBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorBootcamp()
}
