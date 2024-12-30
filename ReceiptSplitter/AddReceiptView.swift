import SwiftUI

struct AddReceiptView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ReceiptViewModel
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var items: [Item] = []
    @State private var taxPercentage: String = "9.625"
    @State private var tipPercentage: String = "15.0"
    @State private var showToast = false
    @State private var personName = ""
    @State private var persons: [Person] = []

    var body: some View {
        VStack {
            List {
                Section(header: Text("Items")) {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.name) - \(item.price, specifier: "%.2f")")
                                VStack(alignment: .leading) {
                                    ForEach(persons) { person in
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
                            Button(action: {
                                deleteItem(id: item.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    HStack {
                        TextField("Item Name", text: $itemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Price", text: $itemPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)

                        Button("Add Item") {
                            addItem()
                        }
                    }
                }

                Section(header: Text("Add Person")) {
                    HStack {
                        TextField("Person Name", text: $personName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: addPerson) {
                            Text("Add Person")
                        }
                    }

                    ForEach(persons) { person in
                        HStack {
                            Text(person.name)
                            Spacer()
                            Button(action: {
                                deletePerson(id: person.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }

            HStack {
                TextField("Tax %", text: $taxPercentage)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Tip %", text: $tipPercentage)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Button("Save Receipt") {
                saveReceipt()
            }
            .padding()
        }
        .overlay(
            Group {
                if showToast {
                    Text("Receipt Successfully Saved")
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showToast)
                        .padding(.bottom, 50)
                }
            },
            alignment: .bottom
        )
        .navigationTitle("Add Receipt")
    }

    func addPerson() {
        let newPerson = Person(name: personName)
        persons.append(newPerson)
        personName = ""
    }

    func addItem() {
        guard let price = Double(itemPrice), !itemName.isEmpty else { return }
        let newItem = Item(name: itemName, price: price)
        items.append(newItem)
        itemName = ""
        itemPrice = ""
    }

    func deleteItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    func deletePerson(id: UUID) {
        persons.removeAll { $0.id == id }
        for itemIndex in items.indices {
            items[itemIndex].assignedTo.removeAll { $0.id == id }
        }
    }

    func togglePersonAssignment(_ person: Person, for item: Item) {
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
            var itemToUpdate = items[itemIndex]

            if itemToUpdate.assignedTo.contains(where: { $0.id == person.id }) {
                itemToUpdate.assignedTo.removeAll { $0.id == person.id }
            } else {
                itemToUpdate.assignedTo.append(person)
            }

            items[itemIndex] = itemToUpdate
        }
    }

    func saveReceipt() {
        guard let tax = Double(taxPercentage), let tip = Double(tipPercentage) else { return }
        viewModel.addReceipt(items: items, tax: tax, tip: tip, persons: persons)
        showToastMessage()
    }

    func showToastMessage() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}
