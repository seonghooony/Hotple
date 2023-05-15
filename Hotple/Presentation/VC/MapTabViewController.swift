//
//  MapTabViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

class MapTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = MapTabViewReactor
    
    weak var windowNavigationController: UINavigationController?

    
    override func loadView() {
        
        initView()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationBar()
        
    }
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.debug("MapTabViewController deinit")
    }
    
    /*
        상단 네비게이션 바 초기화
     */
    private func initNavigationBar() {
        
        let tempBtn1 = UIBarButtonItem(customView: UIView())
        let tempBtn2 = UIBarButtonItem(customView: UIView())
        
        _ = windowNavigationController?.viewControllers.map({ viewcontroller in
            if viewcontroller is UITabBarController {
                viewcontroller.navigationItem.rightBarButtonItems = [tempBtn1]
                viewcontroller.navigationItem.titleView = nil
                viewcontroller.navigationItem.leftBarButtonItems = [tempBtn2]
            }
        })

    }
    
    private func initView() {
        
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .systemBrown
        

        
    }
    
    func initConstraint() {
        
        
    }
    
    

    
    func bind(reactor: MapTabViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: MapTabViewReactor) {
        //action
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: MapTabViewReactor) {
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
