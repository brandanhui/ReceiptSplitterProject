import Foundation

class ReceiptViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    
    init() {
        loadReceipts()
    }
    
    // Save receipts to lcoal storage
    func saveReceipts() {
        if let encoded = try? JSONEncoder().encode(receipts) {
            UserDefaults.standard.set(encoded, forKey: "receipts")
            print("Receipts saved: \(receipts.count)")  // Debug print
        } else {
            print("Failed to encode receipts.")  // Debug print
        }
    }
    
    // Load receipts from local storage
    func loadReceipts() {
        if let savedReceipts = UserDefaults.standard.data(forKey: "receipts"),
           let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: savedReceipts) {
            receipts = decodedReceipts
            print("Receipts loaded: \(receipts.count)")  // Debug print
        } else {
            print("No receipts found or failed to load.")  // Debug print
        }
    }
    
    func addReceipt(items: [Item], tax: Double, tip: Double, persons: [Person]) {
        let receipt = Receipt(items: items, taxPercentage: tax, tipPercentage: tip, persons: persons)
        receipts.append(receipt)
        saveReceipts()
    }
    
    func deleteReceipt(at index: IndexSet) {
        receipts.remove(atOffsets: index)
        saveReceipts()
    }
    
    func clearAllReceipts() {
        receipts.removeAll()
        saveReceipts()
    }
    
    func editReceipt(at index: Int, items: [Item], tax: Double, tip: Double, persons: [Person]) {
        receipts[index] = Receipt(items: items, taxPercentage: tax, tipPercentage: tip, persons: persons)
        saveReceipts()
    }
}
