![ios](https://img.shields.io/badge/iOS-13-green)
![tv](https://img.shields.io/badge/tvOS-13-green)
![mac](https://img.shields.io/badge/macOS-10.15-green)

# Media

> Also available as a part of my [SwiftUI+ Collection](https://benkau.com/packages.json) – just add it to Xcode 13+

A package for simplifying the user of the camera and the user's photo library in SwiftUI.

## Features

-   Dynamic property wrappers for fetching media from the photo library
-   Camera modifier for easily taking a photo
-   ImagePicker modifier for allowing the user to pick a photo from their library

> Note: Permission requests and Info.plist values are not handled by this framework. You should use the standard UI to perform these actions as usual.

## Example

Fetch all asset collections of a given type and subtype:

```swift
// Its not necessary to `import Photos` as the framework does this for you.
import Media

struct AlbumsView: View {

    @FetchAssetCollection(album: .album, kind: .albumRegular)
    private var albums

    var body: some View {
        List(albums) { album in
            Text(album.localizedTitle ?? "")
        }
    }

}
```

For camera or image picker implementations:

```swift
@State private var takePhoto: Bool = false
@State private var chooseFromLibrary: Bool = false

var body: some View {
    VStack(spacing: 20) {
        Button {
            takePhoto = true
        } label: {
            Text("Take a photo")
        }
        .camera(isPresented: $takePhoto) { result in
            print(try! result.get())
        }

        Button {
            chooseFromLibrary = true
        } label: {
            Text("Choose from Library")
        }
        .imagePicker(isPresented: $chooseFromLibrary) { result in
            print(try! result.get())
        }
    }
}
```

## Inspiration

The property wrapper has heavily inspired by the new `FetchRequest` provided by SwiftUI. As such, it conforms to `RandomAccessCollection` allowing it to be used in all the same places, e.g. `List`, `ForEach`, etc...

This greatly simplifies the use of the photos framework library when integrating into a SwiftUI package.

Since the library is also a `dynamic` property, updates occuring in the users library are automatically tracked and reflecting in your SwiftUI views.

## Custom Queries

The property wrapper initializers provide various overrides to ensure you can customize the queries you need to perform.

In cases where a convenience initializer hasn't been provided, you can simply pass your own `PHFetchOptions` instance:

```swift
private static var options: PHFetchOptions = {
    let options = PHFetchOptions()
    options.predicate = ...
    return options
}()

@FetchAssetCollection(options)
private var custom
```

## Supports API

`PHAssetCollection`

```swift
@FetchAssetCollection(
    album: .smartAlbum,
    filter: NSPredicate(
        format: "NOT (assetCollectionSubtype IN %@)",
        [
            PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue,
            PHAssetCollectionSubtype.smartAlbumAllHidden.rawValue,
            PHAssetCollectionSubtype.smartAlbumFavorites.rawValue,
        ]
    )
) var albums
```

`PHCollectionList`

```swift
@FetchCollectionList(
    list: .smartFolder,
    kind: .any
) private var folders
```

`PHAsset`

```swift
// You can instantiate your results during init:
@FetchAssetList
private var assets: MediaResults<PHAsset>

// Or, if you already have a set of results from a `PHFetchResult<PHAsset>` instance:
@FetchAssetList(results)
private var assets

// Alternatively, if you have a `PHAssetCollection` instance:
@FetchAssetList(in: collection)
private var assets
```

There are multiple overrides for all of the above to allow for most customizations, alternatively you can pass a `PHFetchOptions` instance yourself as mentioned above.

## Exclusions

The primary purpose of this library is to simplify the usage of the `Photos` framework in SwiftUI applications. As such, permission requests and mutations are not included.

Those APIs are not an issue that needs fixing by this library.

Instead you should continue to use the existing APIs available via the `Photos` framework. Since the use of `Photos` types is required, the library automatically imports `Photos` for you so adding an additional import is redundant.

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/SwiftUI-Plus/Media.git", .upToNextMinor(from: "1.0.0"))`

> Note: The package requires iOS v13+

## Other Packages

If you want easy access to this and more packages, add the following collection to your Xcode 13+ configuration:

`https://benkau.com/packages.json`
