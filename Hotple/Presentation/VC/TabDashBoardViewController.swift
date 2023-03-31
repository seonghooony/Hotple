//
//  TabDashBoardViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/03/29.
//


import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

class TabDashBoardViewController: UITabBarController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = TabDashBoardViewReactor
    
    weak var windowNavigationController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        Log.debug("TabDashBoardViewController deinit")
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
    
    func bind(reactor: TabDashBoardViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: TabDashBoardViewReactor) {
        //action
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: TabDashBoardViewReactor) {
        //state
        
//        reactor.state
//            .map { state in
//                print("reactor")
//                print(state.userData)
//                return String(state.userData.id)
//            }
//            .distinctUntilChanged()
//            .bind(to: testLbl.rx.text)
//            .disposed(by: disposeBag)
        
    }
    
}

extension TabDashBoardViewController: UITabBarControllerDelegate {
    
}
