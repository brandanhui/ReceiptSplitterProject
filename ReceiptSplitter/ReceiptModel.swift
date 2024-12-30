import Foundation

// Model for a person
struct Person: Identifiable, Codable {
    var id = UUID()
    var name: String
    var total: Double = 0.0  // Total amount assigned to this person
}

// Model for an item
struct Item: Identifiable, Codable {
    var id = UUID()
    var name: String
    var price: Double
    var assignedTo: [Person] = []  // List of people this item is assigned to
}

// Model for a receipt
struct Receipt: Identifiable, Codable {
    var id = UUID()
    var items: [Item]
    var taxPercentage: Double
    var tipPercentage: Double
    var persons: [Person]  // List of persons involved in the receipt
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    var taxAmount: Double {
        subtotal * (taxPercentage / 100)
    }
    
    var tipAmount: Double {
        subtotal * (tipPercentage / 100)
    }
    
    var totalWithTax: Double {
        subtotal + taxAmount
    }
    
    var totalWithTaxAndTip: Double {
        totalWithTax + tipAmount
    }
    
    var totalPerPerson: [Person] {
        var totals = persons.map { person in
            var personCopy = person
            personCopy.total = 0.0
            return personCopy
        }
        
        for item in items {
            // Even split if no persons assigned
            if item.assignedTo.isEmpty {
                let splitAmount = item.price / Double(persons.count)
                for index in totals.indices {
                    totals[index].total += splitAmount
                }
            } else {
                // Split among assigned people
                let splitAmount = item.price / Double(item.assignedTo.count)
                for person in item.assignedTo {
                    if let index = totals.firstIndex(where: { $0.id == person.id }) {
                        totals[index].total += splitAmount
                    }
                }
            }
        }
        
        return totals
    }

}
