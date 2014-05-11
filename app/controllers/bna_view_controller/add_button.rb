module BnaViewControllerAddButton
  REGIONS = Bnet::AUTHENTICATOR_HOSTS.keys

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
    args << nil

    sheet = UIActionSheet.alloc
    sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', *args
    sheet.showFromBarButtonItem(sender, animated: true)
  end

  def actionSheet(sheet, clickedButtonAtIndex: index)
    selected_region = REGIONS.fetch index, nil
    return if selected_region.nil?

    puts "##{index} #{selected_region} choosen"

    MMProgressHUD.show
    request_queue.async do
      begin
        authenticator = Bnet::Authenticator.request_authenticator(selected_region)
        puts "Authenticator: #{authenticator}"
        AuthenticatorList.add_authenticator authenticator
        Dispatch::Queue.main.async do
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
