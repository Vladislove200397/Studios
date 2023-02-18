//
//  PopUpController.swift
//  UniversalPopUp
//
//  Created by Vlad Kulakovsky  on 14.02.23.
//

import UIKit
import SnapKit
typealias VoidBlock = (() -> Void)
protocol PopUpControllerDelegate: AnyObject {
    func dismissAction()
    func confirmAction()
}

class PopUpController: UIViewController {
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = confiuration.backgroundColor
        view.clipsToBounds = true
        view.layer.borderWidth = 0.7
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var imageContrainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        label.numberOfLines = 0
        label.text = confiuration.title
        label.textColor = confiuration.titleColor
        label.font = confiuration.titleFont
        label.textAlignment = .center
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = PaddingLabel()
        label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        label.numberOfLines = 0
        label.text = confiuration.description
        label.textColor = confiuration.descriptionColor
        label.font = confiuration.descriptionFont
        label.textAlignment = .center
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(dismissAction),
            for: .touchUpInside
        )
        button.backgroundColor = confiuration.buttonBackgroundColor
        button.tintColor = confiuration.dismissButtonTintColor
        button.titleLabel?.font = confiuration.buttonFonts
        button.setTitle(confiuration.dismissButtonTitle, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var confirmationButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(
            self,
            action: #selector(confirmAction),
            for: .touchUpInside
        )
        button.backgroundColor = confiuration.buttonBackgroundColor
        button.tintColor = confiuration.confirmButtonTintColor
        button.titleLabel?.font = confiuration.buttonFonts
        button.setTitle(confiuration.confirmButtonTitle, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var popUpImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = confiuration.image
        imageView.tintColor = confiuration.imageTintColor
        return imageView
    }()
    
    lazy var inputField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = confiuration.inputPlaceHolder
        return textField
    }()
    
    private var confirmHandler: VoidBlock?
    private var dismissHandler: VoidBlock?
    private weak var delegate: PopUpControllerDelegate?
    private var confiuration : PopUpConfiguration = .standart
    
    init(confirmHandler: VoidBlock? = nil,
         dismissHandler: VoidBlock? = nil,
         config: PopUpConfiguration = .standart
    ) {
        self.confiuration = config
        self.confirmHandler = confirmHandler
        self.dismissHandler = dismissHandler
        super .init(nibName: nil, bundle: nil)
        initView()
    }
    
    init(delegate: PopUpControllerDelegate,
         config: PopUpConfiguration = .standart
    ) {
        self.delegate = delegate
        self.confiuration = config
        super .init(nibName: nil, bundle: nil)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeConstraints()
        setupStyle()
    }
    
    private func setupUI() {
        self.view.addBlurredBackground(style: .dark, alpha: 0.2, blurColor: .black)
        self.view.addSubview(mainView)
        mainView.addSubview(mainStack)
        imageContrainerView.addSubview(popUpImage)
        mainStack.addArrangedSubview(imageContrainerView)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(inputField)
        mainStack.addArrangedSubview(buttonStack)
        buttonStack.addArrangedSubview(dismissButton)
        buttonStack.addArrangedSubview(confirmationButton)
        
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func setupStyle() {
        switch confiuration.style {
            case .info:
                dismissButton.isHidden = true
                imageContrainerView.isHidden = true
                inputField.isHidden = true
            case .input:
                imageContrainerView.isHidden = true
            case .error:
                inputField.isHidden = true
                dismissButton.isHidden = true
            case .confirmation:
                inputField.isHidden = true
                imageContrainerView.isHidden = true
        }
    }
    
    private func makeConstraints() {
        let mainViewEdges = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(mainViewEdges)
            make.center.equalToSuperview()
        }
        
        let mainStackEdges = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(mainStackEdges)
        }
        
        popUpImage.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        confirmationButton.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
    }
    
    @objc private func dismissAction() {
        self.dismissHandler?()
        self.delegate?.dismissAction()
        self.dismiss(animated: true)
    }
    
    @objc private func confirmAction() {
        self.confirmHandler?()
        self.delegate?.confirmAction()
        self.dismiss(animated: true)
    }
}
