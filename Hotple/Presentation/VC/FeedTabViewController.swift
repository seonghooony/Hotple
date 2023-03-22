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
        
        initNavigationBar()
        initView()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        print("FeedTabViewController deinit")
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
    
    /*
        상단 네비게이션 바 초기화
     */
    private func initNavigationBar() {
        print("네비 초기화")
      

        windowNavigationController?.navigationBar.backgroundColor = .white
        windowNavigationController?.navigationBar.topItem?.titleView = nil
        windowNavigationController?.navigationBar.topItem?.leftBarButtonItems = []
        windowNavigationController?.navigationBar.topItem?.rightBarButtonItems = []


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
    
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
