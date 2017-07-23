import UIKit

class TestTableViewController: UITableViewController {
    var sections: [[String]] = []
    var workaroundSwitch: UISwitch!
    var shouldApplyWorkaround: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        refill()

        workaroundSwitch = UISwitch()
        workaroundSwitch.addTarget(self, action: #selector(workaroundSwitchDidChange), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: workaroundSwitch)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refill))
    }

    @objc func workaroundSwitchDidChange() {
        shouldApplyWorkaround = workaroundSwitch.isOn
    }

    @objc func refill() {
        let string = "abcdefghijklmnopqrstuvwxyz"
        sections = string.characters.map { [String($0)] }
        tableView.reloadData()
    }
}

extension TestTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (sections[section].first?.characters.first).map { String($0) } ?? ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = sections[indexPath.section][indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] _, indexPath in
                guard let vc = self else { return }

                vc.tableView.beginUpdates()
                defer { vc.tableView.endUpdates() }

                vc.sections[indexPath.section].remove(at: indexPath.row)
                if vc.sections[indexPath.section].isEmpty {
                    vc.sections.remove(at: indexPath.section)
                    vc.tableView.deleteSections([indexPath.section], with: .fade)

                    if vc.shouldApplyWorkaround {
                        for i in (indexPath.section + 1) ..< (vc.sections.count + 1) {
                            vc.tableView.moveSection(i, toSection: i - 1)
                        }
                    }
                } else {
                    vc.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        ]
    }
}
