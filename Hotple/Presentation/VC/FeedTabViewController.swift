//
//  FeedTabViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

class FeedTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = FeedTabViewReactor
    
    weak var windowNavigationController: UINavigationController?
    
    // 상단 네비 뷰
    var headerView = UIView()
    // 헤더 라벨 뷰
    var headerLbl = UILabel()

    
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
        Log.debug("FeedTabViewController deinit")
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
        
        self.view.backgroundColor = .brown
        
        headerView.backgroundColor = .white
        self.view.addSubview(headerView)
        
        headerLbl.text = "마이페이지"
        headerLbl.textColor = .black
        self.headerView.addSubview(headerLbl)
        
    }
    
    func initConstraint() {
        headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
//            make.top.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(Const.headerMinHeight)
        }
        
        headerLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
    }
    

    
    func bind(reactor: FeedTabViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: FeedTabViewReactor) {
        //action
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: FeedTabViewReactor) {
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
