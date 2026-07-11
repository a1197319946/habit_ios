import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "app_logo" asset catalog image resource.
    static let appLogo = DeveloperToolsSupport.ImageResource(name: "app_logo", bundle: resourceBundle)

    /// The "bunny_success" asset catalog image resource.
    static let bunnySuccess = DeveloperToolsSupport.ImageResource(name: "bunny_success", bundle: resourceBundle)

    /// The "header_bg" asset catalog image resource.
    static let headerBg = DeveloperToolsSupport.ImageResource(name: "header_bg", bundle: resourceBundle)

    /// The "launch_bg" asset catalog image resource.
    static let launchBg = DeveloperToolsSupport.ImageResource(name: "launch_bg", bundle: resourceBundle)

    /// The "native_launch" asset catalog image resource.
    static let nativeLaunch = DeveloperToolsSupport.ImageResource(name: "native_launch", bundle: resourceBundle)

    /// The "native_launch_v2" asset catalog image resource.
    static let nativeLaunchV2 = DeveloperToolsSupport.ImageResource(name: "native_launch_v2", bundle: resourceBundle)

    /// The "poster_bg" asset catalog image resource.
    static let posterBg = DeveloperToolsSupport.ImageResource(name: "poster_bg", bundle: resourceBundle)

    /// The "scancode" asset catalog image resource.
    static let scancode = DeveloperToolsSupport.ImageResource(name: "scancode", bundle: resourceBundle)

}

