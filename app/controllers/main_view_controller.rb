class MainViewController < UITableViewController
  SEGUE_DETAIL = 'authenticator_detail'
  SEGUE_RESTORE = 'authenticator_restore'

  extend IB

  include MainViewControllerTableView
  include MainViewControllerProgressView

  ib_action :addButtonTapped
  ib_action :editButtonTapped

  def viewDidLoad
    super

    add_progressview
  end

  def reload_and_scroll_to_bottom
    Dispatch::Queue.main.async do
      tableView.reloadData
      tableView.scrollToRowAtIndexPath(
        NSIndexPath.indexPathForRow(AuthenticatorList.number_of_authenticators - 1, inSection: 0),
        atScrollPosition: UITableViewScrollPositionBottom,
        animated: true
      )
    end
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when SEGUE_DETAIL
      dest = segue.destinationViewController
      authenticator = sender.authenticator
      dest.authenticator = WeakRef.new authenticator
    end
  end

  def editButtonTapped(sender)
    self.tableView.setEditing !self.tableView.editing?, animated: true
  end

  def request_queue
    @request_queue ||= Dispatch::Queue.new 'bna_request'
  end

  def addButtonTapped(sender)
    buttons = {
      cancel: 'Cancel',
      destructive: nil,
    }
    buttons.merge!(Hash[Bnet::AUTHENTICATOR_HOSTS.keys.map { |r| [r, r.to_s] }])
    buttons.merge!({
      restore: 'Restore',
    })

    UIActionSheet.alert('Choose', buttons: buttons) do |button|
      if button == :restore
        self.performSegueWithIdentifier(SEGUE_RESTORE, sender: self)
      elsif Bnet::AUTHENTICATOR_HOSTS.has_key? button
        request_authenticator button
      end
    end
  end

  def request_authenticator(region)
    MMProgressHUD.show
    request_queue.async do
      begin
        authenticator = Bnet::Authenticator.request_authenticator(region)
        AuthenticatorList.add_authenticator authenticator
        reload_and_scroll_to_bottom
        MMProgressHUD.dismissWithSuccess 'success!'
      rescue Bnet::BadInputError, Bnet::RequestFailedError => e
        MMProgressHUD.dismissWithError e.message
      end
    end
  end
end
