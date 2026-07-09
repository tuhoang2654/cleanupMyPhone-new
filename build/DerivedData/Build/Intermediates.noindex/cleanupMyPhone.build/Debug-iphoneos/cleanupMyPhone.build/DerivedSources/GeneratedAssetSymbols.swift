import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
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

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "app_icon" asset catalog image resource.
    static let appIcon = ImageResource(name: "app_icon", bundle: resourceBundle)

    /// The "arrow-left" asset catalog image resource.
    static let arrowLeft = ImageResource(name: "arrow-left", bundle: resourceBundle)

    /// The "ic_china" asset catalog image resource.
    static let icChina = ImageResource(name: "ic_china", bundle: resourceBundle)

    /// The "ic_done_disable" asset catalog image resource.
    static let icDoneDisable = ImageResource(name: "ic_done_disable", bundle: resourceBundle)

    /// The "ic_done_enable" asset catalog image resource.
    static let icDoneEnable = ImageResource(name: "ic_done_enable", bundle: resourceBundle)

    /// The "ic_english" asset catalog image resource.
    static let icEnglish = ImageResource(name: "ic_english", bundle: resourceBundle)

    /// The "ic_france" asset catalog image resource.
    static let icFrance = ImageResource(name: "ic_france", bundle: resourceBundle)

    /// The "ic_germany" asset catalog image resource.
    static let icGermany = ImageResource(name: "ic_germany", bundle: resourceBundle)

    /// The "ic_hindi" asset catalog image resource.
    static let icHindi = ImageResource(name: "ic_hindi", bundle: resourceBundle)

    /// The "ic_indonesia" asset catalog image resource.
    static let icIndonesia = ImageResource(name: "ic_indonesia", bundle: resourceBundle)

    /// The "ic_intro1" asset catalog image resource.
    static let icIntro1 = ImageResource(name: "ic_intro1", bundle: resourceBundle)

    /// The "ic_intro2" asset catalog image resource.
    static let icIntro2 = ImageResource(name: "ic_intro2", bundle: resourceBundle)

    /// The "ic_intro3" asset catalog image resource.
    static let icIntro3 = ImageResource(name: "ic_intro3", bundle: resourceBundle)

    /// The "ic_radio_normal" asset catalog image resource.
    static let icRadioNormal = ImageResource(name: "ic_radio_normal", bundle: resourceBundle)

    /// The "ic_radio_selected" asset catalog image resource.
    static let icRadioSelected = ImageResource(name: "ic_radio_selected", bundle: resourceBundle)

    /// The "ic_rate0" asset catalog image resource.
    static let icRate0 = ImageResource(name: "ic_rate0", bundle: resourceBundle)

    /// The "ic_rate1" asset catalog image resource.
    static let icRate1 = ImageResource(name: "ic_rate1", bundle: resourceBundle)

    /// The "ic_rate2" asset catalog image resource.
    static let icRate2 = ImageResource(name: "ic_rate2", bundle: resourceBundle)

    /// The "ic_rate3" asset catalog image resource.
    static let icRate3 = ImageResource(name: "ic_rate3", bundle: resourceBundle)

    /// The "ic_rate4" asset catalog image resource.
    static let icRate4 = ImageResource(name: "ic_rate4", bundle: resourceBundle)

    /// The "ic_rate5" asset catalog image resource.
    static let icRate5 = ImageResource(name: "ic_rate5", bundle: resourceBundle)

    /// The "ic_rate_check" asset catalog image resource.
    static let icRateCheck = ImageResource(name: "ic_rate_check", bundle: resourceBundle)

    /// The "ic_rate_uncheck" asset catalog image resource.
    static let icRateUncheck = ImageResource(name: "ic_rate_uncheck", bundle: resourceBundle)

    /// The "ic_setting_arrow_right" asset catalog image resource.
    static let icSettingArrowRight = ImageResource(name: "ic_setting_arrow_right", bundle: resourceBundle)

    /// The "ic_setting_lang" asset catalog image resource.
    static let icSettingLang = ImageResource(name: "ic_setting_lang", bundle: resourceBundle)

    /// The "ic_setting_privacy" asset catalog image resource.
    static let icSettingPrivacy = ImageResource(name: "ic_setting_privacy", bundle: resourceBundle)

    /// The "ic_setting_rate" asset catalog image resource.
    static let icSettingRate = ImageResource(name: "ic_setting_rate", bundle: resourceBundle)

    /// The "ic_setting_share" asset catalog image resource.
    static let icSettingShare = ImageResource(name: "ic_setting_share", bundle: resourceBundle)

    /// The "ic_setting_term" asset catalog image resource.
    static let icSettingTerm = ImageResource(name: "ic_setting_term", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif