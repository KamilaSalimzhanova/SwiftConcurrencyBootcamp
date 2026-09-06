//
//  GlobalActorView.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 06.09.2026.
//

import SwiftUI
import Combine

@globalActor struct GlobalActorImpl {
    static var shared = GlobalActor()
}

actor GlobalActor {
    func getDataFromAPI() -> [String] {
        ["Data 1", "Data 2", "Data 3"]
    }
}

final class GlobalActorViewData: ObservableObject {
    @Published var data = [String]()
    
    private let actor = GlobalActorImpl.shared
    
    @GlobalActorImpl func getData() async {
        let data = await actor.getDataFromAPI()
        
        await MainActor.run {
            self.data = data
        }
    }
}

struct GlobalActorView: View {
    @StateObject private var globalActor = GlobalActorViewData()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(globalActor.data, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await globalActor.getData()
        }
    }
}

#Preview {
    GlobalActorView()
}
