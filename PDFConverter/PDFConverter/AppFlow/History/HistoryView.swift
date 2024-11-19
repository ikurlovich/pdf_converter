import SwiftUI

struct HistoryView: View {
    @StateObject
    private var viewModel = HistoryViewModel()
    
    let backAction: () -> Void
    let pdfViverAction: () -> Void
    
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
            if viewModel.pdfItems.isEmpty {
                emptyHistoryListView()
            }
            else {
                documentsList()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func documentsList() -> some View {
        let filteredItems = viewModel.pdfItems
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        ScrollView {
            if filteredItems.isEmpty {
                Text("No results found")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(filteredItems, id: \.id) { item in
                    Button {
                        viewModel.selectCurrentURL(url: item.url)
                        pdfViverAction()
                    } label: {
                        HStack {
                            if let coverImage = item.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .frame(width: 48, height: 66)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .foregroundStyle(.black)
                                    .bold()
                                
                                Text(item.date.formatted(.dateTime.day().month(.abbreviated).year()))
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 15))
                                
                                Text("\(item.pages) page")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 15))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5)
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(.black)
                                    .padding(.bottom, 30)
                            }
                        }
                        .padding(.horizontal)
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
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
                .foregroundStyle(.black)
                .font(.system(size: 20, weight: .medium))
            
            Text("Start by scanning, uploading a\nfile, or selecting a photo")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
    HistoryView(backAction: {}, pdfViverAction: {})
}
