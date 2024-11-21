import SwiftUI

struct HistoryView: View {
    @StateObject
    private var viewModel = HistoryViewModel()
    
    let backAction: () -> Void
    let pdfViverAction: () -> Void
    let paywallAction: () -> Void
    
    var body: some View {
        VStack {
            customNavigationPanel()
            searchHistoryView()
            historyList()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMain)
        .onAppear(perform: viewModel.onAppear)
        .alert("Delete File", isPresented: $viewModel.isShowDeleteAlert) {
            Button("Delete", role: .destructive, action: viewModel.deleteFile)
        } message: {
            Text("Are you sure you want to delete this PDF file? This action cannot be undone.")
        }
        .alert("Clear History", isPresented: $viewModel.isShowDeleteHistoryAlert) {
            Button("Delete", role: .destructive, action: viewModel.cleanHistory)
        } message: {
            Text("Clear all files from history? This cannot be undone.")
        }
        .alert("Rename", isPresented: $viewModel.isShowRenameAlert) {
            TextField("File Name", text: $viewModel.currentName)
            Button("Cancel", action: { viewModel.isShowRenameAlert.toggle() })
            Button("Save", action: viewModel.renameFile)
        } message: {
            Text("Enter a new name for your PDF file.")
        }
        
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
        let filteredAndSortedItems = viewModel.sortItems()
            .filter { viewModel.searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(viewModel.searchText) }
        
        ScrollView {
            if filteredAndSortedItems.isEmpty {
                Text("No results found")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(filteredAndSortedItems, id: \.id) { item in
                    Button {
                        viewModel.selectCurrentURL(url: item.url)
                        pdfViverAction()
                    } label: {
                        HStack {
                            if let coverImage = item.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
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
                                
                                HStack {
                                    Text("\(item.pages) page,")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 15))
                                    
                                    Text(formattedFileSize(weight: item.weight))
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 15))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5)
                            
                            Button {
                                viewModel.selectCurrentURL(url: item.url)
                                viewModel.showingOptions = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(.black)
                                    .padding(.bottom, 30)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .confirmationDialog("", isPresented: $viewModel.showingOptions, titleVisibility: .hidden) {
                        Button("Rename") {
                            viewModel.activeRenameFile()
                        }
                        
                        Button("Share") {
                            viewModel.shareFile()
                        }
                        
                        Button("Duplicate") {
                            viewModel.createFileCopy()
                        }
                        
                        Button("Print") {
                            viewModel.printFile()
                        }
                        
                        Button(role: .destructive) {
                            viewModel.activeDeleteFile()
                        } label: {
                            Text("Delete")
                        }
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
            
            TextField(text: $viewModel.searchText) {
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
            sortedMenu()
            
            VStack {
                Text("History")
                    .bold()
                    .font(.title)
            }
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder
    private func sortedMenu() -> some View {
        Menu {
            Button("Unlock Premium", systemImage: "crown") {
                paywallAction()
            }
            
            Divider()
            
            Section("Sort by:") {
                Button("Date Added") {
                    viewModel.currentSortType = .byDateDescending
                }
                
                Button("Name") {
                    viewModel.currentSortType = .byName
                }
                
                Button("Size") {
                    viewModel.currentSortType = .bySizeAscending
                }
                
                Button("Page Count") {
                    viewModel.currentSortType = .byPageCount
                }
            }
            
            Divider()
            
            Button(role: .destructive) {
                viewModel.activeCleanHistory()
            } label: {
                Label("Clear History", systemImage: "trash")
            }
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .frame(width: 21, height: 21)
                .foregroundStyle(viewModel.pdfItems.isEmpty ? .white.opacity(0.5) : .white)
        }
        .menuStyle(DefaultMenuStyle())
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal)
        .disabled(viewModel.pdfItems.isEmpty)
    }
    
    private func formattedFileSize(weight: Int64) -> String {
        if weight < 1024 {
            return "\(weight) КБ"
        } else {
            let megabytes = Double(weight) / 1024
            return String(format: "%.2f МБ", megabytes)
        }
    }
}

#Preview {
    HistoryView(backAction: {}, pdfViverAction: {}, paywallAction: {})
}
