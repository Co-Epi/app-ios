import UIKit
import RxSwift
import RxCocoa
import SwiftUI

class BreathlessViewController: UIViewController {
    private let viewModel: BreathlessViewModel

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var skipButtonLabel: UIButton!

    @IBAction func skipButtonAction(_ sender: Any) {
        viewModel.onSkipTap()
    }

    private let disposeBag = DisposeBag()

    init(viewModel: BreathlessViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            viewModel.onBack()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
        setRootSwiftUIView(view: BreathlessView(viewModel: viewModel))
    }

    func setFoo(hostView: UIView) {
        hostView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostView)
        hostView.pinAllEdgesToParent()
    }
}

struct BreathlessView: View {
    @ObservedObject var viewModel: BreathlessViewModel

    init(viewModel: BreathlessViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header()
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.viewData, id: \.cause) { item in
                        itemRow(item: item)
                    }
                    .padding(.top, 30)
                    .padding(.leading, 30).padding(.trailing, 30)

                    Button(action: {
                        viewModel.onSkipTap()
                    }, label: {
                        Text(L10n.Ux.skip)
                            .font(.system(size: 13))
                            .foregroundColor(Color.black)
                    })
                    .padding(.top, 30).padding(.leading, 30).padding(.trailing, 30)
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }

    private func header() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.Ux.Breathless.title)
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(L10n.Ux.Breathless.subtitle)
                .font(.system(size: 13))
                .foregroundColor(.white)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100,
               maxHeight: 100, alignment: .topLeading)
        .padding(.top, 20).padding(.leading, 20).padding(.trailing, 20)
        .background(Color(UIColor.coEpiPurple))
    }

    private func itemRow(item: BreathlessItemViewData) -> some View {
        HStack(spacing: 16) {
            Image(item.imageName)
                .frame(minWidth: 40, maxWidth: 40, minHeight: 40, maxHeight: 40)
                .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(UIColor.coEpiPurpleHighlighted), lineWidth: 1))
            Text(item.text)
                .font(.system(size: 17))
                .fontWeight(.semibold)
        }
        .onTapGesture {
            viewModel.onCauseSelected(viewData: item)
        }
    }
}
