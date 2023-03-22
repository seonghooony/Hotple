//
//  ProfileSettingViewController.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/20.
//

import UIKit
import SnapKit
import RxFlow
import RxCocoa
import ReactorKit
import RxDataSources

class ProfileSettingViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = ProfileSettingViewReactor
    
    weak var windowNavigationController: UINavigationController?

    var backBtn = UIButton()
    
    var menuTableView = UITableView().then {
        $0.register(ProfileSettingMenuCell.self, forCellReuseIdentifier: ProfileSettingMenuCell.reuseIdentifier)
//        $0.rowHeight = UITableView.automaticDimension
    }

    // 상단 네비게이션 타이틀 라벨
    var titleHeaderLbl: UILabel = {
        let label = UILabel()
        label.text = "설정"
        return label
    }()
    
    private let viewDidLoadSubject = PublishSubject<Bool>()
    
    deinit {
        print("ProfileSettingViewController deinit")
    }
    
    override func loadView() {
        let view = UIView()
        
        initView()
        
    }
    
    private func initView() {
        
        let view = UIView()
        
        self.view = view
        
        self.view.backgroundColor = .white

        backBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        
        self.view.addSubview(menuTableView)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initNavigationBar()

    }
    
    /*
        상단 네비게이션 바 초기화
     */
    private func initNavigationBar() {
        print("네비 초기화")
//        titleLbl.text = "마이페이지"
//        titleLbl.alpha = 0.0

        let backBarBtn = UIBarButtonItem(customView: backBtn)
        
        self.navigationItem.leftBarButtonItems = [backBarBtn]
        self.navigationItem.titleView = titleHeaderLbl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadSubject.onNext(true)
        
        initConstraint()
    }
    
    
    
    func initConstraint() {
        
        menuTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureTableViewCell(tableView: UITableView, indexPath: IndexPath, item: ProfileSettingSection.ItemType) -> UITableViewCell {
        switch item {
        case .info(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingMenuCell.reuseIdentifier, for: indexPath) as! ProfileSettingMenuCell
//            cell.selectionStyle = .none
            cell.setData(data)
            return cell
        }
    }
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: ProfileSettingViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        
    }
    
    
    func bindAction(_ reactor: ProfileSettingViewReactor) {
        //action
        menuTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewDidLoadSubject.asObserver()
            .map { _ in
                return Reactor.Action.loadView
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backBtn.rx.tap
            .map { _ in
                return Reactor.Action.clickToBack
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        menuTableView.rx.itemSelected
            .map { [weak self] indexPath in
                self?.menuTableView.deselectRow(at: indexPath, animated: true)
                return Reactor.Action.clickCell(indexPath)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
//        kakaoBtn.rx.tap
//            .map { _ in
//                return Reactor.Action.clickToKakao
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        

        
    }
    
    
    func bindState(_ reactor: ProfileSettingViewReactor) {
        //state
        
        let dataSource = RxTableViewSectionedReloadDataSource<ProfileSettingSection.Model> { dataSource, tableView, indexPath, item in
            return self.configureTableViewCell(tableView: tableView, indexPath: indexPath, item: item)
            
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionModels[index].model
            
            switch section {
            case .normal:
                return "기본"
            }
        }
        
        reactor.state.map { [$0.normalSection] }
            .distinctUntilChanged()
            
            .bind(to: self.menuTableView.rx.items(dataSource: dataSource))
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

extension ProfileSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
