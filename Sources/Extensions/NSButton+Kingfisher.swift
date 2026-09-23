//
//  NSButton+Kingfisher.swift
//  Kingfisher
//
//  Created by Jie Zhang on 14/04/2016.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

@MainActor
extension KingfisherWrapper where Base: NSButton {

    // MARK: Setting Image

    /// Sets an image to the button with a ``Source``.
    ///
    /// - Parameters:
    ///   - source: The ``Source`` object that defines data information from the network or a data provider.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `source`.
    ///   - options: A set of options to define image setting behaviors. See ``KingfisherOptionsInfo`` for more.
    ///   - progressBlock: Called when the image downloading progress is updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieval and setting are finished.
    /// - Returns: A task that represents the image downloading.
    ///
    /// Internally, this method will use ``KingfisherManager`` to get the source. Since this method will perform UI
    ///  changes, it is your responsibility to call it from the main thread.
    ///
    /// > Both `progressBlock` and `completionHandler` will also be executed in the main thread.
    @discardableResult
    public func setImage(
        with source: Source?,
        placeholder: KFCrossPlatformImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask?
    {
        let options = KingfisherParsedOptionsInfo(KingfisherManager.shared.defaultOptions + (options ?? .empty))
        return setImage(
            with: source,
            placeholder: placeholder,
            parsedOptions: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }

    func setImage(
        with source: Source?,
        placeholder: KFCrossPlatformImage? = nil,
        parsedOptions: KingfisherParsedOptionsInfo,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask?
    {
        return setImage(
            with: source,
            imageAccessor: ImagePropertyAccessor(
                getImage: { button in
                    button.image
                },
                setImage: { button, image, _ in
                    button.image = image
                }
            ),
            taskAccessor: TaskPropertyAccessor(
                setTask: { wrapper, task in
                    wrapper.imageTask = task
                },
                getTaskIdentifier: { wrapper in
                    wrapper.imageTaskIdentifier
                },
                setTaskIdentifier: { wrapper, identifier in
                    wrapper.imageTaskIdentifier = identifier
                },
                getCancellationToken: { wrapper in
                    wrapper.imageCancellationToken
                },
                setCancellationToken: { wrapper, token in
                    wrapper.imageCancellationToken = token
                }
            ),
            placeholder: placeholder,
            parsedOptions: parsedOptions,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }

    // MARK: Cancelling Downloading Task

    /// Cancels the image download task of the button if it is running.
    /// Nothing will happen if the downloading has already finished.
    public func cancelImageDownloadTask() {
        imageTask?.cancel()
        imageCancellationToken?.cancel()
    }

    // MARK: Setting Alternate Image

    @discardableResult
    public func setAlternateImage(
        with source: Source?,
        placeholder: KFCrossPlatformImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask?
    {
        let options = KingfisherParsedOptionsInfo(KingfisherManager.shared.defaultOptions + (options ?? .empty))
        return setAlternateImage(
            with: source,
            placeholder: placeholder,
            parsedOptions: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }

    func setAlternateImage(
        with source: Source?,
        placeholder: KFCrossPlatformImage? = nil,
        parsedOptions: KingfisherParsedOptionsInfo,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask?
    {
        return setImage(
            with: source,
            imageAccessor: ImagePropertyAccessor(
                getImage: { button in
                    button.alternateImage
                },
                setImage: { button, image, _ in
                    button.alternateImage = image
                }
            ),
            taskAccessor: TaskPropertyAccessor(
                setTask: { wrapper, task in
                    wrapper.alternateImageTask = task
                },
                getTaskIdentifier: { wrapper in
                    wrapper.alternateImageTaskIdentifier
                },
                setTaskIdentifier: { wrapper, identifier in
                    wrapper.alternateImageTaskIdentifier = identifier
                },
                getCancellationToken: { wrapper in
                    wrapper.alternateImageCancellationToken
                },
                setCancellationToken: { wrapper, token in
                    wrapper.alternateImageCancellationToken = token
                }
            ),
            placeholder: placeholder,
            parsedOptions: parsedOptions,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }

    // MARK: Cancelling Alternate Image Downloading Task

    /// Cancels the image download task of the image view if it is running.
    ///
    /// Nothing will happen if the downloading has already finished.
    public func cancelAlternateImageDownloadTask() {
        alternateImageTask?.cancel()
        alternateImageCancellationToken?.cancel()
    }
}


// MARK: - Associated Object
@MainActor private var imageTaskKey: Void?
@MainActor private var imageTaskIdentifierKey: Void?
@MainActor private var imageCancellationTokenKey: Void?

@MainActor private var alternateImageTaskKey: Void?
@MainActor private var alternateImageTaskIdentifierKey: Void?
@MainActor private var alternateImageCancellationTokenKey: Void?

@MainActor
extension KingfisherWrapper where Base: NSButton {

    // MARK: Properties
    private var imageTask: DownloadTask? {
      get { return getAssociatedObject(base, &imageTaskKey) }
      nonmutating set { setRetainedAssociatedObject(base, &imageTaskKey, newValue)}
    }

    public private(set) var imageTaskIdentifier: Source.Identifier.Value? {
        get {
            let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &imageTaskIdentifierKey)
            return box?.value
        }
        nonmutating set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(base, &imageTaskIdentifierKey, box)
        }
    }

    private var imageCancellationToken: CancellationToken? {
        get { getAssociatedObject(base, &imageCancellationTokenKey) }
        nonmutating set { setRetainedAssociatedObject(base, &imageCancellationTokenKey, newValue) }
    }

    private var alternateImageTask: DownloadTask? {
        get { return getAssociatedObject(base, &alternateImageTaskKey) }
        nonmutating set { setRetainedAssociatedObject(base, &alternateImageTaskKey, newValue)}
    }

    public private(set) var alternateImageTaskIdentifier: Source.Identifier.Value? {
        get {
            let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &alternateImageTaskIdentifierKey)
            return box?.value
        }
        nonmutating set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(base, &alternateImageTaskIdentifierKey, box)
        }
    }

    private var alternateImageCancellationToken: CancellationToken? {
        get { getAssociatedObject(base, &alternateImageCancellationTokenKey) }
        nonmutating set { setRetainedAssociatedObject(base, &alternateImageCancellationTokenKey, newValue) }
    }
}
#endif
