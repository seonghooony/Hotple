//
//  HomeViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//


import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

class HomeTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = HomeTabViewReactor
    
    weak var windowNavigationController: UINavigationController?
    
    let testBtn = UIButton()
    
    // 상단 네비 뷰
    var headerView = UIView()
    // 헤더 라벨 뷰
    var headerLbl = UILabel()

    
    override func loadView() {
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .white
        
        headerView.backgroundColor = .white
        self.view.addSubview(headerView)
        
        headerLbl.text = "마이페이지"
        headerLbl.textColor = .black
        self.headerView.addSubview(headerLbl)

        
        testBtn.setTitle("TEST", for: .normal)
        testBtn.backgroundColor = .black
        self.view.addSubview(testBtn)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        Log.debug("HomeTabViewController deinit")
    }
    
    func initConstraint() {
        
        self.testBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
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
    
    func bind(reactor: HomeTabViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: HomeTabViewReactor) {
        //action
        testBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToTest
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: HomeTabViewReactor) {
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
