import AddressBook

let arguments = Process.arguments.dropFirst()
if arguments.isEmpty {
    fputs("No arguments given\n", stderr)
    exit(EXIT_FAILURE)
}

guard let addressBook = ABAddressBook.sharedAddressBook() else {
    fputs("Failed to initialize address book\n", stderr)
    exit(EXIT_FAILURE)
}

private func comparison(forProperty property: String, string: String) -> ABSearchElement {
    let comparison: ABSearchComparison = CFIndex(kABContainsSubStringCaseInsensitive.rawValue)
    return ABPerson.searchElementForProperty(property, label: nil, key: nil, value: string,
        comparison: comparison)
}

let searchString = arguments.joinWithSeparator(" ")
let firstNameSearch = comparison(forProperty: kABFirstNameProperty, string: searchString)
let lastNameSearch = comparison(forProperty: kABLastNameProperty, string: searchString)
let emailSearch = comparison(forProperty: kABEmailProperty, string: searchString)
let orComparison = ABSearchElement(forConjunction: CFIndex(kABSearchOr.rawValue),
    children: [firstNameSearch, lastNameSearch, emailSearch])

let found = addressBook.recordsMatchingSearchElement(orComparison) as? [ABRecord] ?? []
if found.count == 0 {
    exit(EXIT_SUCCESS)
}

print("NAME\tEMAIL")
for person in found {
    let firstName = person.valueForProperty(kABFirstNameProperty) as? String ?? ""
    let lastName = person.valueForProperty(kABLastNameProperty) as? String ?? ""
    let emailsProperty = person.valueForProperty(kABEmailProperty) as? ABMultiValue
    if let emails = emailsProperty {
        for i in 0..<emails.count() {
            let email = emails.valueAtIndex(i) as? String ?? ""
            print("\(email)\t\(firstName) \(lastName)")
        }
    }
}
