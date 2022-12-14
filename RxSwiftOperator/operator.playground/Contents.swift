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

//在多个源 Observables 中， 取第一个发出元素或产生事件的 Observable，然后只发出它的元素
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


// 操作符将缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
func bufferOperator() {
  let obser = Observable<Int>.from([1,2,3,4,5,6,7,8,9,10,11,12])
  obser.buffer(timeSpan: .seconds(1), count: 6, scheduler: MainScheduler.instance)
    .subscribe(onNext: {print($0)})
    .disposed(by: disbag)
}
//bufferOperator() //输出 [1,2,3,4,5,6],[7,8,9,10,11,12],[]


//操作符将会拦截一个 error 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。这样可以使得 Observable 正常结束，或者根本都不需要结束
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


//操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经都发出过元素）
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


//操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素
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


//Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅
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


//
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


// 操作符将创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程
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


//操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生(过滤掉高频产生的元素)
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

debounceOperator() //输出 3,7,14,20

