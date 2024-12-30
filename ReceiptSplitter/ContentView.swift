import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ReceiptViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                //Show list of receipts
                List {
                    ForEach(viewModel.receipts) { receipt in
                        NavigationLink(destination: ReceiptDetailView(receipt: $viewModel.receipts[viewModel.receipts.firstIndex(where: { $0.id == receipt.id })!], viewModel: viewModel)) {
                            Text("Receipt - $ \(receipt.totalWithTaxAndTip, specifier: "%.2f")")
                        }
                    }
                    .onDelete(perform: viewModel.deleteReceipt)
                }
                
                // Nav to AddReceiptView
                NavigationLink(destination: AddReceiptView(viewModel: viewModel)) {
                    Text("Add New Receipt")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .navigationTitle("Receipts")
            .navigationBarItems(trailing: Button(action: {
                // Clear all receipts
                //TODO: Add individual deletes
                viewModel.clearAllReceipts()
            }) {
                Text("Clear All")
            })
            .onAppear {
                //Load previous receipts if available
                viewModel.loadReceipts()
            }
        }
    }
}
