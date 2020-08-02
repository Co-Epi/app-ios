import Dip
import UIKit

class DebugViewController: UIViewController {
    private let container: DependencyContainer

    @IBOutlet var tabs: UISegmentedControl!
    @IBOutlet var pagerContainer: UIView!

    private var pagerViewController: DebugPageViewController?

    init(container: DependencyContainer) {
        self.container = container
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPager()
    }

    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        // quick & dirty switch between page 0 and 1
        switch sender.selectedSegmentIndex {
        case 0: pagerViewController?.goToPreviousPage()
        case 1: pagerViewController?.goToNextPage()
        default: fatalError("Not supported: \(sender.selectedSegmentIndex)")
        }
    }

    private func addPager() {
        let viewController = DebugPageViewController(
            container: container) { [weak self] pageIndex in
            self?.tabs.selectedSegmentIndex = pageIndex
        }
        pagerContainer.addSubview(viewController.view)
        viewController.view.pinAllEdgesToParent()
        addChild(viewController)
        viewController.didMove(toParent: self)
        pagerViewController = viewController
    }
}

class DebugPageViewController:
    UIPageViewController,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{
    private let container: DependencyContainer!

    var pages = [UIViewController]()
    let pageControl = UIPageControl()

    private var onPageChanged: (Int) -> Void

    init(
        container: DependencyContainer,
        onPageChanged: @escaping ((Int)
            -> Void)
    ) {
        self.container = container
        self.onPageChanged = onPageChanged

        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    )
        -> UIViewController?
    {
        if let index = pages.firstIndex(of: viewController) {
            if index > 0 {
                return pages[index - 1]
            }
        }
        return nil
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    )
        -> UIViewController?
    {
        if let index = pages.firstIndex(of: viewController) {
            if index < pages.count - 1 {
                return pages[index + 1]
            }
        }
        return nil
    }

    func goToNextPage(animated: Bool = true) {
        guard let current = viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(
            self,
            viewControllerAfter: current
        )
        else { return }
        setViewControllers(
            [nextViewController],
            direction: .forward,
            animated: animated,
            completion: nil
        )
    }

    func goToPreviousPage(animated: Bool = true) {
        guard let current = viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(
            self,
            viewControllerBefore: current
        )
        else { return }
        setViewControllers(
            [previousViewController],
            direction: .reverse,
            animated: animated,
            completion: nil
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        let initialPage = 0

        let debugBleViewModel: DebugBleViewModel = try! container.resolve()
        let logsViewModel: LogsViewModel = try! container.resolve()

        pages.append(DebugBleViewController(viewModel: debugBleViewModel))
        pages.append(LogsViewController(viewModel: logsViewModel))

        setViewControllers(
            [pages[initialPage]],
            direction: .forward,
            animated: true,
            completion: nil
        )
    }

    func pageViewController(
        _: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted _: Bool
    ) {
        guard let viewControllers = viewControllers else { return }
        if let index = pages.firstIndex(of: viewControllers[0]) {
            onPageChanged(index)
        }
    }
}
