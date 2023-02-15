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
import Then

class ProfileTabViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = ProfileTabViewReactor
    
    var stickyHeaderView = UIView()
    var headerView = UIView()
    var scrollView = UIScrollView()
    var scrollContentView = UIView()
    var optionTableView = UITableView()
        .then {
            $0.separatorStyle = .none
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
        }

    
    override func loadView() {
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .white
        
        headerView.backgroundColor = .red
        self.view.addSubview(headerView)
        
        stickyHeaderView.backgroundColor = .blue
        self.view.addSubview(stickyHeaderView)
        
        scrollView.delegate = self
        scrollView.backgroundColor = .green
        self.view.addSubview(scrollView)
        
        scrollContentView.backgroundColor = .brown
        scrollView.addSubview(scrollContentView)
        
//        optionTableView.delegate = self
//        optionTableView.dataSource = self
//        optionTableView.backgroundColor = .brown
//        optionTableView.register(InteriorAdItemCell.self, forCellReuseIdentifier: "InteriorAdItemCell")
//        scrollContentView.addSubview(optionTableView)
        
       
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
            make.height.equalTo(Const.naviBarHeight)
        }
        stickyHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
//            make.top.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(Const.headerMaxHeight)
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
        
//        optionTableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        
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
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: ProfileTabViewReactor) {
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

//extension ProfileTabViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: InteriorAdItemCell.reuseIdentifier, for: indexPath) as! InteriorAdItemCell
////        let cell = UITableViewCell()
////        cell.backgroundColor = .black
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//
//        return 144.0
//    }
//
//}

extension ProfileTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var headerConstant = scrollView.contentOffset.y
        var tableConstant = CGFloat()
        
        print(headerConstant)
        
        headerConstant = headerConstant < 0 ? 0 : headerConstant
        headerConstant = headerConstant > Const.headerMinHeight ? Const.headerMinHeight : headerConstant
        
        tableConstant = Const.headerMaxHeight - ( ((headerConstant - 0) / Const.headerMinHeight) * (Const.headerMaxHeight - Const.headerMinHeight) )
        
        stickyHeaderView.snp.updateConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-headerConstant)
//            make.top.equalToSuperview().offset(-headerConstant)
        }
        
//        scrollView.snp.updateConstraints { make in
//            make.top.equalTo(stickyHeaderView.snp.bottom).offset(tableConstant)
//        }
        
        stickyHeaderView.alpha = 1 - headerConstant / Const.headerMinHeight
        headerView.alpha = headerConstant / Const.headerMinHeight
        
        
        
    }
}
