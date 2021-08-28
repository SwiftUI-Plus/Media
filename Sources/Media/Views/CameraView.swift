import SwiftUI

public extension View {

    /// Presents the camera when `isPresented` is `true`
    /// - Parameters:
    ///   - isPresented: A binding to the boolean that will trigger the presentation
    ///   - onComplete: When the photo has been taken, this will be called with the resulting URL to the file or an error
    func camera(isPresented: Binding<Bool>, onComplete: @escaping MediaCompletion) -> some View {
        background(CameraView(isPresented: isPresented, onComplete: onComplete))
    }

}

private struct CameraView: View {

    let isPresented: Binding<Bool>
    let completion: MediaCompletion

    init(isPresented: Binding<Bool>, onComplete: @escaping MediaCompletion) {
        self.isPresented = isPresented
        self.completion = onComplete
    }

    var body: some View {
        MediaView(isPresented: isPresented, source: .camera, completion: completion)
    }
}
