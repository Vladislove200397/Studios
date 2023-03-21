//
//  FlexView.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import UIKit
import SnapKit

final class FlexView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    weak var delegate: FlexibleViewDelegate?
    private(set) var isOpen = false {
        didSet {
            animation()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let id = String(describing: FlexView.self)
        Bundle.main.loadNibNamed(id, owner: self)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        containerView.isHidden = !self.isOpen
        contentView.layer.cornerRadius = 10
    }
    
    func set(
        delegate: FlexibleViewDelegate?,
        weekdayText: [String]
    ) {
        self.delegate = delegate
        self.setupButton()
        addWeekdaytext(from: weekdayText)
    }
    
    private func addWeekdaytext(from array: [String]) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        
        containerView.addSubview(stack)
        
        array.forEach { text in
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.text = text.firstUppercased
            stack.addArrangedSubview(label)
        }
        
        stack.snp.makeConstraints { make in
            let insets = UIEdgeInsets(top: 10, left: 35, bottom: 0, right: 35)
            make.top.left.bottom.top.equalToSuperview().inset(insets)
        }
    }
    
    @IBAction func openButtonDidTap(_ sender: Any) {
        isOpen.toggle()
        animation()
    }
    
    private func setupButton() {
        let image = isOpen ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
        toggleButton.setImage(image, for: .normal)
    }
    
    private func animation() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.containerView.isHidden = !self.isOpen
            
            if self.isOpen {
                self.delegate?.viewDidOpen()
            }
            self.setupButton()
        }
    }
    
    func collapse() {
        if isOpen {
            isOpen = false
        }
    }
}
