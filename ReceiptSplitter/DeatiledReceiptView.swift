import SwiftUI

struct ReceiptDetailView: View {
    @State private var isEditing = false
    @Binding var receipt: Receipt
    var viewModel: ReceiptViewModel

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Items")) {
                        ForEach(receipt.items) { item in
                            Text("\(item.name) - $ \(item.price, specifier: "%.2f")")
                        }
                    }
                    
                    Section(header: Text("Summary")) {
                        Text("Subtotal: $ \(receipt.subtotal, specifier: "%.2f")")
                        Text("Tax: $ \(receipt.taxAmount, specifier: "%.2f")")
                        Text("Tip: $ \(receipt.tipAmount, specifier: "%.2f")")
                        Text("Total (with tax): $ \(receipt.totalWithTax, specifier: "%.2f")")
                        Text("Total (with tax and tip): $ \(receipt.totalWithTaxAndTip, specifier: "%.2f")")
                    }
                    
                    Section(header: Text("Persons")) {
                        ForEach(receipt.totalPerPerson) { person in
                            VStack(alignment: .leading) {
                                Text("\(person.name):")
                                Text("  Subtotal: $\(person.total, specifier: "%.2f")")
                                Text("  Total with Tax: $\(person.total + receipt.taxAmount / Double(receipt.persons.count), specifier: "%.2f")")
                                Text("  Total with Tip and Tax: $\(person.total + receipt.taxAmount / Double(receipt.persons.count) + receipt.tipAmount / Double(receipt.persons.count), specifier: "%.2f")")
                            }
                        }
                    }
                }
                
                Button("Edit Receipt") {
                    isEditing = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Receipt Details")
            .navigationDestination(isPresented: $isEditing) {
                EditReceiptView(receipt: $receipt, viewModel: viewModel)
            }
        }
    }
}
