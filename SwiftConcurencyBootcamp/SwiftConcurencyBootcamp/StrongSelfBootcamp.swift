//
//  StrongSelfBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 20.09.2026.
//

import SwiftUI
import Combine

final class DataService {
    func getData() async -> String {
        "Updated data"
    }
}

final class StrongSelfVM: ObservableObject {
    @Published var data = "Text"
    let dataService = DataService()
    
    func updateData() {
        Task {
            // Strong reference implication
            data = await dataService.getData()
        }
    }
    
    func updateData2() {
        Task {
            // Strong reference explicitly with self
            self.data = await dataService.getData()
        }
    }
    
    func updateData3() {
        Task { [self] in
            // Strong reference explicitly with self
            self.data = await dataService.getData()
        }
    }
    
    func updateData4() {
        Task { [weak self] in
            // weak ref
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
}

struct StrongSelfBootcamp: View {
    @StateObject private var vm = StrongSelfVM()
    
    var body: some View {
        Text(vm.data)
            .onAppear {
                vm.updateData()
            }
    }
}

#Preview {
    StrongSelfBootcamp()
}
