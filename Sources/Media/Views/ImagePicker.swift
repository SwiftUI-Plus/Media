#if os(iOS)
import SwiftUI

public extension View {

    /// Presents the image picker when `isPresented` is `true`
    /// - Parameters:
    ///   - isPresented: A binding to the boolean that will trigger the presentation
    ///   - onComplete: When an image has been selected, this will be called with the resulting URL to the file or an error
    func imagePicker(isPresented: Binding<Bool>, onComplete: @escaping MediaCompletion) -> some View {
        background(ImagePickerView(isPresented: isPresented, onComplete: onComplete))
    }

}

private struct ImagePickerView: View {

    let isPresented: Binding<Bool>
    let completion: MediaCompletion

    init(isPresented: Binding<Bool>, onComplete: @escaping MediaCompletion) {
        self.isPresented = isPresented
        self.completion = onComplete
    }

    var body: some View {
        MediaView(isPresented: isPresented, source: .photoLibrary, completion: completion)
    }
}
#endif
