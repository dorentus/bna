class BnaViewController < UITableViewController
  extend IB

  include BnaViewControllerTableView
  include BnaViewControllerAddButton
  include BnaDisplayLinkExt

  ib_action :addButtonTapped

  def viewDidLoad
    super
  end

  def prepareForSegue(segue, sender: sender)
    dest = segue.destinationViewController
    authenticator = sender.authenticator
    dest.authenticator = WeakRef.new authenticator rescue NoMethodError
  end
end
