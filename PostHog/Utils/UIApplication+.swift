//
//  UIApplication+.swift
//  PostHog
//
//  Created by Yiannis Josephides on 11/11/2024.
//

#if os(iOS) || os(tvOS) || os(visionOS)
    import UIKit

    extension UIApplication {
        static func getCurrentWindow(filterForegrounded: Bool = true) -> UIWindow? {
            // UIWindowScene / connectedScenes require iOS 13+.
            // Fall back to keyWindow on iOS 12 — surveys/autocapture are no-ops there anyway.
            guard #available(iOS 13.0, tvOS 13.0, *) else {
                return UIApplication.shared.keyWindow
            }

            let windowScenes = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter {
                    !filterForegrounded || $0.activationState == .foregroundActive
                }

            for scene in windowScenes {
                // attempt to retrieve directly from UIWindowScene
                if #available(iOS 15.0, tvOS 15.0, *) {
                    if let keyWindow = scene.keyWindow {
                        return keyWindow
                    }
                } else {
                    // check scene.windows.isKeyWindow
                    for window in scene.windows where window.isKeyWindow {
                        return window
                    }
                }

                // check scene.delegate.window property
                let sceneDelegate = scene.delegate as? UIWindowSceneDelegate
                if let target = sceneDelegate, let window = target.window {
                    return window
                }
            }

            return nil
        }
    }
#endif
