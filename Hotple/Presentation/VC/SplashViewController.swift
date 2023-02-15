//
//  SplashViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/13.
//


import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit
import Lottie
import RxViewController

class SplashViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = SplashViewReactor
    
    private let animationLogoView: LottieAnimationView = .init(name: "splash")

    private let startSubject = PublishSubject<Bool>()
    
    override func loadView() {
        let view = UIView()
        
        view.backgroundColor = .white
        self.view = view
        
        
        
        animationLogoView.play { isFinished in
            print(isFinished)
            self.startSubject.onNext(isFinished)
        }
        animationLogoView.contentMode = .scaleToFill
//        animationLogoView.loopMode = .repeatBackwards(1)
        animationLogoView.loopMode = .playOnce
        view.addSubview(animationLogoView)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        print("SplashViewController deinit")
    }
    
    func initConstraint() {
        animationLogoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        
    }
    
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SplashViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: SplashViewReactor) {
        //action
        
        startSubject.asObservable()
            .map { _ in
                return Reactor.Action.checkToLogin
            }
//            .delay(.seconds(1), scheduler: MainScheduler.instance) //reactorview 가 세팅할 시간을 줘야함
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
//        self.rx.viewDidLoad
//            .map { _ in
//                return Reactor.Action.checkToLogin
//            }
//            .delay(.seconds(1), scheduler: MainScheduler.instance) //reactorview 가 세팅할 시간을 줘야함
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        
    }
    
    
    func bindState(_ reactor: SplashViewReactor) {
        //state


    }
    
}
