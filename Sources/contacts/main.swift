import AddressBook

let arguments = CommandLine.arguments.dropFirst()
if arguments.isEmpty {
    fputs("No arguments given\n", stderr)
    exit(EXIT_FAILURE)
}

guard let addressBook = ABAddressBook.shared() else {
    fputs("Failed to create address book (check your Contacts privacy settings)\n", stderr)
    exit(EXIT_FAILURE)
}

private func comparison(forProperty property: String, string: String) -> ABSearchElement {
    let comparison: ABSearchComparison = CFIndex(kABContainsSubStringCaseInsensitive.rawValue)
    return ABPerson.searchElement(forProperty: property, label: nil, key: nil, value: string,
        comparison: comparison)
}

let searchString = arguments.joined(separator: " ")
let firstNameSearch = comparison(forProperty: kABFirstNameProperty, string: searchString)
let lastNameSearch = comparison(forProperty: kABLastNameProperty, string: searchString)
let emailSearch = comparison(forProperty: kABEmailProperty, string: searchString)
let orComparison = ABSearchElement(forConjunction: CFIndex(kABSearchOr.rawValue),
    children: [firstNameSearch, lastNameSearch, emailSearch])

let found = addressBook.records(matching: orComparison) as? [ABRecord] ?? []
if found.count == 0 {
    exit(EXIT_SUCCESS)
}

print("NAME\tEMAIL")
for person in found {
    let firstName = person.value(forProperty: kABFirstNameProperty) as? String ?? ""
    let lastName = person.value(forProperty: kABLastNameProperty) as? String ?? ""
    let emailsProperty = person.value(forProperty: kABEmailProperty) as? ABMultiValue
    if let emails = emailsProperty {
        for i in 0..<emails.count() {
            let email = emails.value(at: i) as? String ?? ""
            print("\(email)\t\(firstName) \(lastName)")
        }
    }
}
