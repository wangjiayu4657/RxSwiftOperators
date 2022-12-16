import UIKit
import RxSwift
import RxCocoa
import RxRelay


enum TestError:Error {
  case test
}

let disbag:DisposeBag = DisposeBag()
let obser1 = PublishSubject<String>()
let obser2 = PublishSubject<String>()
let obser3 = PublishSubject<String>()

///在多个源 Observables 中， 取第一个发出元素或产生事件的 Observable，然后只发出它的元素
func ambOperator() {
  obser1
    .amb(obser2)
    .amb(obser3)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser2.onNext("hello")
  obser1.onNext("1")
  obser3.onNext("a")
  obser1.onNext("2")
  obser3.onNext("b")
  obser2.onNext("world")
}
//ambOperator() //输出: hello world


/// 操作符将缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
func bufferOperator() {
  let obser = Observable<Int>.from([1,2,3,4,5,6,7,8,9,10,11,12])
  obser.buffer(timeSpan: .seconds(1), count: 6, scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//bufferOperator() //输出 [1,2,3,4,5,6],[7,8,9,10,11,12],[]


///操作符将会拦截一个 error 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。这样可以使得 Observable 正常结束，或者根本都不需要结束
func catchErrorOperator() {
  obser1
    .catch({ err in
      print("err = \(err)")
      return obser2
    })
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("a")
  obser1.onNext("b")
  obser1.onNext("c")
  obser1.onError(TestError.test)
  obser2.onNext("hello obser2")
}
//catchErrorOperator() //输出 a,b,c, err = test, hello obser2


///操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经都发出过元素）
func combineLatestOperator() {
  Observable
    .combineLatest(obser1, obser2) {$0 + $1}
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser2.onNext("A")
  obser1.onNext("2")
  obser2.onNext("B")
  obser2.onNext("C")
  obser2.onNext("D")
  obser1.onNext("3")
  obser1.onNext("4")
  obser1.onNext("5")
}
//combineLatestOperator() //输出1A,2A,2B,2C,2D,3D,4D,5D

func combineLatestOperator1() {
  let stringObservable = Observable.just("1")
  let fruitObservable = Observable.from(["a", "b"])
  let animalObservable = Observable.from(["2", "3", "4"])
  let source = [stringObservable, fruitObservable, animalObservable]
  Observable
    .combineLatest(source) { "\($0[0]) \($0[1]) \($0[2])" }
    .subscribe(onNext: { print($0) })
    .disposed(by: disbag)
}
//combineLatestOperator1() 
/*
 输出:
 1 a 2
 1 b 2
 1 b 3
 1 b 4
 */


///操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素
func concatOperator() {
  obser1
    .concat(obser2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser2.onNext("a")
  obser2.onNext("b")
  obser1.onNext("1")
  obser2.onNext("c")
  obser1.onNext("2")
  obser1.onCompleted()
  obser2.onNext("hello")
  obser2.onNext("world")
}
//concatOperator() //输出 1,2, hello, world


///Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅
func concatMapOperator() {
  let obser = BehaviorSubject(value: obser1)

  obser
    .concatMap{ $0 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disbag)

  obser1.onNext("A")
  obser1.onNext("B")
  obser.onNext(obser2)
  obser2.onNext("1")
  obser2.onNext("2")
  obser1.onCompleted()
  obser2.onNext("hello")
}
//concatMapOperator() //输出 A,B,hello


///publish 会将 Observable 转换为可被连接的 Observable。可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。
func connectOperator() {
  let obser = Observable<Int>
    .interval(.seconds(1), scheduler: MainScheduler.instance)
    .publish()
  
  _ = obser.subscribe(onNext: {print("subscription 1:,event: \($0)")}).disposed(by: disbag)

  DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
    _ = obser.connect()
  })
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
    _ = obser
      .subscribe(onNext: {print("subscription 2:,event: \($0)")})
      .disposed(by: disbag)
  })
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
    _ = obser
      .subscribe(onNext: {print("subscription 3:,event: \($0)")})
      .disposed(by: disbag)
  })
   
}
//connectOperator() //输出 0 1 1 2 2 3 3 3 4 4 4 ...


