import SwiftUI

struct HistoryView: View {
    let backAction: () -> Void
    
    @State
    var searchText: String = ""
    
    var body: some View {
        VStack {
            customNavigationPanel()
            searchHistoryView()
            historyList()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMain)
    }
    
    @ViewBuilder
    private func historyList() -> some View {
        VStack {
            emptyHistoryListView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func searchHistoryView() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
            
            TextField(text: $searchText) {
                Text("Search")
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal)
        .foregroundStyle(.white)
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func emptyHistoryListView() -> some View {
        VStack {
            Image(.historyEmptyList)
                .resizable()
                .frame(width: 110, height: 110)
                .padding(.bottom)
            
            Text("No Files Yet")
                .font(.system(size: 20, weight: .medium))
            
            Text("Start by scanning, uploading a\nfile, or selecting a photo")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
            
            Button(action: backAction) {
                NavigationLabel(text: "Start")
            }
        }
    }
    
    @ViewBuilder
    private func customNavigationPanel() -> some View {
        ZStack {
            Button(action: {}) {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 21, height: 21)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
            
            VStack {
                Text("History")
                    .bold()
                    .font(.title)
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    HistoryView(backAction: {})
}
