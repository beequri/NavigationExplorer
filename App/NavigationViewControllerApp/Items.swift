//  Categories.swift
//  Created by beequri on 02 Apr 2021

/*
 
 MIT License
 
 Copyright (c) 2021 NavigationExplorer (https://github.com/beequri/NavigationExplorer)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import UIKit
import NavigationExplorer

@objc public enum CategoryType:Int, CaseIterable {
    case heartCircle            = 100
    case heartSlashCircle       = 101
    
    case carCircle              = 102
    case tramCircle             = 103
    case bicycleCircle          = 104
    case figureWalkCircle       = 105
    case airplaneCircle         = 106
    
    case eyeCircle              = 107
    case faceSmiling            = 108
    case personCropCircle       = 109
    case person2Circle          = 110
    case antCircle              = 111
    
    case trayCircle             = 112
    case paperplaneCircle       = 113
    case archiveboxCircle       = 114
    case bookmarkCircle         = 115
    case creditcardCircle       = 116
    
    case bagCircle              = 117
    case houseCircle            = 118
    case headphonesCircle       = 119
    case giftCircle             = 120
    case micCircle              = 121
    case phoneCircle            = 122
    
    case paperclipCircle        = 123
    case linkCircle             = 124
    case bellCircle             = 125
    case pinCircle              = 126
    case mappinCircle           = 127
    case tvCircle               = 128
    
    case boltCircle             = 129
    case dollarsignCircle       = 130
    case bitcoinsignCircle      = 131
    case crossCircle            = 132
    
    case staroflifeCircle       = 133
    case exclamationmarkCircle  = 134
    case questionmarkCircle     = 135
    case numberCircle           = 136
    case plusminusCircle        = 137
    case docCircle              = 138
    case calendarCircle         = 139
    
    case bookCircle             = 140
    case playCircle             = 141
    case stopCircle             = 142
    case moonCircle             = 143
    case magnifyingglassCircle  = 144
    
    case flagCircle             = 145
    case locationCircle         = 146
    case tagCircle              = 147
    case cameraCircle           = 148
    case lockCircle             = 149
    
    case clock                  = 150
    case chartPie               = 151
    case waveformCircle         = 152
    case starCircle             = 153
    case fCursiveCircle         = 154
    
    case arrowsUpDownCircle     = 155
    case asteriskCircle         = 156
    case eurosignCircle         = 157
    case sterlingsignCircle     = 158
    case yensignCircle          = 159
    
    static var names: [String] = [
        "heart.circle", "heart.slash.circle", "car.circle", "tram.circle", "bicycle.circle", "figure.walk.circle", "airplane.circle",
        "eye.circle", "face.smiling", "person.crop.circle", "person.2.circle", "ant.circle",
        "tray.circle", "paperplane.circle", "archivebox.circle", "bookmark.circle", "creditcard.circle",
        "bag.circle", "house.circle", "headphones.circle", "gift.circle", "mic.circle", "phone.circle",
        "paperclip.circle", "link.circle", "bell.circle", "pin.circle", "mappin.circle", "tv.circle",
        "bolt.circle", "dollarsign.circle", "bitcoinsign.circle", "cross.circle", "staroflife.circle",
        "exclamationmark.circle", "questionmark.circle", "number.circle", "plusminus.circle", "doc.circle", "calendar.circle",
        "book.circle", "play.circle", "stop.circle", "moon.circle", "magnifyingglass.circle",
        "flag.circle", "location.circle", "tag.circle", "camera.circle", "lock.circle",
        "clock", "chart.pie", "waveform.circle", "star.circle", "f.cursive.circle", "arrow.up.arrow.down.circle",
        "asterisk.circle", "eurosign.circle", "sterlingsign.circle", "yensign.circle"
        
    ]
    
    var string:String {
        let index = self.rawValue - 100
        return CategoryType.names[index]
    }
}

@objc public class Items: NSObject {
    
    var selectedTags:[Int] = []
    
    @objc public lazy var items: [CollectionItem] = {
        var collection: [CollectionItem] = []
        for category in CategoryType.allCases {
            let unselectedName = category.string + ".fill"
            let selectedName = category.string + ".fill"
            guard let unselImage = UIImage(systemName: unselectedName),
                  let selImage = UIImage(systemName: selectedName) else {
                continue
            }
            let item = CollectionItem()
            item.selectedImage = selImage
            item.unselectedImage = unselImage
            item.tag = category.rawValue
            
            if selectedTags.contains(category.rawValue) {
                item.isSelected = true
            }
            
            collection.append(item)
        }
        return collection
    }()
    
    @objc public lazy var tags: [Int] = {
        return CategoryType.allCases.map {$0.rawValue}
    }()
    
    @objc public override init() {
        super.init()
    }
    
    @objc public func items(for ids:[Int]) -> [CollectionItem] {
        return items.filter { ids.contains($0.tag) }
    }
    
    @objc public lazy var selected: [CollectionItem] = {
        var collection: [CollectionItem] = []
        for item in items {
            guard item.isSelected == true else {
                continue
            }
            collection.append(item)
        }
        return collection
    }()
    
    @objc public init(selectedTags: [Int]) {
        self.selectedTags.append(contentsOf: selectedTags)
    }
}


