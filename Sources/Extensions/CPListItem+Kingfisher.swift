
//
//  CPListItem+Kingfisher.swift
//  Kingfisher
//
//  Created by Wayne Hartman on 2021-08-29.
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

#if canImport(CarPlay) && !targetEnvironment(macCatalyst)
import CarPlay

@MainActor
extension KingfisherWrapper where Base: CPListItem {
    
    // MARK: Setting Image
    
    /// Sets an image to the image view with a source.
    ///
    /// - Parameters:
    ///   - source: The `Source` object contains information about the image.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `KingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    ///
    /// Internally, this method will use `KingfisherManager` to get the requested source
    /// Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
    public func setImage(
        with source: Source?,
        placeholder: KFCrossPlatformImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        let options = KingfisherParsedOptionsInfo(KingfisherManager.shared.defaultOptions + (options ?? []))
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
        completionHandler: (@MainActor @Sendable (Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: source,
            imageAccessor: ImagePropertyAccessor(
                getImage: { listItem in
                    listItem.image
                },
                setImage: { listItem, image, _ in
                    listItem.setImage(image)
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
    
    // MARK: Cancelling Image
    
    /// Cancel the image download task bounded to the image view if it is running.
    /// Nothing will happen if the downloading has already finished.
    public func cancelImageDownloadTask() {
        imageTask?.cancel()
        imageCancellationToken?.cancel()
    }
}

@MainActor private var imageTaskKey: Void?
@MainActor private var imageTaskIdentifierKey: Void?
@MainActor private var imageCancellationTokenKey: Void?

// MARK: Properties
@MainActor
extension KingfisherWrapper where Base: CPListItem {

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

    var imageCancellationToken: CancellationToken? {
        get { getAssociatedObject(base, &imageCancellationTokenKey) }
        nonmutating set { setRetainedAssociatedObject(base, &imageCancellationTokenKey, newValue) }
    }
}
#endif
