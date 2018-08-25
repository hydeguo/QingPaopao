//
//  SwiftRx(Extension).swift
//  Reserve
//
//  Created by Hydeguo on 2018/5/28.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension UIView {
    

    
    public var rx_visible: AnyObserver<Bool> {
        return Binder(self) { view, visible in
            view.isHidden = !visible
            }.asObserver()
    }
}
