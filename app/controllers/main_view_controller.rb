class MainViewController < UITableViewController
  SEGUE_DETAIL = 'authenticator_detail'
  SEGUE_RESTORE = 'authenticator_restore'
  REGIONS = Bnet::AUTHENTICATOR_HOSTS.keys

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

  def dummy
    # to make sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', ... work
    UIActionSheet.alloc.initWithTitle(nil, delegate:nil, cancelButtonTitle:nil, destructiveButtonTitle:nil, otherButtonTitles:nil)
  end

  def addButtonTapped(sender)
    args = ['Choose Region', self, 'Cancel', nil]
    args.concat REGIONS
    args << 'RESTORE'
    args << nil

    sheet = UIActionSheet.alloc
    sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', *args
    sheet.showFromBarButtonItem(sender, animated: true)
  end

  def actionSheet(sheet, clickedButtonAtIndex: index)
    if index == REGIONS.count
      puts "RESTORE"
      self.performSegueWithIdentifier(SEGUE_RESTORE, sender: self)
      return
    end

    selected_region = REGIONS.fetch index, nil
    return if selected_region.nil?

    puts "##{index} #{selected_region} choosen"

    MMProgressHUD.show
    request_queue.async do
      begin
        authenticator = Bnet::Authenticator.request_authenticator(selected_region)
        puts "Authenticator: #{authenticator}"
        AuthenticatorList.add_authenticator authenticator
        reload_and_scroll_to_bottom
        MMProgressHUD.dismissWithSuccess 'success!'
      rescue Bnet::BadInputError => e
        puts "Error: #{e}"
        MMProgressHUD.dismissWithError e.message
      rescue Bnet::RequestFailedError => e
        puts "Error: #{e}"
        MMProgressHUD.dismissWithError e.message
      end
    end
  end
end
