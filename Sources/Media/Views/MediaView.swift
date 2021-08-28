import SwiftUI
import CoreServices
import Photos

public typealias MediaCompletion = (Result<URL, Error>) -> Void

public enum MediaError: LocalizedError {
    case imageNotAvailable
    case urlMissing

    public var errorDescription: String? {
        switch self {
        case .imageNotAvailable:
            return NSLocalizedString("The original image was not available", comment: "")
        case .urlMissing:
            return NSLocalizedString("The URL was missing", comment: "")
        }
    }
}

internal struct MediaView: UIViewControllerRepresentable {

    @Binding var isPresented: Bool
    let source: UIImagePickerController.SourceType
    let completion: MediaCompletion

    func makeUIViewController(context: Context) -> CameraWrapper {
        CameraWrapper(isPresented: $isPresented, source: source, completion: completion)
    }

    func updateUIViewController(_ controller: CameraWrapper, context: Context) {
        controller.isPresented = $isPresented
        controller.source = source
        controller.completion = completion
        controller.updateState()
    }

}

final class CameraWrapper: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    fileprivate var isPresented: Binding<Bool>
    fileprivate var source: UIImagePickerController.SourceType
    fileprivate var completion: MediaCompletion

    init(isPresented: Binding<Bool>, source: UIImagePickerController.SourceType, completion: @escaping MediaCompletion) {
        self.isPresented = isPresented
        self.source = source
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    func updateState() {
        let isAlreadyPresented = presentedViewController != nil

        if isAlreadyPresented != isPresented.wrappedValue {
            if !isAlreadyPresented {
                let controller = UIImagePickerController()

                controller.sourceType = source
                controller.mediaTypes = [String(kUTTypeImage)]
                controller.imageExportPreset = .compatible

                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isPresented.wrappedValue = false
        picker.presentingViewController?.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            complete(with: .failure(MediaError.imageNotAvailable), picker: picker)
            return
        }

        DispatchQueue.global().async { [weak self] in
            do {
                let url = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")

                let data = image.jpegData(compressionQuality: 1)
                try data?.write(to: url)

                self?.complete(with: .success(url), picker: picker)
            } catch {
                self?.complete(with: .failure(error), picker: picker)
            }
        }
    }

    private func complete(with result: Result<URL, Error>, picker: UIImagePickerController) {
        DispatchQueue.main.async {
            self.isPresented.wrappedValue = false
            picker.presentingViewController?.dismiss(animated: true) {
                self.completion(result)
            }
        }
    }

}
