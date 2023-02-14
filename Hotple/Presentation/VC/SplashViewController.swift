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

class SplashViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = SplashViewReactor
    
    private let animationLogoView: LottieAnimationView = .init(name: "")
    
    override func loadView() {
        let view = UIView()
        
        self.view = view
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        print("SplashViewController deinit")
    }
    
    func initConstraint() {

        
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


        
    }
    
    
    func bindState(_ reactor: SplashViewReactor) {
        //state


    }
    
}
