import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let group = DispatchGroup()
            var selectedImages = [UIImage]()

            for result in results {
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }

                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }

                    if let image = object as? UIImage {
                        selectedImages.append(image)
                    }
                }
            }

            group.notify(queue: .main) {
                self.parent.images = selectedImages
            }
        }
    }
}
