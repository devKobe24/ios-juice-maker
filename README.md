# Juice Maker [STEP 1]
> 사용자로부터 원하는 쥬스를 입력받아 쥬스를 만들어주는 앱.
> 각 주스마다 필요한 과일의 갯수가 정해져 있으며,
> 과일의 재고가 다 떨어졌을 경우,
> 주스를 만들 수 없고, 재고가 부족하다는 콘솔 로그를 출력해줍니다.

## 📚 목차
- [팀원소개](#-팀원-소개)
- [타임라인](#-타임라인)
- [실행화면](#-실행화면)
- [트러블 슈팅](#-트러블-슈팅)
- [참고자료](#-참고자료)
- [팀 회고](#-팀-회고)

## 🧑‍💻 팀원 소개
| <img src="https://i.imgur.com/PmVVM2M.png" width="200"/> | <img src="https://github.com/devKobe24/BranchTest/blob/main/IMG_5424.JPG?raw=true" width="200" height="200"/> |
| :-: | :-: |
| [**maxhyunm**](https://github.com/maxhyunm) | [**Kobe**](https://github.com/devKobe24) |

## ⏰ 타임라인
프로젝트 진행 기간 | 23.05.09.(화) ~ 23.05.11.(목)

| 날짜 | 진행 사항 |
| -------- | -------- |
| 23.05.09.(화)     | FruiteStore 생성 및 과일 재고 변경 메서드 구현.<br/>FruitJuice 열거형 타입 생성 및 isEnoughStock 메서드 생성.<br/>makeFruitJuice 함수 구현, isEnoughStock 열거형 리팩토링.<br/>StockError 열거형 생성, 예외처리 추가.<br/>checkStock 리팩토링, changeStock 리팩토링.<br/>calculateStock 메서드 리팩토링, makeFruitJuice 메서드 리팩토링. |
| 23.05.10.(수)     | Fruite, FruiteJuice 열거형 분리, errorMessage를 message로 변경.<br/>FruitStore 타입 struct로 변경, baseStock을 전달받는 생성자 구현, Ingredient typealias 생성, Recipe typealias 수정, calculateStock 함수의 argument label for에서 fo로 변경.<br/> 오타 수정, 개행 컨벤션 변경, 불필요한 주석 제거. 불필요한 Import 제거     |
| 23.05.11.(목)     | recipe 관련 네이밍 변경, 로직 조건문 변경, 불필요한 개행 삭제.|
| 23.05.12.(금)     | README 작성     |

## 📺 실행화면
- JuiceMaker 실행 화면 <br>
![](https://imgur.com/q9Qji8M.gif)

## 🔨 트러블 슈팅 
1️⃣ **FruitStore의 재고사항인 inventory를 생성하는 과정** <br>
🔒 **문제점** <br>
FruitStore의 재고사항인 inventory를 생성하는 과정에서, 처음에는 모든 과일의 수량을 10으로 주도록 CaseIterable과 reduce를 활용하여 기본값으로 딕셔너리를 생성했습니다. 하지만 이렇게 하니 과일마다 초기재고가 다를 경우를 구현할 수 없었고, 또한 모든 과일가게가 무조건 Fruit 타입 전체의 재고를 가지고 있도록 만들어져 문제가 되었습니다.
```swift!
private var inventory: Dictionary<Fruit, Int> = Fruit.allCases.reduce(into: Dictionary<Fruit, Int>()) { $0[$1] = 10 }
```

🔑 **해결방법** <br>
두 가지 생성자를 만들어 하나에는 모든 과일의 재고를 동일하게 맞출 수 있도록 구현했고, 다른 하나에는 [과일: 수량] 형식의 딕셔너리를 전달받아 inventory를 구성할 수 있도록 하여 해결했습니다.
```swift!
init(stock: [Fruit: Int]) {
    self.inventory = stock
}
    
init(equalizedStock: Int) {
    self.inventory = Fruit.allCases.reduce(into: [:]) {
        $0[$1] = equalizedStock
    }
}
```


2️⃣ **typealias** <br>
🔒 **문제점 2** <br>
타입 알리아스를 만들어 (fruit: 과일, quantity: 수량)의 타입으로 Receipe를 만들었지만, 내부적으로 해당 타입이 Array로 받아져야 하기 때문에(예: [Recipe]) 가독성이 좋지 않은 문제가 있었습니다.
```swift!
typealias Recipe = (fruit: Fruit, quantity: Int)
...
var chagedStock: Array<Recipe> = []
```

🔑 **해결방법** <br>
타입 알리아스를 하나 더 만들어 Ingredient라는 이름으로 Recipe와 Ingredient를 구분지었습니다.
```swift!
typealias Ingredient = (fruit: Fruit, quantity: Int)
typealias Recipe = [Ingredient]
...
var chagedStock: Recipe = []
```


3️⃣ **재고 변경 함수** <br>
🔒 **문제점 3** <br>
주스를 만들 때 일부 재료만 품절일 경우 전체 재고를 변경하지 않도록 구현하기 위해 처음에는 isEnoughStock() 이라는 메서드를 생성하여 Bool값으로 전체 재료의 제작 가능 여부를 리턴하도록 만든 뒤 changeStock() 메서드를 통해 재고를 변경하도록 구현했습니다. 하지만 이럴 경우 모든 재료의 재고를 가져오는 로직을 두 차례 반복해야 했습니다.

```swift!
func isEnoughStock(_ recipes: Array<Recipe>) throws -> Bool {
	for recipe in recipes {
		guard let fruitStock = inventory[recipe.fruit] else { throw StockError.fruitNotFound }
		guard fruitStock > recipe.amount else { throw StockError.outOfStock }
		return true
	}
}

func changeStock(of fruit: Fruit, minus amount: Int) throws {
	guard let fruitStock = inventory[fruit] else { throw StockError.fruitNotFound }
	guard fruitStock > amount else { throw StockError.outOfStock }
	
	inventory[fruit] = fruitStock - amount
}
```

🔑 **해결방법** <br>
isEnoughStock() 메서드를 calculateStock() 메서드로 변경, 재고가 충분하지 않은 경우 오류를 리턴하고 충분할 경우 쥬스에 필요한 값을 뺀 수량을 리턴하여 changeStock()에서는 단순히 재고 수량을 변경만 할 수 있도록 기능을 분리하였습니다.
```swift!
func calculateStock(of fruit: Fruit, quantity: Int) throws -> Int {
    guard let fruitStock = inventory[fruit] else {
        throw StockError.fruitNotFound
    }
    guard fruitStock >= quantity else {
        throw StockError.outOfStock
    }
        
    return fruitStock - quantity
}

mutating func changeStock(of fruit: Fruit, quantity: Int) {
    guard let  = inventory[fruit] else { return }
	inventory[fruit] = quantity
}
```


🤔 **고민했던 점** <br>
JuiceMaker 인스턴스를 통해 FruitStore 내부의 changeStock()에 접근할 수 있도록 메서드를 추가해야 할지 다소 고민이 되었지만, 처음 JuiceMaker 인스턴스를 생성할 때 FruitStore의 인스턴스를 만들어 인자로 전달해주어야 하기 때문에 해당 FruitStore 인스턴스를 사용하면 될 것으로 판단하여 따로 구현하지 않았습니다.


## 📑 참고자료
- [초기화](https://bbiguduk.gitbook.io/swift/language-guide-1/initialization)
- [프로퍼티](https://bbiguduk.gitbook.io/swift/language-guide-1/properties)
- [클래스와 구조체](https://bbiguduk.gitbook.io/swift/language-guide-1/structures-and-classes)
- [열거형](https://bbiguduk.gitbook.io/swift/language-guide-1/enumerations)
- [제어 흐름](https://bbiguduk.gitbook.io/swift/language-guide-1/control-flow)
- [에러 처리](https://bbiguduk.gitbook.io/swift/language-guide-1/error-handling)




## 📝 팀 회고
### 우리 팀
👍 활발한 의견 공유 <br>
👍 팀프로젝트 활동시간대를 정하여 개인 공부 시간에 영향 없도록 한 점 <br>
👍 각자의 부족한 부분을 서로 채워나간 점 <br>
👍 모르는 것이 있으면 부끄러워하지 않고 질문을 서슴없이 한 점 <br>
👍 어려운 상황이나 문제가 닥치면 함께 찾아보고 풀어나간 점 <br>

### 팀원 피드백
**To. Kobe** <br>
👍 여러 차례 의견이나 아이디어를 번복해도 흔쾌히 함께 의견을 나누며 작업해주신 점에 너무 감사드립니다! <br>
👍 UI 구현 부분에 지식이 많이 부족한 저를 위해 이해가 쉽도록 설명을 곁들이며 작업해 주셨습니다.<br>
👍 늘 팀프로그래밍 시간 전에 문서 작성이나 필요한 자료를 준비해두셔서 프로젝트가 훨씬 빠르고 원활히 진행될 수 있었습니다.<br>
👍 제가 놓친 부분들을 예리하게 캐치하여 의견을 제시해 주셨습니다.<br>
👍 막강 친화력을 가지신 코비 덕분에 즐거운 팀프로그래밍 시간이 될 수 있었습니다.<br>

**To. Maxhyunm** <br>
👍 이해가 가지 않는 부분에 대해 여러차례 질문을 드려도 친절하게 답해주셨습니다. <br>
👍 제가 한 질문에 대한 답변을 저의 지식에 맞춰 잘 풀어 설명해주셨습니다. <br>
👍 항상 의견 조율에 대한 의견을 먼저 물어봐주시고 맞춰주셨습니다. <br>
👍 Swift에 대한 많은 방법론을 제시해주시고 먼저 이끌어주셔서 좋은 공부가 되었습니다. <br>
👍 분위기를 너무 좋게 풀어주셨습니다. <br>
