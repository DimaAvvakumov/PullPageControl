# PullPageControl

## Why use PullPageControl?

Pull to refresh and infinity scroll is a standart in development industry for ios mobile plathorm. 
Apple provide default component for pull to refresh - `UIRefreshControl`. But it is boring and ugly.

## How to install

You can install via `cocoapods` with using special source:
```javascript
source 'https://github.com/DimaAvvakumov/Specs'

pod 'PullPageControl'
```

## How to use

1. Object of class `PullPageControl` response for control
 - It interact with `UIScrollView` or `UITableView`
 - Observed for contentOffset
 - It has 3 common state (normal, refresh, pageLoading)
 - Control can generate (triggered) two events: "start refreshing" and "load next page",
   ❗️But, for the switch between states response UIViewController or ViewModel (based on architect)

2. Let's configure one time for the project:
```swift
extension PullPageControl {
    
    class func standart(scrollView:UIScrollView) -> PullPageControl {
        let control = PullPageControl(scrollView: scrollView)
        
        // refresh
        let refreshView = ProgressCircleView(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        control.refreshView = refreshView
        
        return control
    }
    
}
```

3. Next, simple connect to UIViewController:
```swift
class ViewController: UIViewController {
    
    // Outlets
    @IBOutlet var tableView: UITableView!

    // Pull Refresh
    var pullPageControl: PullPageControl!

    // MARK:- Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullPageControl = PullPageControl.standart(scrollView: tableView)
        pullPageControl.setup()
    }

}
```

4. Then, start to observed for events...
```swift
    pullPageControl.refreshEvent.asObservable().subscribe(onNext: { [weak self] (event) in
        // send signal to ViewModel
    }).disposed(by: bag)
```

5. ...and send switch state commands
```swift
    pullPageControl.state.accept( .refreshing )
```

