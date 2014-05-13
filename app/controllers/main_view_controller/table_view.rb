module MainViewControllerTableView
  extend IB

  CELL_ID = 'AUTHENTICATOR_CELL'

  def tableView(tableView, numberOfRowsInSection: section)
    AuthenticatorList.number_of_authenticators
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID, forIndexPath: indexPath)
    cell.authenticator = AuthenticatorList.authenticator_at_index(indexPath.row)
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    AuthenticatorCell::DEFAULT_HEIGHT
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    return unless editingStyle == UITableViewCellEditingStyleDelete
    cell = tableView.cellForRowAtIndexPath(indexPath)
    if AuthenticatorList.del_authenticator(cell.authenticator)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationAutomatic)
    end
  end
end