/// 操作符将创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程
func createOperator() {
   let obser = Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    observer.onCompleted()
    return Disposables.create()
  }
  
  obser
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//createOperator() //输出 1,2,3,4,5


///操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生(过滤掉高频产生的元素)
func debounceOperator() {
  Observable<Int>
    .from([1,2,3,6,7,12,13,14,20])
    .flatMap({
      Observable
        .of($0)
        .delaySubscription(.seconds($0), scheduler: MainScheduler.instance)
    })
    .debounce(.seconds(2), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//debounceOperator() //输出 3,7,14,20


///打印所有的订阅，事件以及销毁信息
func debugOperator() {
  let observable = Observable<String>.create { observer in
    observer.onNext("🍎")
    observer.onNext("🍐")
    observer.onCompleted()
    return Disposables.create()
  }
  
  observable
    .debug()
    .subscribe()
    .disposed(by: disbag)
}
//debugOperator()

//2022-12-14 16:34:57.413: operator.playground:195 (debugOperator()) -> subscribed
//2022-12-14 16:34:57.434: operator.playground:195 (debugOperator()) -> Event next(🍎)
//2022-12-14 16:34:57.435: operator.playground:195 (debugOperator()) -> Event next(🍐)
//2022-12-14 16:34:57.436: operator.playground:195 (debugOperator()) -> Event completed
//2022-12-14 16:34:57.436: operator.playground:195 (debugOperator()) -> isDisposed


///直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。在一些情况下，直到订阅时才创建 Observable 是可以保证拿到的数据都是最新的
func deferredOperator() {
  var count = 1
  
  let observable = Observable<String>.deferred {
    count += 1
    return Observable<String>.create { observer in
      observer.onNext("🐶")
      observer.onNext("🐱")
      observer.onNext("🐵")
      observer.onNext("\(count)")
      return Disposables.create()
    }
  }
  
  observable
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  observable
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//deferredOperator() //输出 🐶 🐱 🐵 2 , 🐶 🐱 🐵 3


///将 Observable 的每一个元素拖延一段时间后发出,delay 操作符将修改一个 Observable，它会将 Observable 的所有元素都拖延一段设定好的时间， 然后才将它们发送出来
func delayOperator() {
  Observable<String>
    .of("🐶", "🐱", "🐵")
    .delay(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//delayOperator() //延迟3s输出 🐶 🐱 🐵


///delaySubscription 操作符将在经过所设定的时间后，才对 Observable 进行订阅操作, 即延时订阅
func delaySubscriptionOperator() {
  Observable<String>
    .of("🐶", "🐱", "🐵")
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//delaySubscriptionOperator() //延迟3s后输出 🐶 🐱 🐵


///该操作符的作用和 materialize 正好相反，它可以将 materialize 转换后的元素还原
func dematerializeOperator() {
  var result = [Event<Int>]()
  Observable<Int>
    .of(1,2,3)
    .materialize()
    .subscribe(onNext: {result.append($0)})
    .disposed(by: disbag)
  
  Observable
    .from(result)
    .dematerialize()
    .subscribe(onNext: {print("element == \($0)")})
    .disposed(by: disbag)
}
//dematerializeOperator() //输出: element == 1, element == 2, element == 3


///阻止 Observable 发出相同的元素distinctUntilChanged 操作符将阻止 Observable 发出相同的元素。如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。
func distinctUntilChangedOperator() {
  Observable<Int>
    .of(1,1,2,2,2,3,3,3,3,4,4,4,4)
    .distinctUntilChanged()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//distinctUntilChangedOperator() //输出: 1,2,3,4


///当 Observable 产生某些事件时，执行某个操作, 当 Observable 的某些事件产生时，你可以使用 do 操作符来注册一些回调操作。这些回调会被单独调用，它们会和 Observable 原本的回调分离。
func doOperator() {
  let callBack:((String) -> ())? = {print("element == \($0)")}
  Observable<String>
    .of("a","b","c")
    .do(onNext: callBack)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//doOperator() //输出:  element == a,b,c


///只发出 Observable 中的第 n 个元素,elementAt操作符将拉取Observable序列中指定索引的元素,然后将它作为唯一的元素发出
func elementOperator() {
  Observable
    .of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .element(at: 3)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//elementOperator()  //输出: 🐸


///empty操作符将创建一个Observable,  这个Observable只有一个完成事件
func emptyOperator() {
   Observable<Int>
    .empty()
    .subscribe(onCompleted: {print("completed")})
    .disposed(by: disbag)
}
//emptyOperator()  //输出: completed


///error操作符将创建一个Observable,这个Observable只会产生一个error事件
func errorOperator() {
  Observable<TestError>
    .error(TestError.test)
    .subscribe(onError:{print($0)})
    .disposed(by: disbag)
}
//errorOperator() //输出: test


///filter 操作符将通过你提供的判定方法过滤一个Observable
func filterOperator() {
  Observable<Int>
    .from([1,10,3,14,18,7,21,5])
    .filter({$0 > 10})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//filterOperator() //输出: 14, 18, 21


///flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。
func flatMapOperator() {
   BehaviorSubject(value: obser1)
    .flatMap({$0})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser1.onNext("2")
  obser1.onNext("3")
  obser1.onCompleted()
}
//flatMapOperator() //输出: 1,2,3

func flatMapPerator1() {
  let obser = BehaviorSubject(value: obser1)
  obser
    .flatMap({$0})
    .subscribe(onNext:{print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser.onNext(obser2)
  obser2.onNext("👦🏻")
}
//flatMapPerator1() //输出: 1, 👦🏻


/// flatMapFirst 与 flatMapLatest 正好相反：flatMapFirst 只会接收最初的 value 事件。该操作符可以防止重复请求：比如点击一个按钮发送一个请求，当该请求完成前，该按钮点击都不应该继续发送请求。便可该使用 flatMapFirst 操作符。
func flatMapFirstOperator() {
  let observer = BehaviorSubject(value: obser1)
  observer
    .flatMapFirst({$0})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("a")
  observer.onNext(obser2)
  obser2.onNext("1")
}
//flatMapFirstOperator() //输出: a


///flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
func flatMapLatestOperator() {
  let obser = BehaviorSubject(value: obser1)
  obser
    .flatMapLatest({$0})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("a")
  obser1.onNext("b")
  obser.onNext(obser2)
  obser2.onNext("1")
  obser2.onNext("2")
  obser1.onNext("c")
}
//flatMapLatestOperator() //输出: a,b,1,2


///from 操作符提供了在使用 Observable 时，能够直接将其他类型转换为 Observable的功能
func fromOperator() {
  Observable<Int>
    .from([1,2,3,4,5])
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//fromOperator() //输出: 1,2,3,4,5


///groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。它会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
func groupByOperator() {
  Observable<Int>
    .from([1,2,3,4,5,6,7,8,9,10])
    .groupBy(keySelector: {$0 % 2 == 0 ? "偶数" : "奇数"})
    .subscribe(onNext: { result in
      result
        .map({result.key + " : \($0)"})
        .subscribe(onNext: {print($0)})
        .disposed(by: disbag)
    })
    .disposed(by: disbag)
}
//groupByOperator() //奇数 : 1,3,5,7,9  偶数 : 2,4,6,8,10


///创建一个可观察对象序列，只要所提供的条件计算为true，该序列就会生成值。
func generateOperator() {
  Observable<Int>
    .generate(initialState: 2, condition: {$0 < 6}, iterate: {$0 * 2})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//generateOperator() //输出: 2, 4


///ignoreElements 操作符将阻止 Observable 发出 next 事件，但是允许他发出 error 或 completed 事件。如果你并不关心 Observable 的任何元素，你只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符。
func ignoreElemmentsOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .ignoreElements()
    .subscribe(onCompleted: {print("completed")})
    .disposed(by: disbag)
}
//ignoreElemmentsOperator() //输出: completed


///interval 操作符将创建一个 Observable，它每隔一段设定的时间，发出一个索引数的元素。它将发出无数个元素。
func intervalOperator() {
  Observable<Int>
    .interval(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//intervalOperator() //输出: 0,1,2,3...


///just 操作符将某一个元素转换为 Observable, 发出唯一的一个元素
func justOperator() {
  Observable<Int>
    .just(6)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//justOperator()  //输出: 6


///map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
func mapOperator() {
  Observable<Int>
    .from([1,2,3])
    .map({$0 * 2})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//mapOperator() //输出: 2,4,6


///merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。
func mergeOperator() {
  Observable
    .merge([obser1,obser2])
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
    
  obser1.onNext("1")
  obser2.onNext("a")
}
//mergeOperator() //输出: 1, a

func mergeOperator1() {
  Observable
    .of(obser1,obser2)
    .merge()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
    
  obser1.onNext("1")
  obser2.onNext("a")
}
//mergeOperator1() //输出: 1, a


///materialize 操作符将 Observable 产生的这些事件全部转换成元素，然后发送出来。
func materializeOperator() {
  Observable<Int>
    .of(1,2,3)
    .materialize()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//materializeOperator() // 输出: event(1), event(2), event(3), completed


///publish 会将 Observable 转换为可被连接的 Observable。可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。
func publishOperator() {
	let sequence = Observable<Int>
    .interval(.seconds(1), scheduler: MainScheduler.instance)
    .publish()
  
  sequence
    .subscribe(onNext: {print("subscription 1: \($0)")})
    .disposed(by: disbag)
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
   	 sequence
      .connect()
      .disposed(by: disbag)
  }
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    sequence
      .subscribe(onNext: {print("subscription 2: \($0)")})
      .disposed(by: disbag)
  }
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    sequence
      .subscribe(onNext: {print("subscription 3: \($0)")})
      .disposed(by: disbag)
  }
}
//publishOperator() //输出:0 1 1 2 2 3 3 3 4 4 4  ...


///reduce 操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。
func reduceOperator() {
  Observable<Int>
    .of(10,100,1000)
    .reduce(1, accumulator: +)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//reduceOperator() //输出:1111


///refCount 操作符将自动连接和断开可被连接的 Observable。它将可被连接的 Observable 转换为普通 Observable。当第一个观察者对它订阅时，那么底层的 Observable 将被连接。当最后一个观察者离开时，那么底层的 Observable 将被断开连接。
func refCountOperator() {
  Observable<Int>
    .of(1,2,3,4)
    .publish()
    .refCount()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//refCountOperator() //输出: 1,2,3,4


///repeatElement 操作符将创建一个 Observable，这个 Observable 将无止尽地发出同一个元素
func repeatElementOperator() {
  Observable<Int>
    .repeatElement(1)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//repeatElementOperator() //输出: 1 1 1 ...


///replay操作符将Observable转换为可被连接的Observable，并且这个可被连接的Observable将缓存最新的n个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。
func replayOperator() {
  let sequence = Observable<Int>
    .interval(.seconds(1), scheduler: MainScheduler.instance)
    .replay(3)
  
  sequence
    .subscribe(onNext: {print("subscription 1: \($0)")})
    .disposed(by: disbag)
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    sequence
      .connect()
      .disposed(by: disbag)
  }
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    sequence
      .subscribe(onNext: {print("subscription 2: \($0)")})
      .disposed(by: disbag)
  }
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    sequence
      .subscribe(onNext: {print("subscription 3: \($0)")})
      .disposed(by: disbag)
  }
}
//replayOperator()
/*
 输出:
 subscription 1: 0
 subscription 2: 0
 subscription 1: 1
 subscription 2: 1
 subscription 1: 2
 subscription 2: 2
 subscription 3: 0
 subscription 3: 1
 subscription 3: 2
 subscription 1: 3
 subscription 2: 3
 subscription 3: 3
 subscription 1: 4
 subscription 2: 4
 subscription 3: 4
 */

///retry 操作符不会将 error 事件，传递给观察者，然而，它会从新订阅源 Observable，给这个 Observable 一个重试的机会，让它有机会不产生 error 事件。retry 总是对观察者发出 next 事件，即便源序列产生了一个 error 事件，所以这样可能会产生重复的元素
func retryOperator() {
  var count  =  1
  let sequence = Observable<String>.create { observer in
    observer.onNext("🍎")
    observer.onNext("🍐")
    observer.onNext("🍊")
    if count == 1 {
      observer.onError(TestError.test)
      print("error")
      count += 1
    }
    observer.onNext("🐶")
    observer.onNext("🐱")
    observer.onNext("🐭")
    observer.onCompleted()
    return Disposables.create()
  }
  
  sequence
    .retry()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//retryOperator() //输出:🍎 🍐 🍊 error 🍎 🍐 🍊 🐶 🐱 🐭

///创建一个可观察序列，该序列发出一系列顺序整数，然后终止
func rangeOperator() {
  Observable<Int>
    .range(start: 1, count: 6)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//rangeOperator() //输出: 1,2,3,4,5,6

  
///sample 操作符将不定期的对源 Observable 进行取样操作。通过第二个 Observable 来控制取样时机。一旦第二个 Observable 发出一个元素，就从源 Observable 中取出最后产生的元素。
func sampleOperator() {
  let subject1 = Observable<Int>
    .interval(.seconds(1), scheduler: MainScheduler.instance)
  
  let subject2 = Observable<Int>
    .interval(.seconds(3), scheduler: MainScheduler.instance)
  
  subject1
    .sample(subject2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//sampleOperator() //输出: 2, 5, 8, 11, ...


///Sample除了订阅源Observable外，还可以监视另外一个Observable，即notifier。每当收到notifier事件，就会从源序列取一个最新的事件并发送。而如果两次 notifier 事件之间没有源序列的事件，则不发送值。
func sampleOperator1() {
  let source = PublishSubject<Int>()
  let notifier = PublishSubject<String>()
  
  source
    .sample(notifier)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  notifier.onNext("A")
  source.onNext(1)
  source.onNext(3)
  notifier.onNext("B")
  notifier.onNext("C")
  source.onNext(4)
}
//sampleOperator1() //输出 3


///scan操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。然后，将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。以此类推，直到遍历完全部的元素。
func scanOperator() {
  Observable<Int>
    .of(1,2,3,4,5)
    .scan(0, accumulator: +)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//scanOperator() //输出1,3,6,10,15

func scanIntoOperator() {
  var source = [Int]()
//  let block:((_ x:inout [Int], _ y:Int) -> Void) = {x,y in
//    x.append(y)
//  }
  
//  Observable<Int>
//    .of(1,2,3,4,5,6)
//    .scan(into: source, accumulator: block)
//    .subscribe(onNext:{print($0)})
//    .disposed(by: disbag)
//等价于下面的写法
  
  Observable<Int>
    .of(1,2,3)
    .scan(into: source, accumulator: {$0.append($1)})
    .subscribe(onNext:{print($0)})
    .disposed(by: disbag)

}
//scanIntoOperator() //输出: [1], [1, 2], [1, 2, 3]


/**
 share(replay:scope:) 操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者
 replay: 缓存的个数,默认值为0
 scope: 默认值为.whileConnected
 		1.forever：用一个Subject存储所有的connections的事件Event
 		2.whileConnected：每个connection 都有单独的一个Subject存储事件Event
 */
func shareReplayOperator() {
  let obser = Observable<String>.create { observer in
    print("开始网络请求")
    observer.onNext("网络请求结果")
    observer.onCompleted()
    return Disposables.create()
  }.share(replay: 1, scope: .forever)
  
  obser
    .subscribe(onNext: {print("第一次订阅: \($0)")})
    .disposed(by: disbag)
  
  obser
    .subscribe(onNext: {print("第二次订阅: \($0)")})
    .disposed(by: disbag)
}
//shareReplayOperator()
/*
 输出:
 开始网络请求
 第一次订阅: 网络请求结果
 第二次订阅: 网络请求结果
 */


///single 操作符将限制 Observable 只产生一个元素。如果 Observable 只有一个元素，它将镜像这个 Observable 。如果 Observable 没有元素或者元素数量大于一，它将产生一个 error 事件。
func singleOperator() {
  Observable<Int>
    .of(1,2)
    .single()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//singleOperator()
//输出: 1, Unhandled error happened: Sequence contains more than one element.

///只发出一次请求, 常用于网络请求
func singleOperator1() {
  let obser = Observable<String>.create { observer in
    print("开始网路请求")
    observer.onNext("请求结果")
    observer.onCompleted()
    return Disposables.create()
  }.share(replay: 1, scope: .forever)
  
  obser
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//singleOperator1() //输出: 开始请求请求, 请求结果


///skip 操作符可以让你跳过 Observable 中头 n 个元素，只关注后面的元素。
func skipOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .skip(2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//skipOperator() //输出: 3,4,5,6


///skipUntil 操作符可以让你忽略源 Observable 中头几个元素，直到另一个 Observable 发出一个元素后，它才镜像源 Observable。
func skipUntilOperator() {
  obser1
    .skip(until: obser2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser1.onNext("2")
  obser2.onNext("A")
  obser1.onNext("3")
  obser1.onNext("4")
  obser1.onNext("5")
  obser1.onNext("6")
}
//skipUntilOperator() //输出: 3,4,5,6


///skipWhile 操作符可以让你忽略源 Observable 中头几个元素，直到元素的判定为否后，它才镜像源 Observable。
func skipWhileOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .skip(while: { $0 < 3 })
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//skipWhileOperator() //输出: 3,4,5,6


///startWith 操作符会在 Observable 头部插入一些元素。
func startWithOperator() {
  Observable<String>
    .of("2","3","4","5","6")
    .startWith("1")
    .startWith("🅰️", "🅱️")
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//startWithOperator() //输出:🅰️,🅱️ 1,2,3,4,5,6


///switchLatest操作符: 取出信号中的信号,订阅最新发出的信号
func switchLatestOperator() {
  let obser = BehaviorSubject(value: obser1)
  
  obser
    .switchLatest()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("hello")
  obser.onNext(obser2)
  obser2.onNext("rxswift")
}
//switchLatestOperator() //输出: hello rxswift


///通过 take 操作符你可以只发出头 n 个元素。并且忽略掉后面的元素，直接结束序列。
func takeOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .take(3)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//takeOperator() //输出: 1,2,3


///通过 takeLast 操作符你可以只发出尾部 n 个元素。并且忽略掉前面的元素, 注意一个信号发送完成要调用 onCompleted
func takeLastOperator() {
  obser1
    .takeLast(2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("a")
  obser1.onNext("b")
  obser1.onNext("c")
  obser1.onNext("d")
  obser1.onNext("e")
  obser1.onCompleted()
}
//takeLastOperator() //输出: d, e


///takeUntil 操作符将镜像源 Observable，它同时观测第二个 Observable。一旦第二个 Observable 发出一个元素或者产生一个终止事件，那个镜像的 Observable 将立即终止
func takeUntilOperator() {
  obser1
    .take(until: obser2)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("A")
  obser1.onNext("B")
  obser1.onNext("C")
  obser2.onNext("1")
  obser1.onNext("D")
  obser1.onNext("E")
}
//takeUntilOperator() //输出: A,B,C


/**
 takeUntil 操作符将镜像源 Observable，它同时观测第二个 Observable
 behavior: 判断条件
 .inclusive: 包含与谓词匹配的最后一个元素
 .exclusive: 不包含与谓词匹配的最后一个元素
 */
func takeUntilOperator1() {
  Observable<Int>
    .of(1,2,3,4,5,6,4)
    .take(until: {$0 > 4}, behavior: .exclusive)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//takeUntilOperator1() //输出: 1,2,3,4


///takeWhile 操作符将镜像源 Observable 直到某个元素的判定为 false。此时，这个镜像的 Observable 将立即终止。
func takeWhileOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .take(while: {$0 < 4})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//takeWhileOperator() //输出: 1,2,3


/**
 takeWhile 操作符将镜像源 Observable，它同时观测第二个 Observable
 behavior: 判断条件
 .inclusive: 包含与谓词匹配的最后一个元素
 .exclusive: 不包含与谓词匹配的最后一个元素
 */
func takeWhileOperator1() {
  Observable<Int>
    .of(1,2,3,4,5,6)
    .take(while: {$0 < 4},behavior: .exclusive)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//takeWhileOperator1() //输出: 1,2,3


///如果 Observable 在一段时间内没有产生元素，timeout 操作符将使它发出一个 error 事件。
func timeOutOperator()  {
  Observable<Int>
    .of(1,3,6,12,18)
    .flatMap({Observable<Int>.just($0).delay(.seconds($0), scheduler: MainScheduler.instance)})
    .timeout(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//timeOutOperator() //输出: 1, 3, Unhandled error happened: Sequence timeout.


///timer 操作符将创建一个 Observable，它在经过设定的一段时间后，产生唯一的一个元素。这里存在其他版本的 timer 操作符
func timerOperator() {
  Observable<Int>
    .timer(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}

//timerOperator() //输出: 3s后输出 0

/**
 dueTime: 初始延时
 period: 时间间隔
 scheduler: 所在线程
 */
func timerOperator1() {
  Observable<Int>
    .timer(.seconds(3), period: .seconds(1), scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//timerOperator1() //输出: 0,1,2,3,4,...


///通过使用 using 操作符创建 Observable 时，同时创建一个可被清除的资源，一旦 Observable 终止了，那么这个资源就会被清除掉了。
func usingOperator() {
  print("暂时不知道如何使用,没有深入理解其使用场景,后续用到时再深入理解")
}


///window 操作符和 buffer 十分相似，buffer 周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
func windowOperator() {
  Observable<Int>
    .of(1,2,3,4,5,6,7,8)
    .window(timeSpan: .seconds(2), count: 4, scheduler: MainScheduler.instance)
    .debug()
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//windowOperator() //输出


///withLatestFrom 操作符将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。
func withLatestFromOperator() {
  obser1
    .withLatestFrom(obser2, resultSelector: {$0+$1})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser1.onNext("2")
  obser2.onNext("a")
  obser1.onNext("3")
  obser2.onNext("b")
  obser2.onNext("c")
  obser1.onNext("4")
}
//withLatestFromOperator() //输出: 3a,4c


/**
 zip 操作符将多个(最多不超过8个) Observables 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。例如，返回的 Observable 的第一个元素，是由每一个源 Observables 的第一个元素组合出来的。它的第二个元素 ，是由每一个源 Observables 的第二个元素组合出来的。它的第三个元素 ，是由每一个源 Observables 的第三个元素组合出来的，以此类推。它的元素数量等于源 Observables 中元素数量最少的那个。
 */
func zipOperator() {
  
    Observable<String>
    .zip(obser1, obser2, resultSelector: {$0+$1})
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
  
  obser1.onNext("1")
  obser1.onNext("2")
  obser2.onNext("a")
  obser1.onNext("3")
  obser2.onNext("b")
  obser2.onNext("c")
  obser1.onNext("4")
  obser2.onNext("d")
}
//zipOperator() //输出:1a,2b,3c,4d
