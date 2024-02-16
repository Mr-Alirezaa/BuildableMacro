extension Collection where Element: Equatable {
    func contains<C: Collection>(anyOf collection: C) -> Bool where C.Element == Element {
        contains(where: collection.contains)
    }
}
