@_exported import Photos
import SwiftUI

extension PHObject: Identifiable {
    public var id: String { localIdentifier }
}
