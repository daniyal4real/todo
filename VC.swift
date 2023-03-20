//
//  ViewController.swift
//  todo
//
//  Created by dan on 18.03.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UINib(nibName: ItemCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ItemCell.identifier)
        return table
    }()
    
    
    private var tasks = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Список задач"
        
        
        view.addSubview(tableView)
        getAllItems()
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "Добавить", message: "Введите новую задачу", preferredStyle: .alert)
        alert.addTextField(configurationHandler: .none)
        alert.addAction(UIAlertAction(title: "Готово", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
               return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }

    
    func getAllItems() {
    
        do {
            tasks = try context.fetch(ToDoListItem.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        catch {
            
        }
        
    }
    
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.created = Date()
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier, for: indexPath) as! ItemCell
        cell.detailsLabel.text = task.name
        cell.dateLabel?.text = task.created?.formatted()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sheet = UIAlertController(title: "Редактировать", message: nil, preferredStyle: .actionSheet)
        let item = tasks[indexPath.row]
        sheet.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Редактировать задачу", message: "Введите вашу задачу", preferredStyle: .alert)
            alert.addTextField(configurationHandler: .none)
            alert.addAction(UIAlertAction(title: "Сохранить", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                   return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }

}

