//
//  JuiceMaker - AlertEnum.swift
//  Created by Min Hyun on 2023/05/15.
//  last modified by maxhyunm, kobe
//

import UIKit

enum AlertText {
    case menuOut(menu: String)
    case outOfStock
    case confirmStockChange
    
    var title: String {
        switch self {
        case .menuOut(menu: let menu):
            return "\(menu) 나왔습니다!"
        case .outOfStock:
            return "재료가 모자라요."
        case .confirmStockChange:
            return "재고 변경"
        }
    }
    
    var message: String {
        switch self {
        case .menuOut:
            return "맛있게 드세요!"
        case .outOfStock:
            return "재고를 수정할까요?"
        case .confirmStockChange:
            return "정말로 재고를 수정하시겠습니까?"
        }
    }
}

enum AlertActionText {
    case ok
    case cancel
    case interjection
    
    var title: String {
        switch self {
        case .ok:
            return "예"
        case .cancel:
            return "아니오"
        case .interjection:
            return "야호!"
        }
    }
}
