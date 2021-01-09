//
//  DetailCafeMenuVC.swift
//  Milkyway
//
//  Created by soyounglee on 2021/01/04.
//

import UIKit
import SafariServices
import Alamofire

class DetailCafeMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addMyUniverseBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var universeImageView: UIImageView!
    
    
    // 일단 더미로 넣어놓은 데이터 ,,,
    var testCafe = CafeDatas(cafeInfo: CafeInfo(id: 0, cafeName: "", cafeAddress: "", businessHours: "", cafePhoneNum: "", cafeLink: "", honeyTip: []), menu: [Menu](), universeCount: 0)
    
    
    let cafeMenu = ["무지방우유","저지방우유","두유","디카페인"]
    var like: Bool = false
    
    
    
    // MARK: - 데이터 로딩 중 Lottie 화면
    private var loadingView: UIActivityIndicatorView?
    
    private func showLoadingLottie() {
        loadingView = UIActivityIndicatorView(style: .large)
        self.view.addSubview(loadingView!)
        loadingView?.center = self.view.center
        loadingView?.startAnimating()
    }
    
    private func stopLottieAnimation() {
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    
    
    // MARK: - 뷰
    
    
    override func viewWillAppear(_ animated: Bool) {
        showLoadingLottie()
        loadData()
        self.tableView.reloadData()
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        delegateFunc()
        cellResister()
        notiGather()
        
    }
    
    @IBAction func addMyUniverseBtnClicked(_ sender: Any) {
        like ? iHateYou() : iLoveYou()
        tableView.reloadSections(IndexSet(0...0), with: .none)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


// 어떤 '동작'을 할 지 정해주는 부분
// 이 row를 선택하면 어떤 일을 할까요?
extension DetailCafeMenuVC: UITableViewDelegate {
    
    
}


// 테이블 뷰의 뷰를 그려주는 역할
// 어떤 정보를 그려줄 건가요?
extension DetailCafeMenuVC: UITableViewDataSource {
    
    
    // section 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // section 별 행 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else {
            return testCafe.menu.count
        }
    }
    
    
    // section 행의 높이 -> 나중에는 이렇게 말고 ...
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 350
        }
        else if indexPath.section == 1 {
            return 260
        }
        else {
            return 70
        }
    }
    
    // cell 그려주기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { // cafe 기본정보
            
            
            guard let cell: CafeBasicCell = tableView.dequeueReusableCell(withIdentifier: "CafeBasicCell" , for: indexPath) as? CafeBasicCell else{
                return UITableViewCell()
            }
            cell.cafeNameLabel.text = testCafe.cafeInfo.cafeName
            cell.howManyLikeLabel.text = "\(testCafe.universeCount)명의 밀키들이 유니버스에 추가했어요"
            cell.locationLabel.text = testCafe.cafeInfo.cafeAddress
            cell.openTimeLabel.text = testCafe.cafeInfo.businessHours
            cell.telNumBtn.setTitle(testCafe.cafeInfo.cafePhoneNum, for: .normal)
            cell.webPageBtn.setTitle(testCafe.cafeInfo.cafeLink, for: .normal)
            cell.selectionStyle = .none // 셀 선택 불가능하게
            
            return cell
        }
        
        else if indexPath.section == 1 { // 밀키의 꿀팁
            guard let cell: CafeHoneyCell = tableView.dequeueReusableCell(withIdentifier: "CafeHoneyCell", for: indexPath) as? CafeHoneyCell else{
                return UITableViewCell()
            }
            
            // 꿀팁 -> 받아온 숫자에 해당하는 라벨 색 변경 (나중에는 이미지 변경으로 바꿀듯?)
            for i in testCafe.cafeInfo.honeyTip {
                (cell.viewWithTag(i) as? UILabel)?.textColor = UIColor(named: "Milky")
                (cell.viewWithTag(i) as? UILabel)?.layer.borderColor = UIColor(named: "Milky")?.cgColor
            }
            
            cell.selectionStyle = .none // 셀 선택 불가능하게
            return cell
        }
        
        else { // 카페 메뉴
            guard let cell: CafeMenuCell = tableView.dequeueReusableCell(withIdentifier: "CafeMenuCell", for: indexPath) as? CafeMenuCell else{
                return UITableViewCell()
            }
            
            cell.cafeMenuNameLabel.text = testCafe.menu[indexPath.row].menuName
            cell.categoryLabel.text = ""
            // 메뉴 하단에 선택지 표시
            for i in testCafe.menu[indexPath.row].category {
                cell.categoryLabel.text! += (cafeMenu[i-1] + "  ")
                
            }
            
            cell.howMuchLabel.text = testCafe.menu[indexPath.row].price
            cell.selectionStyle = .none // 셀 선택 불가능하게
            return cell
        }
        
        
    }
}


