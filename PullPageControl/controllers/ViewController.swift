//
//  ViewController.swift
//  PullPageControl
//
//  Created by Avvakumov Dmitry on 15.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    typealias SectionType = AnimatableSectionModel<String, TableRow>
    
    @IBOutlet var tableView: UITableView!

    // Public
    var bag = DisposeBag()
    
    // Data
    let tableData = BehaviorRelay<[SectionType]>(value: [])
    
    // Pull Refresh
    var pullPageControl: PullPageControl!
    
    lazy private var dataSource:RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, TableRow>> = {
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, TableRow>> (
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .none, deleteAnimation: .automatic),
            configureCell: {[weak self] ds, tv, indexPath, element in
                let identifier = element.cellIdentifier
                let cell = tv.dequeueReusableCellWithRaw(element, indexPath: indexPath)
                if let c = cell as? TableCellProtocol {
                    c.configureWithModel(model: element, animated: true)
                }
                
                return cell
        })
        
    }()
    
    // MARK:- Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullPageControl = PullPageControl.standart(scrollView: tableView)
        tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableModelCell")
        
        setupRx()
        pullPageControl.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRx() {
        tableData
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        pullPageControl.refreshEvent.asObservable().subscribe(onNext: { [weak self] (event) in
            self?.pullPageControl.state.accept(.refreshing)
        }).disposed(by: bag)
        pullPageControl.nextPageEvent.asObservable().subscribe(onNext: { [weak self] (event) in
            self?.pullPageControl.state.accept(.loadingPage)
        }).disposed(by: bag)
    }
    
    @IBAction func appendAction(_ sender: UIBarButtonItem) {
        tableData.accept([SectionType(model: "Simple", items: initData())])
    }
    @IBAction func stopAction(_ sender: UIBarButtonItem) {
        pullPageControl.state.accept( .normal(isNext: true) )
    }
    
    func initData() -> [TableRow] {
        var data: [TableRow] = []
        for i in 0..<20 {
            data.append( TableModel(itemId: i, title: "Text - \(i)") )
        }
        
        return data
    }

}

