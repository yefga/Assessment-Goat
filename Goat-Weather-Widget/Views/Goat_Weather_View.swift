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

import SwiftUI
import Kingfisher
import WidgetKit

enum WidgetImageType: Encodable {
    case placeholder(String)
    case uiImage(Data)
}


struct WidgetDataModel: Encodable {
    var location: String
    var backgroundImage: WidgetImageType
    var weatherImage: WidgetImageType 
    
}

struct Goat_Weather_WidgetEntryView : View {
    var entry: WidgetProvider.Entry
    @Environment(\.widgetFamily) private var family
    
    @ViewBuilder
    func ImageBuilder(
        size: CGSize,
        imageType: WidgetImageType
    ) -> some View {
        switch imageType {
        case .placeholder(let name):
            Image(name)
                .resizable()
        case .uiImage(let data):
            if let uiImage = UIImage(data: data) {
                // Resize the image to fit the widget's parent
                Image(
                    uiImage: resizeImage(
                        image: uiImage,
                        targetSize: .init(
                            width: size.width,
                            height: size.height
                        )
                    )
                ).resizable()
            } else {
                // Use a placeholder image if data is not valid
                Image("image.example")
                    .resizable()
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            switch family {
            case .systemMedium:
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        
                        // Display weather image with background color and corner radius
                        ImageBuilder(
                            size: geometry.size,
                            imageType: entry.data.weatherImage
                        )                
                        .background(Color.black.opacity(0.2).cornerRadius(20))
                        .scaledToFit()
                        
                        Spacer()
                        
                        // Display last update time
                        Text("Updated at\n\(Date.readableCurrentDate())")
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    
                    // Display location
                    Text(entry.data.location)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5.0)
                }
                .padding()
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
                .background(
                    // Display background image
                    ImageBuilder(
                        size: geometry.size,
                        imageType: entry.data.backgroundImage
                    )
                    .scaledToFill()
                )
                
            default:
                VStack(alignment: .center, spacing: 8) {
                    ImageBuilder(
                        size: geometry.size,
                        imageType: entry.data.weatherImage
                    )
                        .scaledToFit()
                    
                    Text(entry.data.location)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5.0)
                }
                .padding()
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
                .background(
                    ImageBuilder(
                        size: geometry.size,
                        imageType: entry.data.backgroundImage
                    )
                        .scaledToFill()
                )
            }
        }
    }
}

/**
 
 Function to retrieve the background image from the file system

 */
fileprivate func getBackgroundImage() -> UIImage {
    do {
        guard let url = try DatabaseFileManager.readFile(
            name: AppConfiguration.backgroundName
        ) else {
            fatalError("CANNOT FIND URL")
        }
        let data = try Data(contentsOf: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: "image.example")!
        }
        
    } catch  {
        fatalError("NO IMAGE DUDE")
    }
}

/**
 
 Function to resize an image to the target size

 */

fileprivate func resizeImage(
    image: UIImage,
    targetSize: CGSize
) -> UIImage {
    let size = image.size
    
    let widthRatio  = (targetSize.width * 10) / size.width
    let heightRatio = (targetSize.height * 10) / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    
    if (widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
