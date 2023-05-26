Week 3 README

# Juice Maker [STEP 3]
> 과일의 재고를 화면에 출력하고,
> 사용자가 주문 버튼을 누르면 해당 쥬스를 만들기 위해 필요한 과일의 수량을 소진합니다.
> 과일의 재고가 다 떨어졌을 경우 쥬스를 만들 수 없으며,
> 재고수정 버튼을 통해 재고를 추가하는 화면으로 이동합니다.
> 재고수정 화면에서 숫자를 변경한 후 닫기를 누르면 수정 확인 얼럿이 뜨고
> 예를 누르면 재고가 수정되며, 아니오를 누르면 수정 없이 이전 화면으로 복귀합니다.

<br><br>
## 📚 목차
- [팀원소개](#-팀원-소개)
- [타임라인](#-타임라인)
- [실행화면](#-실행화면)
- [트러블 슈팅](#-트러블-슈팅)
- [참고자료](#-참고자료)
- [팀 회고](#-팀-회고)

<br><br>
## 🧑‍💻 팀원 소개
| <img src="https://i.imgur.com/PmVVM2M.png" width="200"/> | <img src="https://github.com/devKobe24/BranchTest/blob/main/IMG_5424.JPG?raw=true" width="200" height="200"/> |
| :-: | :-: |
| [**maxhyunm**](https://github.com/maxhyunm) | [**Kobe**](https://github.com/devKobe24) |

<br><br>
## ⏰ 타임라인
프로젝트 진행 기간 | 23.05.17.(수) ~ 23.05.26.(금)

| 날짜 | 진행 사항 |
| -------- | -------- |
| 23.05.17.(수)     |presentStockViewController 메서드 생성, 노티피케이션 센터 연결, 레이블 연결, replaceStockLabel 메서드 생성, initializeFruitStock 메서드 생성.<br/> StockView->MainView Notification 추가, 내비게이션 바 & 닫기 버튼 생성, 닫기 버튼액션 추가(Alert), NotificationKey 열거형 생성, extensions 파일 생성<br/>setUpStepper, touchUpStepper 함수 생성, setUpNotificationPost 호출 시점변경. |
| 23.05.18.(목)     |setUpButtonUI 함수 생성, 스토리보드 오토레이아웃 구현.      |
| 23.05.19.(금)     |Alert 오류 수정, 뷰 전환시 데이터 전달 방식 수정, Notification 메서드 분리, 메서드명 및 변수명 변경, UI 세팅값 스토리보드 방식으로 변경.<br/>오토레이아웃 수정<br/>매직리터럴 삭제      |
| 23.05.23.(화)     |스토리보드 변수 분리, Identifier 열거형 생성, 메서드 흐름에 맞춰 순서 변경, alertAction 네이밍 수정, Extensions 파일 이름 수정.<br/>NotificationCenter를 Delegate 패턴으로 변경, StockError 파일명 변경.      |
| 23.05.24.(수)     |Delegate extension 확장, Delegate 객체 전달 방법 변경, 컨벤션 수정.<br/>refactor: MainViewController required init 삭제.      |
| 23.05.25.(목)     |StockViewController required init 수정      |
| 23.05.26.(금)     |README 작성      |

<br><br>
## 📺 실행화면
- JuiceMaker 실행 화면 <br>
![](https://hackmd.io/_uploads/HyWvNQhH2.gif)

<br><br>
## 🔨 트러블 슈팅 
### 1️⃣ 화면간 데이터 전달 <br>
🔒 **문제점**<br>
다양한 방안을 고민하다 NotificationCenter를 활용하여 작업을 했지만, 이렇게 하니 코드가 길어지고 복잡해보이는 단점이 있었습니다. 또한 1대1로 데이터를 주고받는데 굳이 전체로 알림을 발송하는 NotificationCenter를 사용할 이유가 없다는 생각이 들었습니다.
```swift=
NotificationCenter.default.post(name: NSNotification.Name.stockChangeStart,
                                object: nil,
                                userInfo: [NotificationKey.fruitStock: fruitStock])

private func setUpNotificationPost() {
    NotificationCenter.default.post(name: NSNotification.Name.stockChangeEnd,
                                    object: nil,
                                    userInfo: [NotificationKey.fruitStock: fruitStock])
}
```
<br><Br>
🔑 **해결방법 1** <br>
MainViewController에서 StockViewController로 데이터를 넘기는 방식은 instantiateViewController(identifier:creator:)를 활용하여 생성자를 통해 전달하는 방식으로 변경하였습니다. StockViewController를 생성할 때 fruitStock을 바로 넘겨주니 코드가 훨씬 간편해 졌습니다.
```swift=
// MainViewController
@IBAction private func presentStockViewController() {
        let storyboard = UIStoryboard(name: Identifier.mainStoryboard.name, bundle: nil)
        let stockViewController = storyboard.instantiateViewController(
            identifier: Identifier.stockViewController.name,
            creator: { coder in
                return StockViewController(coder: coder, fruitStock: self.fruitStock)
            })
        stockViewController.delegate = self
        
        stockViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.navigationController?.present(stockViewController, animated: true)
}
```
```swift=
// StockViewController
init?(coder: NSCoder, fruitStock: [Fruit: Int]) {
    self.fruitStock = fruitStock
    super.init(coder: coder)
}
```
<br><br>
🔑 **해결방법 2**<br>
StockViewController에서 MainViewController로 데이터를 넘기는 방식은 Delegate 패턴을 활용하였습니다. 불필요한 알림을 발송하지 않아도 되는 점이 효율적이라고 판단하였습니다.

```swift=
// MainViewController
protocol MainViewControllerDelegate: AnyObject {
    func changeFruitInventory(fruitStockStatus: [Fruit: Int])
}

stockViewController.delegate = self

extension MainViewController: MainViewControllerDelegate {
    func changeFruitInventory(fruitStockStatus: [Fruit: Int]) {
        juiceMaker.changeFruitStock(fruitStockStatus)
        fruitStock = fruitStockStatus
    }
}
```
```swift=
// StockViewController
weak var delegate: MainViewControllerDelegate?

private func removeStockViewController(isChange: Bool) {
    if isChange {
        delegate?.changeFruitInventory(fruitStockStatus: fruitStock)
    }
    self.dismiss(animated: true)
}
```
<br><br>
🤔 **고민했던 점** <br>
MainViewController와 StockViewController 사이에 반복되는 코드(Alert과 Label 변경 메서드)가 다소 발생하여 이를 효율적으로 처리하는 방법에 대해 많은 고민이 있었습니다. 하지만 Alert의 경우 상황에 따라 매번 다른 처리를 진행해야 하는 점이 있어 각각 구성하는 것이 좋다고 판단하게 되었고, Label 변경 메서드의 경우 굳이 클래스나 프로토콜로 나누게 되면 오히려 코드가 길어지며 가독성이 떨어진다는 판단을 내려 지금의 형태를 유지하게 되었습니다.

<br><br>
## 📑 참고자료
- [Protocol](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/)
- [Delegation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/#Delegation)
- [초기화](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization)
- [instantiateViewController](https://developer.apple.com/documentation/uikit/uistoryboard/3213989-instantiateviewcontroller)
- [클래스와 구조체](https://bbiguduk.gitbook.io/swift/language-guide-1/structures-and-classes)

<br><br>
## 📝 팀 회고
### 우리 팀
👍 활발한 의견 공유
👍 팀프로젝트 활동시간대를 정하여 개인 공부 시간에 영향 없도록 한 점
👍 각자의 부족한 부분을 서로 채워나간 점
👍 모르는 것이 있으면 부끄러워하지 않고 질문을 서슴없이 한 점
👍 어려운 상황이나 문제가 닥치면 함께 찾아보고 풀어나간 점
<br><br>
### 팀원 피드백
**To. Kobe**
👍 여러 차례 의견이나 아이디어를 번복해도 흔쾌히 함께 의견을 나누며 작업해주신 점에 너무 감사드립니다!
👍 UI 구현 부분에 지식이 많이 부족한 저를 위해 이해가 쉽도록 설명을 곁들이며 작업해 주셨습니다.
👍 늘 팀프로그래밍 시간 전에 문서 작성이나 필요한 자료를 준비해두셔서 프로젝트가 훨씬 빠르고 원활히 진행될 수 있었습니다.
👍 제가 놓친 부분들을 예리하게 캐치하여 의견을 제시해 주셨습니다.
👍 막강 친화력을 가지신 코비 덕분에 즐거운 팀프로그래밍 시간이 될 수 있었습니다.<br>

**To. Maxhyunm**
👍 이해가 가지 않는 부분에 대해 여러차례 질문을 드려도 친절하게 답해주셨습니다.
👍 제가 한 질문에 대한 답변을 저의 지식에 맞춰 잘 풀어 설명해주셨습니다.
👍 항상 의견 조율에 대한 의견을 먼저 물어봐주시고 맞춰주셨습니다.
👍 Swift에 대한 많은 방법론을 제시해주시고 먼저 이끌어주셔서 좋은 공부가 되었습니다.
👍 분위기를 너무 좋게 풀어주셨습니다. <br>
