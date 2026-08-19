//
//  DoCatchTryThrowsView.swift
//  SwiftConcurencyBootcamp
//
//  Created by kamila on 19.08.2026.
//

import SwiftUI
import Combine

final class DoCatchDataManager {
    let isActive: Bool = false
    
    func getTitle() -> (title: String?, error: Error?) {
        isActive ? ("new text", nil) : (nil, URLError(.badURL))
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "NEW TEXT"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

final class DoCatchViewModel: ObservableObject {
    @Published var text: String = "Starting text"
    
    let manager = DoCatchDataManager()
    
    func fetchRequest() {
        /*
        let newtitle = manager.getTitle()
        
        if let newtitleText = newtitle.title {
            text = newtitleText
            
            return
        } else {
            text = newtitle.error?.localizedDescription ?? ""
        }
         */
        
        /*
        let result = manager.getTitle2()
        switch result {
        case .success(let success):
            self.text = success
        case .failure(let failure):
            self.text = failure.localizedDescription
        }
         */
        
        do {
            self.text = try manager.getTitle3()
        } catch let error {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowsView: View {
    @StateObject private var vm = DoCatchViewModel()
    
    var body: some View {
        Text(vm.text)
            .foregroundStyle(Color.red)
            .frame(width: 300, height: 200)
            .background(Color.blue).opacity(0.5)
            .onTapGesture {
                vm.fetchRequest()
            }
    }
}

#Preview {
    DoCatchTryThrowsView()
}
