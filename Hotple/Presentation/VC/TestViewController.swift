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


class TestViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = TestViewReactor
    
    var windowNavigationController: UINavigationController?
    
    // 상단 프로필 헤더뷰
    var stickyHeaderView = UIView()
    // 프로필 이미지 뷰
    var profileImgView = UIImageView()
    // 프로필 닉네임 뷰
    var profileNicknameLbl = UILabel()
    
    // 상단 네비 뷰
    var headerView = UIView()
    // 헤더 라벨 뷰
    var headerLbl = UILabel()
    
    // 세팅 버튼
    var settingBtn = UIButton()
    
    
    // 메인 콘텐츠 스크롤 뷰
    var scrollView = UIScrollView()
    var scrollContentView = UIView()


    
    override func loadView() {
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .white
        
        headerView.backgroundColor = .white
        headerView.alpha = 0.0
        self.view.addSubview(headerView)
        
        headerLbl.text = "마이페이지"
        headerLbl.textColor = .black
        self.headerView.addSubview(headerLbl)
        
        stickyHeaderView.backgroundColor = .white
        self.view.addSubview(stickyHeaderView)
        
        profileImgView.image = UIImage(named: "")
        profileImgView.backgroundColor = .lightGray
        profileImgView.layer.cornerRadius = 40
        profileImgView.clipsToBounds = true
        stickyHeaderView.addSubview(profileImgView)
        
        profileNicknameLbl.text = "닉네임"
        profileNicknameLbl.textColor = .black
        stickyHeaderView.addSubview(profileNicknameLbl)
        
        settingBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
//        settingBtn.backgroundColor = .black
        self.view.addSubview(settingBtn)
        
        scrollView.delegate = self
        scrollView.backgroundColor = .green
        self.view.addSubview(scrollView)
        
        scrollContentView.backgroundColor = .brown
        scrollView.addSubview(scrollContentView)
        

        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraint()
    }
    
    deinit {
        print("ProfileTabViewController deinit")
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
        
        stickyHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
//            make.top.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(Const.headerMaxHeight)
        }
        
        profileImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44 + 16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
        }
        
        profileNicknameLbl.snp.makeConstraints { make in
            make.centerY.equalTo(profileImgView)
            make.leading.equalTo(profileImgView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        settingBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(2)
            make.width.height.equalTo(40)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(stickyHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(2000)
        }
        

        
        
    }
    
    
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: TestViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: TestViewReactor) {
        //action
//        settingBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToProfileSetting
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: TestViewReactor) {
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


extension TestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var headerConstant = scrollView.contentOffset.y
        var tableConstant = CGFloat()
        
        print(headerConstant)
        
        headerConstant = headerConstant < 0 ? 0 : headerConstant
        headerConstant = headerConstant > Const.canMoveHeight ? Const.canMoveHeight : headerConstant
        
        tableConstant = Const.headerMaxHeight - ( ((headerConstant - 0) / Const.canMoveHeight) * (Const.headerMaxHeight - Const.canMoveHeight) )
        
        stickyHeaderView.snp.updateConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-headerConstant)
//            make.top.equalToSuperview().offset(-headerConstant)
        }
        
//        scrollView.snp.updateConstraints { make in
//            make.top.equalTo(stickyHeaderView.snp.bottom).offset(tableConstant)
//        }
        
        stickyHeaderView.alpha = 1 - headerConstant / Const.canMoveHeight
        headerView.alpha = headerConstant / Const.canMoveHeight
        
        
        
    }
}
