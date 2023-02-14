//
//  LoginViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//


import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit

class LoginViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = LoginViewReactor
    
    private let loginLbl = UILabel()
    
    private let kakaoBtn = UIButton()
    
    private let naverBtn = UIButton()
    
    
    
    
    private let googleBtn = UIButton()
    
    private let emailBtn = UIButton()
    
    private let signupBtn = UIButton()
    
    private let testBtn = UIButton()
    
    private let testLbl = UILabel()

    
    override func loadView() {
        let view = UIView()
        
        self.view = view
        
        // #698a50 #93c572 #e1ffc9 #f0ffe4
        self.view.backgroundColor = UIColor(red: 240/255, green: 255/255, blue: 228/255, alpha: 1.0)
        
        self.loginLbl.text = "로그인"
        self.loginLbl.textColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1.0)
        self.loginLbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.loginLbl.textAlignment = .center
        self.view.addSubview(self.loginLbl)
        
        kakaoBtn.setBackgroundImage(UIImage(named: "img_kakao_login"), for: .normal)
        self.view.addSubview(self.kakaoBtn)
        
        naverBtn.setBackgroundImage(UIImage(named: "img_naver_login"), for: .normal)
        self.view.addSubview(self.naverBtn)

        testBtn.setTitle("테스트", for: .normal)
        testBtn.backgroundColor = .blue
        self.view.addSubview(self.testBtn)
        
        testLbl.textColor = .black
        self.view.addSubview(self.testLbl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        print("LoginViewController deinit")
    }
    
    func initConstraint() {
        self.loginLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        self.kakaoBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.loginLbl.snp.bottom).offset(100)
            make.width.equalTo(250)
            make.height.equalTo(48)
        }
        
        self.naverBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.kakaoBtn.snp.bottom).offset(8)
            make.width.equalTo(250)
            make.height.equalTo(48)
        }
        
        self.testBtn.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        self.testLbl.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            
        }
        
//        self.moveToHomeBtn.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.height.equalTo(200)
//        }
//
//        self.moveToDetailBtn.snp.makeConstraints { make in
//            make.top.equalTo(self.moveToHomeBtn.snp.bottom).offset(50)
//            make.width.height.equalTo(200)
//        }
        
    }
    
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: LoginViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: LoginViewReactor) {
        //action
        kakaoBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToKakao
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naverBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToNaver
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        testBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToTest
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
//        moveToHomeBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.ClickMoveToHome
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//
//        moveToDetailBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickMoveToDetail
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        
    }
    
    
    func bindState(_ reactor: LoginViewReactor) {
        //state
        
        reactor.state
            .map { state in
                print("reactor")
                print(state.userData)
                return String(state.userData.id)
            }
            .distinctUntilChanged()
            .bind(to: testLbl.rx.text)
            .disposed(by: disposeBag)
        
//        reactor.state.map { state in
//            return state.homeIsRequired
//        }
//        .distinctUntilChanged()
//        .subscribe { isShow in
//            if isShow {
//                self.steps.accept(DemoStep.homeIsRequired)
//            }
//
//        }
//        .disposed(by: disposeBag)
//
//        reactor.state.map { state in
//            return state.detailIsRequired
//        }
//        .distinctUntilChanged()
//        .subscribe { isShow in
//            if isShow {
//                self.steps.accept(DemoStep.mainDetailIsRequired)
//            }
//
//        }
//        .disposed(by: disposeBag)
        
//        .map { value in
//            return value
//        }
//        .bind(to: valueLbl.rx.text)
//        .disposed(by: disposeBag)

    }
    
}