extension DetailCafeMenuVC {
    
    // 노티 옵저버들
    func notiGather() {
        NotificationCenter.default.addObserver(self, selector: #selector(webPageOpen), name: Notification.Name("webPage"), object: nil)
    }
    
    // 프로토콜 상속
    func delegateFunc() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // 셀 등록
    func cellResister() {
        
        // 셀 리소스 파일 가져오기
        let CafeBasicCellNib = UINib(nibName: "CafeBasicCell", bundle: nil)
        let CafeHoneyCellNib = UINib(nibName: "CafeHoneyCell", bundle: nil)
        let CafeMenuCellNib = UINib(nibName: "CafeMenuCell", bundle: nil)
        
        
        // 셀에 리소스 등록
        self.tableView.register(CafeBasicCellNib, forCellReuseIdentifier: "CafeBasicCell")
        self.tableView.register(CafeHoneyCellNib, forCellReuseIdentifier: "CafeHoneyCell")
        self.tableView.register(CafeMenuCellNib, forCellReuseIdentifier: "CafeMenuCell")
    }
    
    
    
    func iLoveYou() {
        ToastView.showIn(viewController: self, message: "카페가 나의 유니버스로 들어왔어요.", fromBottom: 40)
        testCafe.universeCount += 1
        universeImageView.image = UIImage(named: "btnUniverseAdded")
        likeLabel.text = "\(testCafe.universeCount)"
        likeLabel.textColor = UIColor(named: "Milky")
        likeLabel.font = UIFont(name: "SF Pro Text Bold", size: 8.0)!
        like = true
    }
    
    func iHateYou() {
        ToastView.showIn(viewController: self, message: "카페가 나의 유니버스를 탈출했어요.", fromBottom: 40)
        testCafe.universeCount -= 1
        universeImageView.image = UIImage(named: "btnUniverse")
        likeLabel.text = "\(testCafe.universeCount)"
        likeLabel.textColor = UIColor(named: "darkGrey")
        likeLabel.font = UIFont(name: "SF Pro Text Regular", size: 8.0)!
        like = false
    }
    
    // 셀에서 webPage버튼 누르면 여기서 실행 ... cell에서는 실행이 안되더라 흑흑
    // cell은 present를 할 수 없어서 그런듯
    @objc func webPageOpen() {
        
        guard let url = URL(string: "https://blog.naver.com/sso_0022") else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
        
    }
}

// MARK: Server Connect


extension DetailCafeMenuVC {
    
    func loadData() {
        
        print("loadData()")
        DetailCafeService.shared.DetailInfoGet(cafeId: 25) { (networkResult) -> (Void) in
            switch networkResult {
            case .success(let data):
                if let loadData = data as? CafeDatas {
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    print("success")
                    self.testCafe = loadData
                    self.tableView.reloadData()
                    self.stopLottieAnimation()
                  
                    
                }
            case .requestErr( _):
                print("requestErr")
            case .pathErr:

                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
            
            
        }
        
      
    }
}





