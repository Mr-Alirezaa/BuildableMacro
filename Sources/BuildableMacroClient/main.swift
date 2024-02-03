import Foundation
import BuildableMacro

@Buildable
struct Person {
    var name: String

    @BuildableTracked(name: "setLastName")
    var lastName: String

    @BuildableIgnored
    var age: Int

    var onChange: () -> Void = {}
}

let person = Person(name: "Alireza", lastName: "Asadi", age: 27)

let otherPerson = person
    .name("Mammad")
    .setLastName("Gholam")

print(otherPerson.name, otherPerson.lastName)
