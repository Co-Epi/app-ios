import SwiftUI
import UIKit

class AlertDetailsViewController: UIViewController, ObservableObject {
    private let viewModel: AlertDetailsViewModel

    init(viewModel: AlertDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = L10n.Alerts.Details.title
    }

    required init?(coder _: NSCoder) {
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
        ScrollView {
            // Use LazyVStack in iOS 14
            VStack(alignment: .leading, spacing: 0) {
                Text(alertViewData.title)
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.coEpiPurple))
                    .padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.reportTime)
                    .font(.system(size: 13))
                    .fontWeight(.light)
                    .padding(.top, 4).padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.contactStart)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4).padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.contactDuration)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4).padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.avgDistance)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4).padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.minDistance)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4).padding(.leading, 38).padding(.trailing, 38)
                Text(alertViewData.symptoms)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .padding(.top, 8).padding(.leading, 38).padding(.trailing, 38)

                if !viewModel.linkedAlertsViewData.isEmpty {
                    Text(L10n.Alerts.Details.Header.otherExposures)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.coEpiPurple))
                        .padding(.top, 14).padding(.leading, 38).padding(.trailing, 38)
                        .padding(.bottom, 4)
                        .padding(.bottom, -6)
                }
                ForEach(viewModel.linkedAlertsViewData, id: \.alert.id) { alert in
                    linkedAlertRow(linkedAlert: alert)
                    if alert.bottomLine {
                        Divider().background(Color.black)
                    }
                }
            }.padding(.top, 20)
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
                    .cancel(),
                ]
            )
        }
    }

    private func linkedAlertRow(linkedAlert: LinkedAlertViewData) -> some View {
        HStack {
            ConnectionShape().generate(image: linkedAlert.image)
                .frame(minWidth: 12, maxWidth: 12)
            VStack(alignment: .leading) {
                Text(linkedAlert.date)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .padding(.top, 10)
                Text(alertViewData.contactStart)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Text(linkedAlert.contactDuration)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                Text(linkedAlert.symptoms)
                    .font(.system(size: 13))
                    .fontWeight(.light)
                    .padding(.top, 4).padding(.bottom, 12)
            }
        }
        .padding(.leading, 38).padding(.trailing, 38)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,
               alignment: .topLeading)
    }
}

private struct ConnectionShape {
    func generate(image: LinkedAlertViewDataConnectionImage) -> some View {
        switch image {
        case .top: return AnyView(topImage())
        case .body: return AnyView(bodyImage())
        case .bottom: return AnyView(bottomImage())
        }
    }

    private let lineLeft: Int = 6
    private let lineWidth: Int = 2
    private let circleSize: Int = 10
    private let lineGray: Color = Color(UIColor(hex: "979797"))

    func likeRect(y: Int, height: Int) -> CGRect {
        CGRect(x: lineLeft - lineWidth / 2,
               y: y,
               width: lineWidth,
               height: height)
    }

    func circleRect(y: Int) -> CGRect {
        CGRect(x: lineLeft - circleSize / 2,
               y: y,
               width: circleSize,
               height: circleSize)
    }

    private func topImage() -> some View {
        GeometryReader { geometry in
            Path { path in
                let topOffset: Int = 14
                path.addEllipse(in: circleRect(y: topOffset))
                path.addRect(likeRect(y: topOffset + circleSize / 2,
                                      height: Int(geometry.size.height) - topOffset))
            }
            .fill(lineGray)
            .frame(minWidth: 20, maxWidth: 20, minHeight: 0,
                   maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func bodyImage() -> some View {
        GeometryReader { geometry in
            Path { path in
                path.addRect(CGRect(x: lineLeft - lineWidth / 2, y: 0, width: lineWidth,
                                    height: Int(geometry.size.height)))
            }
            .fill(lineGray)
            .frame(minWidth: 20, maxWidth: 20, minHeight: 0,
                   maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func bottomImage() -> some View {
        GeometryReader { _ in
            Path { path in
                let height: Int = 14
                path.addEllipse(in: circleRect(y: height))
                path.addRect(likeRect(y: 0, height: height))
            }
            .fill(lineGray)
            .frame(minWidth: 20, maxWidth: 20, minHeight: 0,
                   maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
