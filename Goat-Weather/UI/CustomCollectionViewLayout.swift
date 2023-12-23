/// Copyright (c) 2023 Yefga.com
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

/// An animator that turns the cells into card mode.
/// - warning: You need to set `clipsToBounds` to `false` on the cell to make
/// this effective.
public struct LinearCardAttributesAnimator: LayoutAttributesAnimator {
    /// The alpha to apply on the cells that are away from the center. Should be
    /// in range [0, 1]. 0.5 by default.
    public var minAlpha: CGFloat
    
    /// The spacing ratio between two cells. 0.4 by default.
    public var itemSpacing: CGFloat
    
    /// The scale rate that will applied to the cells to make it into a card.
    public var scaleRate: CGFloat
    
    public init(minAlpha: CGFloat = 0.5, 
                itemSpacing: CGFloat = 0.4,
                scaleRate: CGFloat = 0.7) {
        self.minAlpha = minAlpha
        self.itemSpacing = itemSpacing
        self.scaleRate = scaleRate
    }
    
    public func animate(collectionView: UICollectionView, 
                        attributes: AnimatedCollectionViewLayoutAttributes) {
        let position = attributes.middleOffset
        let scaleFactor = scaleRate - 0.1 * abs(position)
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        let translationTransform: CGAffineTransform
        
        if attributes.scrollDirection == .horizontal {
            let width = collectionView.frame.width
            let translationX = -(width * itemSpacing * position)
            translationTransform = CGAffineTransform(translationX: translationX, y: 0)
        } else {
            let height = collectionView.frame.height
            let translationY = -(height * itemSpacing * position)
            translationTransform = CGAffineTransform(translationX: 0, y: translationY)
        }
        
        attributes.alpha = 1.0 - abs(position) + minAlpha
        attributes.transform = translationTransform.concatenating(scaleTransform)
    }
}


public protocol LayoutAttributesAnimator {
    func animate(collectionView: UICollectionView,
                 attributes: AnimatedCollectionViewLayoutAttributes)
}

/// A `UICollectionViewFlowLayout` subclass enables custom transitions between cells.
open class CustomCollectionViewLayout: UICollectionViewFlowLayout {
    
    /// The animator that would actually handle the transitions.
    open var animator: LayoutAttributesAnimator?
    
    /// Overrided so that we can store extra information in the layout attributes.
    open override class var layoutAttributesClass: AnyClass { 
        return AnimatedCollectionViewLayoutAttributes.self
    }
    
    open override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(
            in: rect
        ) else {
            return nil
        }
        return attributes.compactMap { 
            $0.copy() as? AnimatedCollectionViewLayoutAttributes
        }.map {
            self.transformLayoutAttributes($0)
        }
    }
    
    open override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect
    ) -> Bool {
        // We have to return true here so that the layout attributes would be recalculated
        // everytime we scroll the collection view.
        return true
    }
    
    private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else { return attributes }
        
        let a = attributes
        
        /**
         The position for each cell is defined as the ratio of the distance between
         the center of the cell and the center of the collectionView and the collectionView width/height
         depending on the scroll direction. It can be negative if the cell is, for instance,
         on the left of the screen if you're scrolling horizontally.
         */
        
        let distance: CGFloat
        let itemOffset: CGFloat
        
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = a.center.x - collectionView.contentOffset.x
            a.startOffset = (
                a.frame.origin.x - collectionView.contentOffset.x
            ) / a.frame.width
            a.endOffset = (
                a.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width
            ) / a.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = a.center.y - collectionView.contentOffset.y
            a.startOffset = (a.frame.origin.y - collectionView.contentOffset.y) / a.frame.height
            a.endOffset = (a.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height) / a.frame.height
        }
        
        a.scrollDirection = scrollDirection
        a.middleOffset = itemOffset / distance - 0.5
        
        // Cache the contentView since we're going to use it a lot.
        if a.contentView == nil,
            let c = collectionView.cellForItem(
                at: attributes.indexPath
            )?.contentView {
            a.contentView = c
        }
        
        animator?.animate(collectionView: collectionView, attributes: a)
        
        return a
    }
}

/// A custom layout attributes that contains extra information.
open class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    /// The ratio of the distance between the start of the cell and the start of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the start of the cell aligns the start of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var startOffset: CGFloat = 0
    
    /// The ratio of the distance between the center of the cell and the center of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the center of the cell aligns the center of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var middleOffset: CGFloat = 0
    
    /// The ratio of the distance between the **start** of the cell and the end of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the **start** of the cell aligns the end of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var endOffset: CGFloat = 0
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedCollectionViewLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedCollectionViewLayoutAttributes else {
            return false
        }
        
        return super.isEqual(o)
            && o.contentView == contentView
            && o.scrollDirection == scrollDirection
            && o.startOffset == startOffset
            && o.middleOffset == middleOffset
            && o.endOffset == endOffset
    }
}
