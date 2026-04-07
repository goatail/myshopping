//
//  AddressEditViewController.swift
//  myshopping
//
//  对齐 Android AddressEditActivity：校验文案、默认地址、标题
//

import UIKit

final class AddressEditViewController: UIViewController {

    private var address: Address?
    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let provinceField = UITextField()
    private let cityField = UITextField()
    private let districtField = UITextField()
    private let detailField = UITextField()
    private let defaultSwitch = UISwitch()
    private let saveButton = UIButton(type: .system)

    init(address: Address?) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = address == nil ? "新增收货地址" : "编辑收货地址"
        view.backgroundColor = .white

        func borderedField(_ placeholder: String) -> UITextField {
            let t = UITextField()
            t.placeholder = placeholder
            t.borderStyle = .roundedRect
            return t
        }

        nameField.placeholder = "收货人姓名"
        nameField.borderStyle = .roundedRect
        phoneField.placeholder = "手机号码"
        phoneField.borderStyle = .roundedRect
        phoneField.keyboardType = .phonePad
        provinceField.placeholder = "省"
        provinceField.borderStyle = .roundedRect
        cityField.placeholder = "市"
        cityField.borderStyle = .roundedRect
        districtField.placeholder = "区/县"
        districtField.borderStyle = .roundedRect
        detailField.placeholder = "详细地址"
        detailField.borderStyle = .roundedRect

        if let a = address {
            nameField.text = a.name
            phoneField.text = a.phone
            provinceField.text = a.province
            cityField.text = a.city
            districtField.text = a.district
            detailField.text = a.detail
            defaultSwitch.isOn = a.isDefault
        }

        let defaultCaption = UILabel()
        defaultCaption.text = "设为默认地址"
        defaultCaption.font = UIFont.systemFont(ofSize: 15)
        let defaultRow = UIStackView(arrangedSubviews: [defaultCaption, UIView(), defaultSwitch])
        defaultRow.axis = .horizontal
        defaultRow.alignment = .center

        saveButton.setTitle("保存", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stack = UIStackView(arrangedSubviews: [
            nameField, phoneField, provinceField, cityField, districtField, detailField,
            defaultRow, saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: guide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    @objc private func save() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let province = provinceField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let city = cityField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let district = districtField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let detail = detailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let asDefault = defaultSwitch.isOn

        if name.isEmpty {
            presentHint("请输入收货人姓名")
            return
        }
        if phone.isEmpty {
            presentHint("请输入手机号码")
            return
        }
        if province.isEmpty || city.isEmpty || district.isEmpty {
            presentHint("请完善省/市/区信息")
            return
        }
        if detail.isEmpty {
            presentHint("请输入详细地址")
            return
        }

        if var existing = address, !existing.id.isEmpty {
            existing.name = name
            existing.phone = phone
            existing.province = province
            existing.city = city
            existing.district = district
            existing.detail = detail
            existing.isDefault = asDefault
            AddressManager.updateAddress(existing)
            if asDefault {
                AddressManager.setDefaultAddress(existing.id)
            }
            presentHint("保存成功") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        let newAddr = Address(
            id: "",
            name: name,
            phone: phone,
            province: province,
            city: city,
            district: district,
            detail: detail,
            isDefault: asDefault
        )
        let newId = AddressManager.addAddress(newAddr)
        if asDefault {
            AddressManager.setDefaultAddress(newId)
        }
        presentHint("添加成功") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func presentHint(_ message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in completion?() }))
        present(ac, animated: true)
    }
}
