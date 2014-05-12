class BnaViewController < UITableViewController
  SEGUE_DETAIL = 'authenticator_detail'
  SEGUE_RESTORE = 'authenticator_restore'
  REGIONS = Bnet::AUTHENTICATOR_HOSTS.keys

  extend IB

  include BnaViewControllerTableView

  ib_action :addButtonTapped

  def viewDidLoad
    super

    @progressview = UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault)
    @progressview.trackTintColor = UIColor.clearColor
    @progressview.progress = 0.5
    @progressview.translatesAutoresizingMaskIntoConstraints = false
    self.navigationController.view.addSubview @progressview

    self.navigationController.view.addConstraints NSLayoutConstraint.constraintsWithVisualFormat("V:[navbar]-(-2)-[progressview]",
                                                                            options: NSLayoutFormatDirectionLeadingToTrailing,
                                                                            metrics: nil,
                                                                            views: { "navbar" => self.navigationController.navigationBar, "progressview" => @progressview })
    self.navigationController.view.addConstraints NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressview]|",
                                                                            options: NSLayoutFormatDirectionLeadingToTrailing,
                                                                            metrics: nil,
                                                                            views: {"progressview" => @progressview})

    @timer = CADisplayLink.displayLinkWithTarget(self, selector: :update_progress)
    @timer.addToRunLoop(NSRunLoop.currentRunLoop, forMode: NSRunLoopCommonModes)
  end

  def prepareForSegue(segue, sender: sender)
    case segue.identifier
    when SEGUE_DETAIL
      dest = segue.destinationViewController
      authenticator = sender.authenticator
      dest.authenticator = WeakRef.new authenticator
    end
  end

  def update_progress
    return if @progressview.nil?
    progress = Bnet::Authenticator.get_progress
    @progressview.progress = progress
    @progressview.progressTintColor = BnaHelpers.color_at_progress(progress)
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
        Dispatch::Queue.main.sync do
          tableView.reloadData
          tableView.scrollToRowAtIndexPath(
            NSIndexPath.indexPathForRow(AuthenticatorList.number_of_authenticators - 1, inSection: 0),
            atScrollPosition: UITableViewScrollPositionBottom,
            animated: true)
          MMProgressHUD.dismissWithSuccess 'success!'
        end
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
