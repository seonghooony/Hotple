//
//  ProfileTabViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/10.
//

import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit
import RxKingfisher

class ProfileTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = ProfileTabViewReactor
    
    weak var windowNavigationController: UINavigationController?
    
    // 상단 네비게이션 타이틀 라벨
    var titleHeaderLbl = UILabel()

    // 세팅 버튼
    var settingBtn = UIButton()
    
    // 상단 프로필 헤더뷰
    var stickyHeaderView = UIView()
    // 프로필 이미지 뷰
    var profileImgView = UIImageView()
    // 프로필 닉네임 라벨
    var profileNicknameLbl = UILabel()
    // 로그인 필요 닉네임 라벨
    var profileNeedLoginLbl = UILabel()
    
    // 메인 콘텐츠 스크롤 뷰
    var scrollView = UIScrollView()
    var scrollContentView = UIView()
    
    var bottomTempView = UIView()
    
    var loadingIndicator = UIActivityIndicatorView(style: .large)


    private let viewDidLoadSubject = PublishSubject<Bool>()
    
    override func loadView() {
        print("loadView")
        
        initView()
        
    }
    
    /*
        상단 네비게이션 바 초기화
     */
    private func initNavigationBar() {
        print("네비 초기화")
        
        let settingBarBtn = UIBarButtonItem(customView: settingBtn)
        
        let titleBarBtn = UIBarButtonItem(customView: titleHeaderLbl)
            
        _ = windowNavigationController?.viewControllers.map({ viewcontroller in
            if viewcontroller is UITabBarController {
                viewcontroller.navigationItem.rightBarButtonItems = [settingBarBtn]
                viewcontroller.navigationItem.titleView = nil
                viewcontroller.navigationItem.leftBarButtonItems = [titleBarBtn]
            }
        })
        


    }
    
    private func initView() {
        
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .white
        
        // 네비게이션 초기화
        titleHeaderLbl.alpha = 0.0
        titleHeaderLbl.text = "마이페이지"
        settingBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        
        scrollView.delegate = self
        scrollView.backgroundColor = .green
        self.view.addSubview(scrollView)
        
        scrollContentView.backgroundColor = .brown
        scrollView.addSubview(scrollContentView)
        
        stickyHeaderView.backgroundColor = .white
        scrollContentView.addSubview(stickyHeaderView)
        
        profileImgView.image = UIImage(named: "")
        profileImgView.backgroundColor = .lightGray
        profileImgView.layer.cornerRadius = 40
        profileImgView.clipsToBounds = true
        profileImgView.isHidden = true
        stickyHeaderView.addSubview(profileImgView)
        
        profileNicknameLbl.text = "닉네임"
        profileNicknameLbl.textColor = .black
        profileNicknameLbl.isHidden = true
        stickyHeaderView.addSubview(profileNicknameLbl)
        
        profileNeedLoginLbl.text = "로그인을 해주세요."
        profileNeedLoginLbl.textColor = .black
        profileNeedLoginLbl.isHidden = true
        stickyHeaderView.addSubview(profileNeedLoginLbl)
        
        bottomTempView.backgroundColor = .lightGray
        scrollContentView.addSubview(bottomTempView)
        
        
        self.view.addSubview(loadingIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationBar()
        
        viewDidLoadSubject.onNext(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        
        initConstraint()
        
        
    }
    
    deinit {
        print("ProfileTabViewController deinit")
    }
    
    func initConstraint() {
        
        scrollView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            
        }
        
        stickyHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(Const.headerMaxHeight)
        }
        
        profileImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
        }
        
        profileNicknameLbl.snp.makeConstraints { make in
            make.centerY.equalTo(profileImgView)
            make.leading.equalTo(profileImgView.snp.trailing).offset(32)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        profileNeedLoginLbl.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
        }
        
        bottomTempView.snp.makeConstraints { make in
            make.top.equalTo(stickyHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(2000)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
    }
    
    
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: ProfileTabViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: ProfileTabViewReactor) {
        //action
        viewDidLoadSubject.asObserver()
            .map { _ in
                return Reactor.Action.loadView
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        settingBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToProfileSetting
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: ProfileTabViewReactor) {
        //state
        
        // 닉네임 바인딩
        reactor.state
            .map { state in
                return state.userData.nickname
            }
            .distinctUntilChanged()
            .bind(to: profileNicknameLbl.rx.text)
            .disposed(by: disposeBag)
        
        // 프로필 사진 바인딩
        reactor.state
            .map { state in
                return URL(string: state.userData.profileImgUrl ?? "")
            }
            .bind(to: profileImgView.kf.rx.image())
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                return state.isLoading
            }
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                return !state.showNeedLogin
            }
            .bind(to: profileNeedLoginLbl.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                return state.showNeedLogin
            }
            .bind(to: profileImgView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                return state.showNeedLogin
            }
            .bind(to: profileNicknameLbl.rx.isHidden)
            .disposed(by: disposeBag)
        
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


extension ProfileTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var headerConstant = scrollView.contentOffset.y
        
        
        
        headerConstant = headerConstant < 0 ? 0 : headerConstant
        headerConstant = headerConstant > Const.headerMaxHeight ? Const.headerMaxHeight : headerConstant
        
        print(headerConstant)
        
//        stickyHeaderView.snp.updateConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-headerConstant)
////            make.top.equalToSuperview().offset(-headerConstant)
//        }
        
//        scrollView.snp.updateConstraints { make in
//            make.top.equalTo(stickyHeaderView.snp.bottom).offset(tableConstant)
//        }
        DispatchQueue.main.async {
//            self.titleHeaderLbl.isHidden = false
            self.titleHeaderLbl.alpha = headerConstant / Const.headerMaxHeight
        }
        
//        stickyHeaderView.alpha = 1 - headerConstant / Const.canMoveHeight
        
        
        
        
    }
}
