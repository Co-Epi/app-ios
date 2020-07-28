import UIKit
import SwiftUI

class AlertDetailsViewController: UIViewController, ObservableObject {
    private let viewModel: AlertDetailsViewModel

    init(viewModel: AlertDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = L10n.Alerts.Details.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setRootSwiftUIView(view: AlertDetailsView(viewModel: viewModel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "more"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(moreTapped))
    }

    @objc
    func moreTapped() {
        viewModel.showActionSheet()
    }
}

struct AlertDetailsView: View {
    @ObservedObject var viewModel: AlertDetailsViewModel

    private var alertViewData: AlertDetailsViewData { viewModel.viewData }

    init(viewModel: AlertDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 4) {
                Text(alertViewData.title)
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.coEpiPurple))
                Text(alertViewData.reportTime)
                    .font(.system(size: 13))
                    .fontWeight(.light)
                Text(alertViewData.contactDuration)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                Text(alertViewData.avgDistance)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Text(alertViewData.minDistance)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Text(alertViewData.symptoms)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .padding(.top, 4)
            }
            .padding(EdgeInsets(top: 20, leading: 38, bottom: 20, trailing: 38))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .actionSheet(isPresented: $viewModel.showingActionSheet) {
            ActionSheet(
                title: Text(L10n.Alerts.Details.More.title),
                buttons: [
                    .default(Text(L10n.Alerts.Details.More.delete)) {
                        self.viewModel.delete()
                    },
                    .destructive(Text(L10n.Alerts.Details.More.reportProblem)) {
                        self.viewModel.reportProblemTapped()
                    },
                    .cancel()
            ])
        }
    }
}
