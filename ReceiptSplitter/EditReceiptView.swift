import SwiftUI

struct EditReceiptView: View {
    @Binding var receipt: Receipt
    @State private var items: [Item]
    @State private var taxPercentage: String
    @State private var tipPercentage: String
    @State private var newItemName: String = ""
    @State private var newItemPrice: String = ""
    @State private var personName: String = ""
    @State private var newPersonName: String = ""
    @Environment(\.presentationMode) var presentationMode
    var viewModel: ReceiptViewModel
    
    init(receipt: Binding<Receipt>, viewModel: ReceiptViewModel) {
        self._receipt = receipt
        self._items = State(initialValue: receipt.wrappedValue.items)
        self._taxPercentage = State(initialValue: String(receipt.wrappedValue.taxPercentage))
        self._tipPercentage = State(initialValue: String(receipt.wrappedValue.tipPercentage))
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            List {
                Section(header: Text("Items")) {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.name) - $ \(item.price, specifier: "%.2f")")
                                VStack(alignment: .leading) {
                                    ForEach(receipt.persons) { person in
                                        HStack {
                                            Image(systemName: item.assignedTo.contains(where: { $0.id == person.id }) ? "checkmark.circle.fill" : "circle")
                                                .onTapGesture {
                                                    togglePersonAssignment(person, for: item)
                                                }
                                            Text(person.name)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            // Trash icon to delete item
                            Button(action: {
                                deleteItem(item)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }

                    HStack {
                        TextField("Item Name", text: $newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Price", text: $newItemPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)

                        Button("Add Item") {
                            addItem()
                        }
                    }
                }

                Section(header: Text("Add Person")) {
                    HStack {
                        TextField("Person Name", text: $newPersonName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: addPerson) {
                            Text("Add Person")
                        }
                    }

                    ForEach(receipt.persons) { person in
                        HStack {
                            Text(person.name)
                            Spacer()
                            // Trash icon to delete person
                            Button(action: {
                                deletePerson(person)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }

                Section(header: Text("Tax and Tip")) {
                    TextField("Tax %", text: $taxPercentage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)

                    TextField("Tip %", text: $tipPercentage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }

            Button("Save Changes") {
                saveChanges()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .navigationTitle("Edit Receipt")
    }

    private func addItem() {
        guard let price = Double(newItemPrice), !newItemName.isEmpty else { return }
        let newItem = Item(name: newItemName, price: price)
        items.append(newItem)
        newItemName = ""
        newItemPrice = ""
    }

    private func addPerson() {
        guard !newPersonName.isEmpty else { return }
        let newPerson = Person(name: newPersonName)
        receipt.persons.append(newPerson)
        newPersonName = ""
    }

    private func togglePersonAssignment(_ person: Person, for item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].assignedTo.contains(where: { $0.id == person.id }) {
                items[index].assignedTo.removeAll { $0.id == person.id }
            } else {
                items[index].assignedTo.append(person)
            }
        }
    }

    private func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }

    private func deletePerson(_ person: Person) {
        receipt.persons.removeAll { $0.id == person.id }

        for itemIndex in items.indices {
            items[itemIndex].assignedTo.removeAll { $0.id == person.id }
        }
    }

    private func saveChanges() {
        if let tax = Double(taxPercentage), let tip = Double(tipPercentage) {
            receipt.items = items
            receipt.taxPercentage = tax
            receipt.tipPercentage = tip
            
            if let index = viewModel.receipts.firstIndex(where: { $0.id == receipt.id }) {
                viewModel.receipts[index] = receipt
                viewModel.saveReceipts()
            }

            presentationMode.wrappedValue.dismiss()
        }
    }
}
