import AddressBook
import ArgumentParser

enum OutputType: String, CaseIterable, ExpressibleByArgument {
    case csv, json
}

enum SearchFieldType: String, CaseIterable, ExpressibleByArgument {
    case fullName, firstName, lastName, email, all
}

@main
struct ContactsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A daemon process which helps you focus on your work."
    )

    @Flag(help: "Print out the version of the application.")
    var version = false

    @Argument(help: "The query input")
    var searchString: String

    @Option
    var outputType: OutputType = .csv

    @Option
    var searchField: SearchFieldType = .all

    mutating func run() throws {
        if version {
            // we cannot get the latest tag version at compile time
            // https://stackoverflow.com/questions/27804227/using-compiler-variables-in-swift
            print("v1.1")
            return
        }

        guard let addressBook = ABAddressBook.shared() else {
            fputs("Failed to create address book (check your Contacts privacy settings)\n", stderr)
            ContactsCommand.exit(withError: ExitCode.failure)
        }

        var searchComparison: ABSearchElement

        switch searchField {
        case .all:
            // search fn, ln, and email fields for the search input
            searchComparison = ABSearchElement(
                forConjunction: CFIndex(kABSearchOr.rawValue),
                children: [
                    comparison(forProperty: kABFirstNameProperty, string: searchString),
                    comparison(forProperty: kABLastNameProperty, string: searchString),
                    comparison(forProperty: kABEmailProperty, string: searchString),
                ]
            )
        case .fullName:
            let nameParts = searchString.split(separator: " ", maxSplits: 1)
            let firstName = nameParts.count > 0 ? String(nameParts[0]) : ""
            let lastName = nameParts.count > 1 ? String(nameParts[1]) : ""
            searchComparison = ABSearchElement(
                forConjunction: CFIndex(kABSearchAnd.rawValue),
                children: [
                    comparison(forProperty: kABFirstNameProperty, string: firstName),
                    comparison(forProperty: kABLastNameProperty, string: lastName),
                ]
            )
        case .firstName:
            searchComparison = ABSearchElement(
                forConjunction: CFIndex(kABSearchAnd.rawValue),
                children: [
                    comparison(forProperty: kABFirstNameProperty, string: searchString),
                ]
            )
        case .lastName:
            searchComparison = ABSearchElement(
                forConjunction: CFIndex(kABSearchAnd.rawValue),
                children: [
                    comparison(forProperty: kABLastNameProperty, string: searchString),
                ]
            )
        case .email:
            searchComparison = ABSearchElement(
                forConjunction: CFIndex(kABSearchAnd.rawValue),
                children: [
                    comparison(forProperty: kABEmailProperty, string: searchString),
                ]
            )
        }

        let found = addressBook.records(matching: searchComparison) as? [ABRecord] ?? []

        if found.count == 0 {
            fputs("No contacts found\n", stderr)
            ContactsCommand.exit(withError: ExitCode.failure)
        }

        var results: [[String: String]] = []

        for person in found {
            let firstName = person.value(forProperty: kABFirstNameProperty) as? String ?? ""
            let lastName = person.value(forProperty: kABLastNameProperty) as? String ?? ""

            let emailsProperty = person.value(forProperty: kABEmailProperty) as? ABMultiValue

            // TODO: think of a better way to handle multiple phones
            // although there can be more than a single phone number, we'll assume there can only be one for now
            let phonesProperty = person.value(forProperty: kABPhoneProperty) as? ABMultiValue
            let phone = phonesProperty?.value(at: 0) as? String ?? ""

            if let emails = emailsProperty {
                for i in 0 ..< emails.count() {
                    let email = emails.value(at: i) as? String ?? ""
                    let result: [String: String] = [
                        "firstName": firstName,
                        "lastName": lastName,
                        "fullName": "\(firstName) \(lastName)",
                        "email": email,
                        "phone": phone,
                    ]
                    results.append(result)
                }
            } else {
                let result: [String: String] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "fullName": "\(firstName) \(lastName)",
                    "email": "",
                    "phone": phone,
                ]
                results.append(result)
            }
        }

        renderOuput(rows: results, outputType: outputType)
    }
}

func renderOuput(rows: [[String: String]], outputType: OutputType) {
    if outputType == .csv {
        print(renderCSV(rows))
        return
    }

    let jsonData = try? JSONSerialization.data(withJSONObject: rows, options: .prettyPrinted)
    let jsonString = String(data: jsonData!, encoding: .utf8)
    print(jsonString!)
}

func renderCSV(_ rows: [[String: String]]) -> String {
    guard let firstRow = rows.first else {
        return ""
    }

    let header = firstRow.keys.joined(separator: ",")
    let values = rows.map { row in
        row.values.joined(separator: ",")
    }.joined(separator: "\n")

    return header + "\n" + values
}

private func comparison(forProperty property: String, string: String) -> ABSearchElement {
    let comparison: ABSearchComparison = CFIndex(kABContainsSubStringCaseInsensitive.rawValue)
    return ABPerson.searchElement(forProperty: property, label: nil, key: nil, value: string,
                                  comparison: comparison)
}
