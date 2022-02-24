//
//  bad_bass_vc.swift
//  NuoTePracticeSwift
//
//  Created by ZhiF_Zhu on 2022/2/19.
//

import UIKit

//模型
struct my_model {
    var id: Int
    var title: String
}

//数据源代理
class MY_DATA: NSObject,UITableViewDataSource {
    enum STATE {
        case Loading
        case Loaded
        
    }
    private var row_num = 0
    private(set) var array = [my_model]()
    private var state:STATE = .Loading{
        didSet{
            state_change?(state)
        }
    }
    var state_change : ((STATE)->Void)?
    
    //初始化
    init(num: Int, tv: UITableView, stateDidChange: ((STATE) -> Void)?) {
        self.row_num = num
        self.state_change = stateDidChange
        super.init()

        //注册cell
        tv.register(bad_cell.self, forCellReuseIdentifier: String(describing: bad_cell.self))
        tv.register(bade_cell__2.self, forCellReuseIdentifier: String(describing: bade_cell__2.self))
        
    }
    
    //宏替换
    subscript(_ indexPath: IndexPath) -> my_model { array[indexPath.row] }
    func make_data(){
        state = .Loading
        print("开始加载")

        //全局队列(这里有问题)
        DispatchQueue.global().asyncAfter(deadline: .now()+0.5){
            self.array = (0..<self.row_num).map { my_model(id: $0, title: self.get_magic_value(index: $0).description) }
            DispatchQueue.main.sync {
                self.state = .Loaded
                print("结束加载")
            }
        }
    }
    
    //生成一组随机数
    private func get_magic_value(index: Int) -> Int { switch index {
    ///f(n)={
    ///1, n = 1,2,3;
    ///f(n-1) + f(n-2) + f(n-3), n > 3 }
    ///- Returns: The magic value
    case 1:
    return 1
    case 2:
    return 1
    case 3:
    return 1
    default:
    if index < 0 { return 0 }
    return get_magic_value(index: index - 3)
    + get_magic_value(index: index - 2)
    + get_magic_value(index: index - 1) }
    }
    
    //刷新UI
    private func update_ui(elems: [my_model]) {
        //拼接数据源
        self.array.append(contentsOf: elems)
        //这里有问题（添加回到主线程刷新UI）
        DispatchQueue.main.sync {
            self.state = .Loaded
        }
    }
    
    //数据源代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //为什么这里返回的数据源数组为0
        return self.array.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //最后一个cell的样式
        if indexPath.row == self.array.count {
            //判空
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: bade_cell__2.self), for: indexPath) as? bade_cell__2 else { fatalError() }
            cell.block = {
                print("点击了")
                self.state = .Loading

                //全局队列(这里有问题)
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    let s = (self.row_num..<self.row_num+20).map {
                        my_model(id: $0, title:self.get_magic_value(index: $0).description)
                    }
                    self.update_ui(elems: s)
                }
                
            }
            cell.btn.isHidden = self.state == .Loading
            return cell
        }
        
        //判空
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:
        bad_cell.self), for: indexPath) as? bad_cell else { fatalError() }
        
//        let model = self.array[indexPath.row]
//        print(model)
//        cell.k_label.text = model.id.description
//        cell.v_label.text = model.title

        cell.k_label.text = indexPath.row.description
        cell.v_label.text = self[indexPath].title

        return cell
        
    }

}

//基类样式
private class my_bass_cell: UITableViewCell {}

//子类cellA
private final class bad_cell: my_bass_cell {
    let k_label: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    let v_label: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier)
        make_ui()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        private func make_ui() {
            k_label.frame = CGRect(x: 0, y: 0, width: self.frame.size.width/2, height: self.frame.size.height)
            v_label.frame = CGRect(x: k_label.frame.size.width, y: 0, width: self.frame.size.width/2, height: self.frame.size.height)
        let views = [k_label, v_label]
        for i in 0..<views.count {
            self.addSubview(views[i])
        }
        //这里有问题
//        NSLayoutConstraint.activate([k_label.topAnchor.constraint(equalTo: contentView.topAnchor,
//        constant: 8),k_label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),k_label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)])
//        NSLayoutConstraint.activate([v_label.leftAnchor.constraint(equalTo: k_label.rightAnchor, constant: 8),v_label.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),v_label.centerYAnchor.constraint(equalTo: k_label.centerYAnchor)
//        ])
            
    }
    
}

public typealias CallBack_Normal = ()->Void

//子类cellB
private final class bade_cell__2: my_bass_cell {
    //定义一个block
    var block: CallBack_Normal?
//    var block: (() -> Void)?
    let btn: UIButton = {
        let b = UIButton()
        b.isUserInteractionEnabled = true
        b.setTitle("tap to load more", for: .normal)
        b.setTitleColor(.systemGreen, for: .normal)
        b.addTarget(self, action: #selector(sel), for: .touchUpInside)
        return b
    }()
    @objc func sel() {
        print("****")
        if block != nil {
            block!()
        }
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier)
        make_ui()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func make_ui() {
        btn.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(btn)
        
        //这里有问题
//        NSLayoutConstraint.activate([btn.topAnchor.constraint(equalTo:
//    contentView.topAnchor),btn.leftAnchor.constraint(equalTo: contentView.leftAnchor),btn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),btn.rightAnchor.constraint(equalTo: contentView.rightAnchor)])
        
    }
    
}

//基类VC
class bad_bass_vc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "首页"
        view.backgroundColor = .systemBlue
        requiredScreenViewTrack()
        // Do any additional setup after loading the view.
    }
    
    func requiredScreenViewTrack() {
        // some code
        
    }

}

//子类VC
final class bad_vc: bad_bass_vc {
    private let tv = UITableView()

    //初始化数据模型
    private lazy var ds = MY_DATA(num: 30, tv: tv) {
        s in self.reload(s)
        
    }

    //创建加载圈
    private let loader:UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.color = .systemRed
        v.style = .large
        return v
    }()
    
    override func viewDidLoad() {
        make_ui()//创建视图
        ds.make_data()//加载数据

    }
    
    func make_ui(){
        tv.frame = view.bounds;
        tv.dataSource = ds;
        view.addSubview(tv)

        NSLayoutConstraint.activate([tv.leftAnchor.constraint(equalTo: view.leftAnchor),tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),tv.topAnchor.constraint(equalTo: view.topAnchor),tv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
    
    //重载tv
    private func reload(_ s: MY_DATA.STATE) {
        
        if s == MY_DATA.STATE.Loaded {//加载完毕
            tv.isUserInteractionEnabled = true
            loader.removeFromSuperview()
        }else if s == MY_DATA.STATE.Loading{//加载中
            tv.isUserInteractionEnabled = false
            view.addSubview(loader)
            loader.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([loader.centerXAnchor.constraint(equalTo:
            view.centerXAnchor),loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
            loader.startAnimating()

        }
        
        tv.reloadData()
    }
    
}
