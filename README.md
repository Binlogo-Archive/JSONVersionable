# JSONVersionable

Using protocol to define a scheme version defined json migration process.

## Goal

- Type safe as possible.
- Flexiable migration process definition.
- Tests cover all version migrate combination.

## Example

Person v1:
```json
{
  "people" : [
    {
      "id" : "4E966EDD-893C-4F96-973A-949411B50149",
      "name" : "Fred Weasley"
    },
    {
      "id" : "4545A339-A09F-4AEE-BE46-1C4FCF6466AA",
      "name" : "George Weasley"
    }
  ],
  "schema_version" : 1
}
```

Person v2:
```json
{
  "people" : [
    {
      "id" : "4E966EDD-893C-4F96-973A-949411B50149",
      "first_name" : "Fred",
      "last_name" : "Weasley"
    },
    {
      "id" : "4545A339-A09F-4AEE-BE46-1C4FCF6466AA",
      "first_name" : "George",
      "last_name" : "Weasley"
    }
  ],
  "schema_version" : 2
}
```

### Migration

```swift
let origin = PersonFixtures.simpleV1
let v2Migration = PersonV2Migration()
let migration = JSONMigration(currentVersion: 2, versionMigrations: [v2Migration])
do {
    let migratedJSON = try migration.migration(origin: origin).json
} catch {
    print(error)
}
```

## Progress

MVP implementaion, but still WIP.

## Inspirations & Thanks

- [Migrating JSON File Schema Changes in Swift](https://mikezornek.com/posts/2020/9/migrating-json-file-schema-changes-in-swift/)
