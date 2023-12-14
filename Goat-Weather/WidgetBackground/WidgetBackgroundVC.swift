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

enum WidgetSize {
    case iPhoneSmall
    case iPhoneMedium
    case iPhoneLarge
}

struct WidgetModel: Equatable {
    var size: WidgetSize?
    var imageURL: URL?
    var location: String?
}

class WidgetBackgroundVC: UIViewController {
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var changeButton: UIButton!
    private let widgets: [WidgetModel] = [
        .init(
            size: .iPhoneSmall,
            imageURL: nil,
            location: "Semarang"
        ),
        .init(
            size: .iPhoneMedium,
            imageURL: nil,
            location: "Semarang"
        ),
        .init(
            size: .iPhoneLarge,
            imageURL: nil,
            location: "Semarang"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.title = "Widget Background"
        
        cardCollectionView?.isPagingEnabled = true
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.register(WidgetCollectionViewCell.self,
                                    forCellWithReuseIdentifier: WidgetCollectionViewCell.reuseIdentifier)
        
        let layout = CustomCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.animator = LinearCardAttributesAnimator()
        cardCollectionView.collectionViewLayout = layout
        
        pageControl.numberOfPages = widgets.count
        changeButton.titleLabel?.textColor = .white
        changeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        changeButton.setTitle("  Change Background", for: .normal)
        changeButton.setImage(UIImage(systemName: "photo"), for: .normal)
        changeButton.backgroundColor = .systemGreen
        changeButton.tintColor = .white
        changeButton.clipsToBounds = true
        changeButton.layer.cornerRadius = 8
        
        DispatchQueue.main.async {
            self.cardCollectionView.reloadData()
        }
    }
    
    @IBAction func changeBackground(
        _ sender: UIButton
    ) {
        
        
    }
}

extension WidgetBackgroundVC: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

extension WidgetBackgroundVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
        widgets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WidgetCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? WidgetCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.widgets = widgets[indexPath.item]
        return cell
    }
}

extension WidgetBackgroundVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout, 
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.bounds.width / CGFloat(1),
            height: view.bounds.height / CGFloat(1)
        )
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout, 
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        -1
    }
    
}

extension WidgetBackgroundVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any]
    ) {
        
    }
}
