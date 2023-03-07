//
//  PopUpController.swift
//  UniversalPopUp
//
//  Created by Vlad Kulakovsky  on 14.02.23.
//

import UIKit
import SnapKit

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
        view.backgroundColor = configuration.backgroundColor
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
        label.insets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        label.numberOfLines = 0
        label.text = configuration.title
        label.textColor = configuration.titleColor
        label.font = configuration.titleFont
        label.textAlignment = .center
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = PaddingLabel()
        label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        label.numberOfLines = 0
        label.text = configuration.description
        label.textColor = configuration.descriptionColor
        label.font = configuration.descriptionFont
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
        button.backgroundColor = configuration.buttonBackgroundColor
        button.tintColor = configuration.dismissButtonTintColor
        button.titleLabel?.font = configuration.buttonFonts
        button.setTitle(configuration.dismissButtonTitle, for: .normal)
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
        button.backgroundColor = configuration.buttonBackgroundColor
        button.tintColor = configuration.confirmButtonTintColor
        button.titleLabel?.font = configuration.buttonFonts
        button.setTitle(configuration.confirmButtonTitle, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(cancelAction),
            for: .touchUpInside
        )
        button.backgroundColor = configuration.buttonBackgroundColor
        button.tintColor = configuration.cancelButtonTintColor
        button.titleLabel?.font = configuration.buttonFonts
        button.setTitle(configuration.cancelButtonTitle, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var popUpImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = configuration.image
        imageView.tintColor = configuration.imageTintColor
        return imageView
    }()
    
    lazy var inputField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = configuration.inputPlaceHolder
        return textField
    }()
    
    private var confirmHandler: VoidBlock?
    private var dismissHandler: VoidBlock?
    private weak var delegate: PopUpControllerDelegate?
    private var configuration : PopUpConfiguration = .standart
    
    init(confirmHandler: VoidBlock? = nil,
         dismissHandler: VoidBlock? = nil,
         config: PopUpConfiguration = .standart
    ) {
        self.configuration = config
        self.confirmHandler = confirmHandler
        self.dismissHandler = dismissHandler
        super .init(nibName: nil, bundle: nil)
        initView()
    }
    
    init(delegate: PopUpControllerDelegate,
         config: PopUpConfiguration = .standart
    ) {
        self.delegate = delegate
        self.configuration = config
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
        mainStack.addArrangedSubview(cancelButton)
        
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func setupStyle() {
        switch configuration.style {
            case .info:
                dismissButton.isHidden = true
                imageContrainerView.isHidden = true
                inputField.isHidden = true
                cancelButton.isHidden = true
            case .input:
                imageContrainerView.isHidden = true
                cancelButton.isHidden = true
            case .error:
                inputField.isHidden = true
                dismissButton.isHidden = true
                cancelButton.isHidden = true
            case .confirmation:
                inputField.isHidden = true
                cancelButton.isHidden = true
            case .threeButtons:
                inputField.isHidden = true
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
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
    }
    
    @objc private func dismissAction() {
        self.dismiss(animated: true) {
            self.dismissHandler?()
            self.delegate?.dismissAction()
        }
    }
    
    @objc private func confirmAction() {
        self.dismiss(animated: true) {
            self.confirmHandler?()
            self.delegate?.confirmAction()
        }
    }
    
    @objc private func cancelAction() {
        self.dismiss(animated: true)
    }
}
