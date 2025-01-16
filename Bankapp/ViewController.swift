import UIKit

/// Основной экран приложения
class ViewController: UIViewController {
    // Модель банковского счёта
    private let account = BankAccount() // Экземпляр для работы с банковским счётом

    // Элементы интерфейса
    private let balanceLabel = UILabel() // Метка для отображения текущего баланса
    private let transactionsTableView = UITableView() // Таблица для отображения списка транзакций

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Настраиваем интерфейс при загрузке экрана
    }

    /// Настройка пользовательского интерфейса
    private func setupUI() {
        view.backgroundColor = .white // Задаём белый фон для экрана

        // Настройка метки для отображения текущего баланса
        balanceLabel.text = "Баланс: \(account.balance) ₽" // Изначально выводим текущий баланс
        balanceLabel.textAlignment = .center // Текст выравнивается по центру
        balanceLabel.font = .boldSystemFont(ofSize: 50) // Устанавливаем крупный жирный шрифт

        // Создаём стек с кнопками для операций
        let stackView = UIStackView(arrangedSubviews: [
            createButton(title: "Снять наличные", action: #selector(withdrawCash)), // Кнопка снятия наличных
            createButton(title: "Пополнить наличными", action: #selector(depositCash)), // Кнопка пополнения наличными
            createButton(title: "Пополнить телефон", action: #selector(rechargePhone)) // Кнопка пополнения телефона
        ])
        stackView.axis = .vertical // Располагаем кнопки вертикально
        stackView.spacing = 10 // Устанавливаем расстояние между кнопками

        // Настраиваем таблицу для отображения транзакций
        transactionsTableView.dataSource = self // Источник данных — текущий контроллер
        transactionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // Регистрируем ячейку

        // Объединяем элементы интерфейса в основной стек
        let mainStack = UIStackView(arrangedSubviews: [balanceLabel, stackView, transactionsTableView])
        mainStack.axis = .vertical // Располагаем элементы вертикально
        mainStack.spacing = 20 // Задаём расстояние между элементами
        mainStack.translatesAutoresizingMaskIntoConstraints = false // Используем Auto Layout

        view.addSubview(mainStack) // Добавляем стек на экран

        // Устанавливаем ограничения для основного стека
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // Отступ сверху
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Отступ слева
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Отступ справа
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20) // Отступ снизу
        ])
    }

    /// Создание кнопки с заданным названием и действием
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system) // Создаём кнопку стандартного типа
        button.setTitle(title, for: .normal) // Устанавливаем текст на кнопке
        button.addTarget(self, action: action, for: .touchUpInside) // Привязываем действие к кнопке
        return button
    }

    // Действия для кнопок
    @objc private func withdrawCash() { handleTransaction(type: .withdraw) } // Снятие наличных
    @objc private func depositCash() { handleTransaction(type: .deposit) } // Пополнение наличными
    @objc private func rechargePhone() { handleTransaction(type: .recharge) } // Пополнение телефона

    /// Обработка транзакций с вводом суммы
    private func handleTransaction(type: TransactionType) {
        let alert = UIAlertController(title: "Введите сумму", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in textField.keyboardType = .numberPad } // Поле ввода для суммы
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            // Извлекаем сумму из текстового поля
            guard let text = alert.textFields?.first?.text, let amount = Double(text), amount > 0 else { return }
            var success = false // Флаг успешности операции
            switch type {
            case .withdraw: success = self.account.withdrawCash(amount) // Снятие наличных
            case .deposit: self.account.depositCash(amount); success = true // Пополнение наличными
            case .recharge: success = self.account.rechargePhone(amount) // Пополнение телефона
            }
            if success {
                self.updateUI() // Обновляем интерфейс
            } else {
                self.showError() // Показываем ошибку
            }
        }
        alert.addAction(action) // Добавляем действие OK
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel)) // Добавляем действие отмены
        present(alert, animated: true) // Показываем диалог
    }

    /// Обновление интерфейса после изменения данных
    private func updateUI() {
        balanceLabel.text = "Баланс: \(account.balance) ₽" // Обновляем текст баланса
        transactionsTableView.reloadData() // Перезагружаем данные таблицы
    }

    /// Показ ошибки
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Недостаточно средств", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default)) // Кнопка закрытия
        present(alert, animated: true) // Показываем диалог
    }
}

// Расширение для работы таблицы с данными
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.getSortedTransactions().count // Количество транзакций
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) // Создаём ячейку
        let transaction = account.getSortedTransactions()[indexPath.row] // Получаем транзакцию
        cell.textLabel?.text = "\(transaction.description): \(transaction.amount) ₽ (\(transaction.date))" // Описание транзакции
        return cell
    }
}
